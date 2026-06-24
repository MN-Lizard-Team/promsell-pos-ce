import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/barcode/barcode_scanner_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/layout/sticky_action_bar.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/generate_barcode.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/add_product_draft_cubit.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_picker_bottom_sheet.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_add/add_product_draft_handler.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_add/advanced_tab_view.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_add/basic_tab_view.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_add/image_source_handler.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController(text: '0');
  final _skuCtrl = TextEditingController();
  final _barcodeCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  String? _imagePath;
  String? _imageThumbnailPath;
  bool _trackStock = true;
  Category? _selectedCategory;
  bool _submitted = false;
  bool _isDirty = false;
  final List<String> _tempImagePaths = [];

  late final ImageSourceHandler _imageHandler;
  late final AddProductDraftHandler _draftHandler;

  @override
  void initState() {
    super.initState();
    _imageHandler = ImageSourceHandler(
      setState: setState,
      isMounted: () => mounted,
      onImagePicked: (path, thumb) {
        _imageHandler.deleteTempImages();
        _imagePath = path;
        _imageThumbnailPath = thumb;
        _markDirty();
      },
      onImageRemoved: () {
        _imagePath = null;
        _imageThumbnailPath = null;
        _markDirty();
      },
      tempImagePaths: _tempImagePaths,
    );
    _draftHandler = AddProductDraftHandler(
      nameCtrl: _nameCtrl,
      priceCtrl: _priceCtrl,
      stockCtrl: _stockCtrl,
      skuCtrl: _skuCtrl,
      barcodeCtrl: _barcodeCtrl,
      costCtrl: _costCtrl,
    );
    _checkDraft();
  }

  void _checkDraft() {
    final draftCubit = context.read<AddProductDraftCubit>();
    final draft = draftCubit.loadDraft();
    if (draft != null && draft.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _draftHandler.showRestoreDialog(
          context,
          draft,
          onRestore: () {
            _draftHandler.restoreDraft(
              context,
              draft,
              onCategoryRestored: (cat) => _selectedCategory = cat,
              onImageRestored: (path, thumb) {
                _imagePath = path;
                _imageThumbnailPath = thumb;
              },
              onTrackStockRestored: (v) => _trackStock = v,
              onSetState: () => setState(() {}),
            );
            context.read<AddProductDraftCubit>().clearDraft();
          },
          onDiscard: () {
            context.read<AddProductDraftCubit>().clearDraft();
          },
        );
      });
    }
  }

  @override
  void dispose() {
    _imageHandler.deleteTempImages();
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _skuCtrl.dispose();
    _barcodeCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  void _markDirty() => _isDirty = true;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_submitted) return;
    _submitted = true;

    final price = double.tryParse(_priceCtrl.text);
    final stock = _trackStock ? int.tryParse(_stockCtrl.text) : 0;
    final cost = double.tryParse(_costCtrl.text);
    if (price == null || stock == null) return;

    context.read<ProductBloc>().add(
      ProductAdded(
        name: _nameCtrl.text.trim(),
        price: price,
        stock: stock,
        sku: _skuCtrl.text.trim().isEmpty ? null : _skuCtrl.text.trim(),
        barcode: _barcodeCtrl.text.trim().isEmpty
            ? null
            : _barcodeCtrl.text.trim(),
        cost: cost,
        categoryId: _selectedCategory?.id,
        imagePath: _imagePath,
        imageThumbnailPath: _imageThumbnailPath,
        trackStock: _trackStock,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final result = await _draftHandler.onWillPop(
      context,
      isDirty: _isDirty,
      submitted: _submitted,
      onDiscard: () {
        _imageHandler.deleteTempImages();
      },
    );
    if (result && mounted) {
      final draftCubit = context.read<AddProductDraftCubit>();
      if (_isDirty && !_submitted) {
        draftCubit.saveDraft(
          _draftHandler.collectDraft(
            selectedCategory: _selectedCategory,
            imagePath: _imagePath,
            imageThumbnailPath: _imageThumbnailPath,
            trackStock: _trackStock,
          ),
        );
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<SettingsCubit>().state.settings.currency;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final canPop = await _onWillPop();
        if (!canPop) return;
        if (!context.mounted) return;
        Navigator.of(context).pop();
      },
      child: BlocListener<ProductBloc, ProductState>(
        listenWhen: (prev, curr) =>
            _submitted && prev.saveStatus != curr.saveStatus,
        listener: (ctx, state) {
          if (state.saveStatus == ProductSaveStatus.saved) {
            context.read<AddProductDraftCubit>().clearDraft();
            Navigator.pop(ctx, true);
          } else if (state.saveStatus == ProductSaveStatus.error) {
            _submitted = false;
            final msg = state.errorMessage == 'duplicateBarcode'
                ? ctx.l10n.duplicateBarcode
                : state.errorMessage ?? ctx.l10n.errorOccurred;
            AppSnackBar.error(ctx, msg);
          }
        },
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text(context.l10n.addProductTitle),
              bottom: TabBar(
                tabs: [
                  Tab(text: context.l10n.basic),
                  Tab(text: context.l10n.advanced),
                ],
              ),
            ),
            body: Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: TabBarView(
                      children: [
                        BasicTabView(
                          nameCtrl: _nameCtrl,
                          priceCtrl: _priceCtrl,
                          stockCtrl: _stockCtrl,
                          imagePath: _imagePath,
                          isPickingImage: _imageHandler.isPickingImage,
                          trackStock: _trackStock,
                          selectedCategory: _selectedCategory,
                          currency: currency,
                          onMarkDirty: _markDirty,
                          onImageTap: () => _imageHandler.showSheet(
                            context,
                            hasImage: _imagePath != null,
                            productId: 'new',
                            logTag: 'AddProductPage',
                          ),
                          onPickCategory: () => _pickCategory(context),
                          onStockChanged: (_) => setState(() {}),
                        ),
                        AdvancedTabView(
                          barcodeCtrl: _barcodeCtrl,
                          skuCtrl: _skuCtrl,
                          costCtrl: _costCtrl,
                          trackStock: _trackStock,
                          currency: currency,
                          onMarkDirty: _markDirty,
                          onScanBarcode: () => _scanBarcode(context),
                          onGenerateBarcode: () => _generateBarcode(context),
                          onTrackStockChanged: (v) {
                            setState(() => _trackStock = v);
                            _markDirty();
                          },
                        ),
                      ],
                    ),
                  ),
                  SafeArea(
                    child: BlocBuilder<ProductBloc, ProductState>(
                      builder: (_, state) {
                        final isSaving =
                            state.saveStatus == ProductSaveStatus.saving;
                        return StickyActionBar(
                          primaryLabel: context.l10n.addProduct,
                          isLoading: isSaving,
                          onPrimary: isSaving ? null : _submit,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _scanBarcode(BuildContext context) async {
    final settings = GetIt.I<SettingsCubit>().state.settings;
    final barcode = await showProductBarcodeScanner(
      context,
      beepOnScan: settings.barcodeBeepOnScan,
      formats: barcodeFormatsFromNames(settings.barcodeEnabledFormats),
      autoOpenManualDelay: settings.barcodeAutoOpenManualDelay,
    );
    if (barcode != null && barcode.isNotEmpty) {
      setState(() => _barcodeCtrl.text = barcode);
      _markDirty();
    }
  }

  Future<void> _generateBarcode(BuildContext context) async {
    final l10n = context.l10n;
    final prefix =
        GetIt.I<SettingsCubit>().state.settings.barcodeAutoGeneratePrefix;
    try {
      final barcode = await GetIt.I<GenerateBarcode>()(prefix: prefix);
      if (!context.mounted) return;
      setState(() => _barcodeCtrl.text = barcode);
      _markDirty();
      AppSnackBar.success(context, l10n.barcodeGenerated);
    } catch (e, stack) {
      AppLogger.error(
        'AddProductPage barcode generation failed',
        error: e,
        stack: stack,
      );
      if (context.mounted) AppSnackBar.error(context, l10n.errorOccurred);
    }
  }

  Future<void> _pickCategory(BuildContext context) async {
    final result = await showCategoryPicker(
      context,
      selectedId: _selectedCategory?.id,
      showNoneOption: true,
    );
    if (result != null || _selectedCategory != null) {
      setState(() {
        _selectedCategory = result;
        _markDirty();
      });
    }
  }
}
