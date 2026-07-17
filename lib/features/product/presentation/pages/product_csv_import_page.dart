import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/app_lock_pin_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/layout/sticky_action_bar.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/product/domain/utils/csv_product_parser.dart';
import 'package:promsell_pos_ce/features/product/domain/utils/csv_product_parser_impl.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

/// Soft limits for mobile POS devices.
const int kCsvImportMaxBytes = 2 * 1024 * 1024; // 2 MB
const int kCsvImportMaxDataRows = 2000;
const int kCsvImportMaxMb = 2;

/// Thai-primary template headers aligned with [CsvProductParser] aliases.
const String kCsvProductTemplateContent =
    'ชื่อ,ราคา,รหัสสินค้า,บาร์โค้ด,ต้นทุน,สต็อก,หมวดหมู่,ติดตามสต็อก\n'
    'กาแฟร้อน,45,SKU-001,8850001111111,20,50,เครื่องดื่ม,true\n'
    'น้ำเปล่า,10,,8850002222222,5,100,เครื่องดื่ม,true\n';

/// Opens the product CSV import flow as a full page (shared [ProductBloc]).
///
/// When store PIN lock is enabled, prompts before navigating to the import page.
Future<bool?> openProductCsvImport(BuildContext context) async {
  final unlocked = await ensureAppUnlocked(
    context,
    title: context.l10n.appLockConfirmCsv,
  );
  if (!unlocked || !context.mounted) return null;

  ProductBloc productBloc;
  try {
    productBloc = context.read<ProductBloc>();
  } catch (_) {
    productBloc = sl<ProductBloc>();
  }

  return Navigator.of(context, rootNavigator: true).push<bool>(
    MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: productBloc,
        child: const ProductCsvImportPage(),
      ),
    ),
  );
}

/// Compat alias — prefer [openProductCsvImport].
void showCsvImportDialog(BuildContext context) {
  openProductCsvImport(context);
}

class ProductCsvImportPage extends StatefulWidget {
  const ProductCsvImportPage({super.key});

  @override
  State<ProductCsvImportPage> createState() => _ProductCsvImportPageState();
}

class _ProductCsvImportPageState extends State<ProductCsvImportPage> {
  final _parser = const CsvProductParser(maxDataRows: kCsvImportMaxDataRows);
  List<CsvProductRow> _rows = [];
  List<CsvImportRowError> _parseRowErrors = [];
  List<CsvImportRowError>? _postImportErrors;
  int _postImportedCount = 0;
  int _postCategoriesCreated = 0;
  String? _errorKey;
  bool _isLoading = false;
  bool _isImporting = false;
  bool _isSharingTemplate = false;

  bool get _busy => _isLoading || _isImporting;

  ProductBloc _resolveBloc(BuildContext context) {
    try {
      return context.read<ProductBloc>();
    } catch (_) {
      return sl<ProductBloc>();
    }
  }

  String _mapFileError(AppLocalizations l10n, String? key) {
    return switch (key) {
      'csvNoData' => l10n.csvNoData,
      'csvInvalidFormat' => l10n.csvInvalidFormat,
      'csvTooManyRows' => l10n.csvTooManyRows(kCsvImportMaxDataRows),
      'csvFileTooLarge' => l10n.csvFileTooLarge(kCsvImportMaxMb),
      'csvImportError' => l10n.csvImportError,
      _ => l10n.csvImportError,
    };
  }

  String _rowLabel(AppLocalizations l10n, CsvImportRowError e) {
    return l10n.csvRowLabel(e.sourceRow, e.message);
  }

