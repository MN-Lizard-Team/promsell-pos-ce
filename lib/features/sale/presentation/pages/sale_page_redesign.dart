import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/adaptive_breakpoints.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart_panel.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/drafts_bottom_sheet.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/sale_catalog.dart';

class SalePage extends StatelessWidget {
  const SalePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<ProductBloc>()),
        BlocProvider(
          create: (_) => sl<SaleBloc>()..add(const SaleDraftInitialized()),
        ),
      ],
      child: const _SaleView(),
    );
  }
}

class _SaleView extends StatefulWidget {
  const _SaleView();

  @override
  State<_SaleView> createState() => _SaleViewState();
}

class _SaleViewState extends State<_SaleView> {
  late final ValueNotifier<double> _cartHeight;
  late final ValueNotifier<double> _cartWidth;
  late final ValueNotifier<bool> _isDraggingHandle;

  static const double _minCartHeightPortrait = 260;
  static const double _minCartHeightLandscape = 220;
  static const double _maxCartHeightRatioPortrait = 0.65;
  static const double _maxCartHeightRatioLandscape = 0.50;

  static const double _minCartWidth = 300;
  static const double _maxCartWidth = 560;
  static const double _handleHeight = 18;
  static const double _snapTolerance = 18;

  @override
  void initState() {
    super.initState();
    _cartHeight = ValueNotifier(280);
    _cartWidth = ValueNotifier(390);
    _isDraggingHandle = ValueNotifier(false);
  }

  @override
  void dispose() {
    _cartHeight.dispose();
    _cartWidth.dispose();
    _isDraggingHandle.dispose();
    super.dispose();
  }

  double _minCartHeight(BuildContext context) {
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    return isLandscape ? _minCartHeightLandscape : _minCartHeightPortrait;
  }

  double _maxCartHeightRatio(BuildContext context) {
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    return isLandscape
        ? _maxCartHeightRatioLandscape
        : _maxCartHeightRatioPortrait;
  }

  double _maxCartHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height * _maxCartHeightRatio(context);

  void _onVerticalDrag(BuildContext context, DragUpdateDetails details) {
    final minH = _minCartHeight(context);
    final maxH = _maxCartHeight(context);
    _cartHeight.value = (_cartHeight.value - details.delta.dy).clamp(
      minH,
      maxH,
    );
  }

  void _onHorizontalDrag(DragUpdateDetails details) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final dxAdjusted = isRtl ? -details.delta.dx : details.delta.dx;
    _cartWidth.value = (_cartWidth.value - dxAdjusted).clamp(
      _minCartWidth,
      _maxCartWidth,
    );
  }

  void _onDragEnd() => _isDraggingHandle.value = false;

  void _onDragStart() => _isDraggingHandle.value = true;

  void _onVerticalDragEnd(BuildContext context, DragEndDetails details) {
    final maxH = _maxCartHeight(context);
    final minH = _minCartHeight(context);
    final presets = <double>[minH, maxH];
    for (final p in presets) {
      if ((_cartHeight.value - p).abs() < _snapTolerance) {
        _cartHeight.value = p;
        break;
      }
    }
    _onDragEnd();
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    const presets = <double>[320, 500];
    for (final p in presets) {
      if ((_cartWidth.value - p).abs() < _snapTolerance) {
        _cartWidth.value = p;
        break;
      }
    }
    _onDragEnd();
  }

  void _onSizePresetChanged(BuildContext context, double value) {
    if (value <= 0.0) {
      _cartHeight.value = _minCartHeight(context);
    } else {
      _cartHeight.value = _maxCartHeight(context);
    }
  }

  void _onWidthPresetChanged(double value) {
    if (value <= 0.0) {
      _cartWidth.value = 320;
    } else {
      _cartWidth.value = 500;
    }
  }

  double? _currentSizePreset(BuildContext context) {
    if (_cartHeight.value <= _minCartHeight(context) + 1) return 0.0;
    if (_cartHeight.value >= _maxCartHeight(context) - 1) return 1.0;
    return null;
  }

  double? _currentWidthPreset() {
    if ((_cartWidth.value - 320).abs() < 10) return 0.0;
    if ((_cartWidth.value - 500).abs() < 10) return 1.0;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final isExpanded =
        AdaptiveBreakpoints.isExpanded(context) ||
        (isLandscape && size.width >= 600);

    return BlocListener<ProductBloc, ProductState>(
      listenWhen: (prev, curr) =>
          curr.status == ProductStatus.success &&
          prev.products != curr.products,
      listener: (context, state) {
        context.read<SaleBloc>().add(SaleCartProductsRefreshed(state.products));
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.salePageTitle),
          actions: [
            BlocBuilder<SaleBloc, SaleState>(
              builder: (ctx, state) => IconButton(
                icon: Badge(
                  isLabelVisible: state.activeDraftId != null,
                  child: const Icon(Icons.bookmarks_outlined),
                ),
                tooltip: ctx.l10n.draftsTitle,
                onPressed: () => DraftsBottomSheet.show(ctx),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 12, isExpanded ? 12 : 8),
            child: isExpanded ? _buildExpandedLayout() : _buildCompactLayout(),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxCartH =
            (constraints.maxHeight * _maxCartHeightRatio(context) -
                    _handleHeight)
                .clamp(_minCartHeight(context), double.infinity);
        return Column(
          children: [
            const Expanded(child: SaleCatalog()),
            MouseRegion(
              cursor: SystemMouseCursors.resizeRow,
              child: GestureDetector(
                onVerticalDragStart: (_) => _onDragStart(),
                onVerticalDragUpdate: (d) => _onVerticalDrag(context, d),
                onVerticalDragEnd: (d) => _onVerticalDragEnd(context, d),
                onVerticalDragCancel: _onDragEnd,
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  height: 24,
                  child: Center(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _isDraggingHandle,
                      builder: (context, isDragging, child) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: isDragging ? 56 : 40,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isDragging
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            ValueListenableBuilder<double>(
              valueListenable: _cartHeight,
              builder: (context, cartHeight, _) {
                final effectiveH = cartHeight.clamp(
                  _minCartHeight(context),
                  maxCartH,
                );
                return SizedBox(
                  height: effectiveH,
                  child: CartPanel(
                    expanded: false,
                    sizePreset: _currentSizePreset(context),
                    onSizePresetChanged: (v) =>
                        _onSizePresetChanged(context, v),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildExpandedLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Expanded(child: SaleCatalog()),
        MouseRegion(
          cursor: SystemMouseCursors.resizeColumn,
          child: GestureDetector(
            onHorizontalDragStart: (_) => _onDragStart(),
            onHorizontalDragUpdate: _onHorizontalDrag,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            onHorizontalDragCancel: _onDragEnd,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 20,
              child: Center(
                child: ValueListenableBuilder<bool>(
                  valueListenable: _isDraggingHandle,
                  builder: (context, isDragging, child) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 6,
                      height: isDragging ? 56 : 40,
                      decoration: BoxDecoration(
                        color: isDragging
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        ValueListenableBuilder<double>(
          valueListenable: _cartWidth,
          builder: (context, cartWidth, child) {
            return SizedBox(
              width: cartWidth,
              child: CartPanel(
                expanded: true,
                widthPreset: _currentWidthPreset(),
                onWidthPresetChanged: _onWidthPresetChanged,
              ),
            );
          },
        ),
      ],
    );
  }
}
