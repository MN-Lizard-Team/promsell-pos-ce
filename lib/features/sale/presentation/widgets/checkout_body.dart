import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/utils/payment_method_helper.dart';
import 'package:promsell_pos_ce/features/receipt/domain/entities/receipt_labels.dart';
import 'package:promsell_pos_ce/features/receipt/data/services/receipt_pdf_service.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/money_text.dart';
import 'package:promsell_pos_ce/core/widgets/receipt_preview.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/payment_widgets.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_state.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/promptpay_payment_page.dart';

class CheckoutBody extends StatefulWidget {
  const CheckoutBody({super.key});

  @override
  State<CheckoutBody> createState() => _CheckoutBodyState();
}

class _CheckoutBodyState extends State<CheckoutBody> {
  String _method = 'cash';
  final _receivedCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _referenceCtrl = TextEditingController();
  bool _submitted = false;
  bool _inPaymentFlow = false;
  double _effectiveTotal = 0;

  double get _received => double.tryParse(_receivedCtrl.text) ?? 0;
  double get _change => _received - _effectiveTotal;

  @override
  void dispose() {
    _receivedCtrl.dispose();
    _noteCtrl.dispose();
    _referenceCtrl.dispose();
    super.dispose();
  }

  void _setReceived(double value) {
    _receivedCtrl.text = value.toStringAsFixed(2);
    HapticFeedback.selectionClick();
    setState(() {});
  }

  void _confirm() {
    if (_submitted) return;
    _submitted = true;
    HapticFeedback.mediumImpact();
    final note = _noteCtrl.text.trim();
    final reference = _referenceCtrl.text.trim();
    final effectiveNote = reference.isEmpty
        ? note
        : [
            if (note.isNotEmpty) note,
            '${context.l10n.paymentReferenceOptional}: $reference',
          ].join('\n');
    final settings = context.read<SettingsCubit>().state.settings;
    final today = DateTime.now().toIso8601String().split('T').first;
    if (settings.dailyCloseLock && settings.lastClosedDate == today) {
      AppSnackBar.error(context, context.l10n.dayClosedMessage);
      _submitted = false;
      return;
    }
    final cartState = context.read<SaleBloc>().state;
    context.read<SaleBloc>().add(
      SaleConfirmed(
        paymentMethod: _method,
        vatMode: settings.vatMode,
        vatRate: settings.vatRate,
        cartDiscountType: cartState.cartDiscountType,
        cartDiscountValue: cartState.cartDiscountValue,
        cartDiscountAmount: cartState.hasCartDiscount
            ? cartState.cartDiscountAmount
            : null,
        amountReceived: _method == 'cash' ? _received : _effectiveTotal,
        changeAmount: _method == 'cash' && _change >= 0 ? _change : 0,
        note: effectiveNote.isEmpty ? null : effectiveNote,
      ),
    );
  }