  Future<void> _shareTemplate() async {
    if (_isSharingTemplate) return;
    setState(() => _isSharingTemplate = true);
    try {
      final dir = await getTemporaryDirectory();
      final file = File(p.join(dir.path, 'promsell_products_template.csv'));
      await file.writeAsString(kCsvProductTemplateContent, encoding: utf8);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'text/csv')],
          subject: 'Promsell product CSV template',
        ),
      );
      if (mounted) {
        AppSnackBar.success(context, context.l10n.csvTemplateShared);
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.error(context, context.l10n.csvImportError);
      }
    } finally {
      if (mounted) setState(() => _isSharingTemplate = false);
    }
  }

  Future<void> _pickFile() async {
    setState(() {
      _isLoading = true;
      _errorKey = null;
      _rows = [];
      _parseRowErrors = [];
      _postImportErrors = null;
    });

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt'],
      );

      if (result == null || result.files.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final platformFile = result.files.first;
      final size = platformFile.size;
      if (size > kCsvImportMaxBytes) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorKey = 'csvFileTooLarge';
          });
        }
        return;
      }

      String? content;
      try {
        final bytes = await platformFile.readAsBytes();
        content = utf8.decode(bytes, allowMalformed: true);
      } catch (_) {
        if (platformFile.path != null) {
          content = await File(platformFile.path!).readAsString(encoding: utf8);
        }
      }

      if (content == null || content.trim().isEmpty) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorKey = 'csvNoData';
          });
        }
        return;
      }

      if (content.length > kCsvImportMaxBytes * 2) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorKey = 'csvFileTooLarge';
          });
        }
        return;
      }

      final parsed = _parser.parse(content);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _rows = parsed.rows;
          _errorKey = parsed.error;
          _parseRowErrors = parsed.rowErrors;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorKey = 'csvImportError';
        });
      }
    }
  }

  void _confirmImport() {
    if (_rows.isEmpty || _isImporting) return;
    setState(() => _isImporting = true);
    _resolveBloc(context).add(ProductsImported(_rows));
  }

  void _resetToIdle() {
    setState(() {
      _rows = [];
      _parseRowErrors = [];
      _postImportErrors = null;
      _postImportedCount = 0;
      _postCategoriesCreated = 0;
      _errorKey = null;
      _isLoading = false;
      _isImporting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final productBloc = _resolveBloc(context);
    final hasPreview = _rows.isNotEmpty;
    final hasPartial =
        _postImportErrors != null && _postImportErrors!.isNotEmpty;

    final String primaryLabel;
    final VoidCallback? onPrimary;
    final String secondaryLabel;
    final VoidCallback? onSecondary;

    if (hasPartial) {
      primaryLabel = l10n.done;
      onPrimary = () => Navigator.of(context).maybePop(true);
      secondaryLabel = l10n.selectCsvFile;
      onSecondary = _busy ? null : _pickFile;
    } else if (hasPreview) {
      primaryLabel = l10n.confirmImport;
      onPrimary = _busy ? null : _confirmImport;
      secondaryLabel = l10n.selectCsvFile;
      onSecondary = _busy ? null : _pickFile;
    } else {
      primaryLabel = l10n.selectCsvFile;
      onPrimary = _busy ? null : _pickFile;
      secondaryLabel = l10n.cancel;
      onSecondary = _busy ? null : () => Navigator.of(context).maybePop();
    }

    return BlocListener<ProductBloc, ProductState>(
      bloc: productBloc,
      listenWhen: (prev, curr) =>
          _isImporting &&
          prev.importStatus == ProductImportStatus.importing &&
          (curr.importStatus == ProductImportStatus.success ||
              curr.importStatus == ProductImportStatus.failure),
      listener: (context, state) {
        if (!mounted) return;
        setState(() => _isImporting = false);

        if (state.importStatus == ProductImportStatus.success &&
            state.importResult != null) {
          final result = state.importResult!;
          final errors = result.rowErrors;
          if (errors.isEmpty) {
            var msg = l10n.importSuccess(result.importedCount);
            if (result.createdCategoryCount > 0) {
              msg =
                  '$msg · ${l10n.csvImportCategoriesCreated(result.createdCategoryCount)}';
            }
            AppSnackBar.success(context, msg);
            Navigator.of(context).pop(true);
          } else {
            AppSnackBar.warning(
              context,
              l10n.csvImportPartialSuccess(result.importedCount, errors.length),
            );
            setState(() {
              _postImportErrors = errors;
              _postImportedCount = result.importedCount;
              _postCategoriesCreated = result.createdCategoryCount;
              _rows = [];
            });
          }
        } else if (state.importStatus == ProductImportStatus.failure) {
          AppSnackBar.error(context, l10n.csvImportError);
        }
      },
      child: PopScope(
        canPop: !_busy,
        child: Scaffold(
          appBar: AppBar(
            title: Text(l10n.importFromCsv),
            actions: [
              IconButton(
                tooltip: l10n.csvDownloadTemplate,
                onPressed: (_isSharingTemplate || _busy)
                    ? null
                    : _shareTemplate,
                icon: _isSharingTemplate
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download_outlined),
              ),
            ],
          ),
          body: SafeArea(child: _buildBody(context, l10n, theme)),
          bottomNavigationBar: StickyActionBar(
            sideBySide: true,
            primaryLabel: primaryLabel,
            onPrimary: onPrimary,
            secondaryLabel: secondaryLabel,
            onSecondary: onSecondary,
            isLoading: _isImporting || (_isLoading && !hasPreview),
            primaryKey: const ValueKey('csv-import-primary'),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    if (_isLoading || _isImporting) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              if (_isImporting) ...[
                const SizedBox(height: 16),
                Text(l10n.csvImporting),
              ],
            ],
          ),
        ),
      );
    }

    if (_postImportErrors != null && _postImportErrors!.isNotEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text(
            l10n.csvImportPartialSuccess(
              _postImportedCount,
              _postImportErrors!.length,
            ),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (_postCategoriesCreated > 0) ...[
            const SizedBox(height: 4),
            Text(
              l10n.csvImportCategoriesCreated(_postCategoriesCreated),
              style: theme.textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 12),
          Text(
            l10n.csvPostImportErrorsTitle,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          ..._postImportErrors!.map(
            (e) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.warning_amber_outlined,
                color: theme.colorScheme.error,
                size: 18,
              ),
              title: Text(_rowLabel(l10n, e), style: theme.textTheme.bodySmall),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: _resetToIdle, child: Text(l10n.selectCsvFile)),
        ],
      );
    }

    if (_errorKey != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                _mapFileError(l10n, _errorKey),
                style: TextStyle(color: theme.colorScheme.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(onPressed: _pickFile, child: Text(l10n.selectCsvFile)),
            ],
          ),
        ),
      );
    }

    if (_rows.isNotEmpty) {
      return CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.csvImportPreview,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.searchShowingCount(_rows.length, _rows.length),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (_parseRowErrors.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.csvRowErrorsSkipped(_parseRowErrors.length),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.csvParseErrorsTitle,
                      style: theme.textTheme.labelMedium,
                    ),
                    const SizedBox(height: 4),
                    ..._parseRowErrors
                        .take(40)
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              _rowLabel(l10n, e),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                        ),
                    if (_parseRowErrors.length > 40)
                      Text(
                        l10n.searchShowingCount(40, _parseRowErrors.length),
                        style: theme.textTheme.labelSmall,
                      ),
                  ],
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
            sliver: SliverList.builder(
              itemCount: _rows.length,
              itemBuilder: (_, i) {
                final row = _rows[i];
                return ListTile(
                  dense: true,
                  title: Text(row.name),
                  subtitle: Text(
                    '${row.price.toStringAsFixed(2)}'
                    '${row.sku != null ? ' · ${l10n.skuLabel}: ${row.sku}' : ''}'
                    '${row.categoryName != null ? ' · ${row.categoryName}' : ''}',
                  ),
                  trailing: Text(
                    '#${row.sourceRow}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.file_upload_outlined,
              size: 56,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.selectCsvFile,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.csvColumnLegend,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: _isSharingTemplate ? null : _shareTemplate,
              icon: _isSharingTemplate
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_outlined),
              label: Text(l10n.csvDownloadTemplate),
            ),
          ],
        ),
      ),
    );
  }
}