  List<double> _quickAmounts() {
    final total = _effectiveTotal;
    final roundedTen = (total / 10).ceil() * 10.0;
    final roundedHundred = (total / 100).ceil() * 100.0;
    final nextTen = roundedTen > total ? roundedTen : roundedTen + 10;
    final nextHundred = roundedHundred > total
        ? roundedHundred
        : roundedHundred + 100;
    return {total, nextTen, nextHundred}.where((v) => v > 0).toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<SaleBloc, SaleState>(
      builder: (_, cartState) {
        final settings = context.watch<SettingsCubit>().state.settings;
        final currency = settings.currency;
        final vatInfo = sl<ReceiptPdfService>().calculateVat(
          total: cartState.total,
          rate: settings.vatRate,
          mode: settings.vatMode,
        );
        _effectiveTotal = vatInfo?.totalWithVat ?? cartState.total;

        return BlocListener<SaleBloc, SaleState>(
          listenWhen: (_, curr) =>
              curr.status == SaleStatus.failure ||
              curr.status == SaleStatus.success ||
              curr.status == SaleStatus.waitingPayment ||
              curr.status == SaleStatus.idle,
          listener: (ctx, state) {
            if (state.status == SaleStatus.waitingPayment) {
              _inPaymentFlow = true;
              Navigator.of(ctx).push(
                MaterialPageRoute(
                  builder: (_) => PromptPayPaymentPage(
                    total: _effectiveTotal,
                    currency: currency,
                    promptpayId: settings.promptpayId,
                    settings: settings,
                    bloc: ctx.read<SaleBloc>(),
                    items: state.items,
                  ),
                ),
              );
              return;
            }
            if (state.status == SaleStatus.success) {
              _inPaymentFlow = false;
              _submitted = false;
              Navigator.of(ctx).pop();
              return;
            }
            if (state.status == SaleStatus.idle && _inPaymentFlow) {
              _inPaymentFlow = false;
              _submitted = false;
              Navigator.of(ctx).pop();
              return;
            }
            if (state.status == SaleStatus.failure) {
              _inPaymentFlow = false;
              _submitted = false;
              AppSnackBar.error(ctx, state.errorMessage ?? ctx.l10n.saleError);
            }
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Builder(
                  builder: (_) {
                    final hasItemDiscounts = cartState.items.any(
                      (i) => i.discountAmount > 0,
                    );
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.3,
                          ),
                          width: 1.5,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            if (hasItemDiscounts || cartState.hasCartDiscount)
                              PaymentTotalRow(
                                label: context.l10n.receiptLabelSubtotal,
                                value: cartState.itemsSubtotal,
                                currency: currency,
                                style: theme.textTheme.bodyMedium,
                              ),
                            if (hasItemDiscounts)
                              PaymentTotalRow(
                                label: context.l10n.discountSectionLabel,
                                value: -cartState.items.fold(
                                  0.0,
                                  (s, i) => s + i.discountAmount,
                                ),
                                currency: currency,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            if (cartState.hasCartDiscount)
                              PaymentTotalRow(
                                label: context.l10n.cartDiscount,
                                value: -cartState.cartDiscountAmount,
                                currency: currency,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            if (vatInfo != null && !vatInfo.isInclusive)
                              PaymentTotalRow(
                                label:
                                    '${context.l10n.receiptLabelVat} ${settings.vatRate}%',
                                value: vatInfo.vatAmount,
                                currency: currency,
                                style: theme.textTheme.bodySmall,
                              ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    context.l10n.totalAmount,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontFamily: 'NotoSansThai',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  transitionBuilder: (child, animation) {
                                    return ScaleTransition(
                                      scale: animation,
                                      child: child,
                                    );
                                  },
                                  child: MoneyText(
                                    key: ValueKey<double>(_effectiveTotal),
                                    value: _effectiveTotal,
                                    currency: currency,
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
                                          fontFamily: 'NotoSansThai',
                                          fontWeight: FontWeight.w800,
                                          fontSize: 24,
                                        ),
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: PaymentMethodCard(
                        icon: Icons.payments_outlined,
                        label: context.l10n.cash,
                        selected: _method == 'cash',
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _method = 'cash';
                            _referenceCtrl.clear();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: PaymentMethodCard(
                        icon: Icons.qr_code_2_outlined,
                        label: context.l10n.transfer,
                        selected: _method == 'transfer',
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _method = 'transfer');
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: PaymentMethodCard(
                        icon: Icons.credit_card,
                        label: context.l10n.card,
                        selected: _method == 'card',
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _method = 'card');
                        },
                      ),
                    ),
                    if (settings.promptpayId.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: PaymentMethodCard(
                          icon: Icons.account_balance_wallet_outlined,
                          label: context.l10n.promptpay,
                          selected: _method == 'promptpay',
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _method = 'promptpay');
                          },
                        ),
                      ),
                    ],
                  ],
                ),
                if (_method == 'cash') ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _quickAmounts()
                        .asMap()
                        .entries
                        .map(
                          (entry) => FilledButton(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(0, 48),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              textStyle: const TextStyle(
                                fontFamily: 'NotoSansThai',
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onPressed: () => _setReceived(entry.value),
                            child: Text(
                              entry.key == 0
                                  ? context.l10n.quickCashExact
                                  : '$currency${entry.value.toStringAsFixed(2)}',
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _receivedCtrl,
                    decoration: InputDecoration(
                      labelText: context.l10n.receivedAmount(currency),
                      prefixIcon: const Icon(Icons.payments_outlined),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    autofocus: true,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 10),
                  ChangePreview(
                    change: _change,
                    currency: currency,
                    visible: _received > 0,
                  ),
                ] else if (_method == 'promptpay') ...[
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          size: 48,
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.promptpay,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          settings.promptpayId,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _referenceCtrl,
                    decoration: InputDecoration(
                      labelText: context.l10n.paymentReferenceOptional,
                      prefixIcon: const Icon(Icons.tag_outlined),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteCtrl,
                  decoration: InputDecoration(
                    labelText: context.l10n.notePlaceholder,
                    prefixIcon: const Icon(Icons.notes_outlined),
                  ),
                  textInputAction: TextInputAction.done,
                  maxLines: 1,
                ),
                const SizedBox(height: 20),
                Builder(
                  builder: (_) {
                    final isProcessing =
                        cartState.status == SaleStatus.processing;
                    final canConfirm =
                        _method != 'cash' || _received >= _effectiveTotal;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_method == 'cash' && !canConfirm && _received > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              context.l10n.insufficientCash,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 56),
                            textStyle: const TextStyle(
                              fontFamily: 'NotoSansThai',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          onPressed: isProcessing || !canConfirm
                              ? null
                              : () {
                                  HapticFeedback.mediumImpact();
                                  _confirm();
                                },
                          icon: isProcessing
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Icon(
                                  Icons.check_circle_outline,
                                  size: 24,
                                ),
                          label: Text(
                            context.l10n.confirmPaymentAmount(
                              currency,
                              _effectiveTotal.toStringAsFixed(2),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                Builder(
                  builder: (_) {
                    if (settings.showPreSalePreview &&
                        settings.receiptPreviewStyle != 'none' &&
                        !cartState.isEmpty) {
                      final labels = ReceiptLabels(
                        receipt: context.l10n.receiptLabelReceipt,
                        payment: context.l10n.receiptLabelPayment,
                        paymentMethodLabel: localizePaymentMethod(
                          context,
                          _method,
                        ),
                        total: context.l10n.receiptLabelTotal,
                        received: context.l10n.receiptLabelReceived,
                        change: context.l10n.receiptLabelChange,
                        note: context.l10n.receiptLabelNote,
                        vat: context.l10n.receiptLabelVat,
                        vatIncluded: context.l10n.receiptLabelVatIncluded(
                          settings.vatRate,
                        ),
                        subtotal: context.l10n.receiptLabelSubtotal,
                        itemDiscounts: context.l10n.receiptItemDiscounts,
                        cartDiscount: context.l10n.receiptCartDiscount,
                      );
                      final style = switch (settings.receiptPreviewStyle) {
                        'card' => ReceiptPreviewStyle.card,
                        'none' => ReceiptPreviewStyle.none,
                        _ => ReceiptPreviewStyle.thermal,
                      };
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.l10n.receiptPreview,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _showReceiptDialog(
                              context,
                              settings: settings,
                              labels: labels,
                              style: style,
                              items: cartState.items
                                  .map(
                                    (i) => ReceiptPreviewItem(
                                      name: i.product.name,
                                      qty: i.qty,
                                      price: i.product.price,
                                      subtotal: i.subtotal,
                                      imagePath: i.product.imagePath,
                                      imageThumbnailPath:
                                          i.product.imageThumbnailPath,
                                      imageUrl: i.product.imageUrl,
                                    ),
                                  )
                                  .toList(),
                              total: cartState.total,
                              vatInfo: vatInfo,
                              paymentMethod: _method,
                              amountReceived: _method == 'cash'
                                  ? _received
                                  : null,
                              changeAmount: _method == 'cash' && _change >= 0
                                  ? _change
                                  : null,
                              note: _noteCtrl.text.trim().isEmpty
                                  ? null
                                  : _noteCtrl.text.trim(),
                            ),
                            child: ReceiptPreview(
                              settings: settings,
                              labels: labels,
                              style: style,
                              items: cartState.items
                                  .map(
                                    (i) => ReceiptPreviewItem(
                                      name: i.product.name,
                                      qty: i.qty,
                                      price: i.product.price,
                                      subtotal: i.subtotal,
                                      imagePath: i.product.imagePath,
                                      imageThumbnailPath:
                                          i.product.imageThumbnailPath,
                                      imageUrl: i.product.imageUrl,
                                    ),
                                  )
                                  .toList(),
                              total: cartState.total,
                              vatInfo: vatInfo,
                              paymentMethod: _method,
                              amountReceived: _method == 'cash'
                                  ? _received
                                  : null,
                              changeAmount: _method == 'cash' && _change >= 0
                                  ? _change
                                  : null,
                              note: _noteCtrl.text.trim().isEmpty
                                  ? null
                                  : _noteCtrl.text.trim(),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showReceiptDialog(
    BuildContext context, {
    required Settings settings,
    required ReceiptLabels labels,
    required ReceiptPreviewStyle style,
    required List<ReceiptPreviewItem> items,
    required double total,
    required dynamic vatInfo,
    required String paymentMethod,
    required double? amountReceived,
    required double? changeAmount,
    required String? note,
  }) {
    showDialog(
      context: context,
      barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.92),
      builder: (_) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [
                // Receipt card
                Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 48,
                      ),
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.78,
                        maxWidth: 440,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: InteractiveViewer(
                          panEnabled: true,
                          scaleEnabled: true,
                          minScale: 0.8,
                          maxScale: 3.0,
                          boundaryMargin: const EdgeInsets.all(40),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: ReceiptPreview(
                              settings: settings,
                              labels: labels,
                              style: style,
                              items: items,
                              total: total,
                              vatInfo: vatInfo,
                              paymentMethod: paymentMethod,
                              amountReceived: amountReceived,
                              changeAmount: changeAmount,
                              note: note,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Close button (same style as ImageViewerDialog)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
