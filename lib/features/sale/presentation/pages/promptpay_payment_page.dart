import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:promsell_pos_ce/core/utils/slip_verifier.dart';
import 'package:thai_promptpay/thai_promptpay.dart' as pp;
import 'package:promsell_pos_ce/l10n/app_localizations.dart';
import 'package:promsell_pos_ce/core/utils/sound_player.dart';
import 'package:promsell_pos_ce/core/widgets/money_text.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/slip_scanner_dialog.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/promptpay_qr_code.dart';
import 'package:share_plus/share_plus.dart';

class PromptPayPaymentPage extends StatefulWidget {
  const PromptPayPaymentPage({
    super.key,
    required this.total,
    required this.currency,
    required this.promptpayId,
    required this.settings,
    required this.bloc,
    required this.items,
  });

  final double total;
  final String currency;
  final String promptpayId;
  final Settings settings;
  final CheckoutBloc bloc;
  final List<CartItem> items;

  @override
  State<PromptPayPaymentPage> createState() => _PromptPayPaymentPageState();
}

class _PromptPayPaymentPageState extends State<PromptPayPaymentPage> {
  late int _remainingSeconds;
  Timer? _timer;
  final _referenceCtrl = TextEditingController();
  String? _sendingBankCode;
  bool _cartExpanded = false;
  Timer? _autoConfirmTimer;
  double _lastProgress = 1.0;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.settings.promptPayTimeout;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 0) {
        _timer?.cancel();
        if (mounted) {
          widget.bloc.add(const CheckoutPaymentCancelled());
        }
        return;
      }
      setState(() {
        _lastProgress = _remainingSeconds / widget.settings.promptPayTimeout;
        _remainingSeconds--;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _autoConfirmTimer?.cancel();
    _referenceCtrl.dispose();
    super.dispose();
  }

  String get _formattedTime {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _extendTime() {
    HapticFeedback.lightImpact();
    setState(() => _remainingSeconds += 60);
  }

  void _confirm() {
    HapticFeedback.mediumImpact();
    if (widget.settings.promptPaySoundEnabled) {
      SoundPlayer.playConfirmation();
    }
    _timer?.cancel();
    widget.bloc.add(
      CheckoutPaymentConfirmed(
        paymentReference: _referenceCtrl.text.trim(),
        sendingBankCode: _sendingBankCode,
      ),
    );
  }

  void _cancel() {
    HapticFeedback.mediumImpact();
    _timer?.cancel();
    widget.bloc.add(const CheckoutPaymentCancelled());
  }

  Future<void> _scanSlip() async {
    HapticFeedback.lightImpact();
    final result = await Navigator.of(context).push<SlipVerifyResult>(
      MaterialPageRoute(builder: (_) => const SlipScannerDialog()),
    );
    if (result == null || !mounted) return;

    if (result.isValid) {
      setState(() {
        _referenceCtrl.text = result.transRef ?? '';
        _sendingBankCode = result.sendingBankCode;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.verified,
                color: AppColors.overlayIcon,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${context.l10n.slipScanSuccess}${result.bankNameTh != null ? ' — ${result.bankNameTh}' : ''}',
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      if (widget.settings.autoConfirmAfterSlip) {
        _scheduleAutoConfirm();
      }
    } else {
      final theme = Theme.of(context);
      final isWrongQr = result.errorType == SlipErrorType.notASlipQr;
      final errorText = switch (result.errorType) {
        SlipErrorType.emptyPayload => context.l10n.slipErrorEmpty,
        SlipErrorType.notASlipQr => context.l10n.slipErrorNotASlip,
        SlipErrorType.unreadable => context.l10n.slipErrorUnreadable,
        null => result.errorMessage ?? context.l10n.promptpayInvalidQr,
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isWrongQr ? Icons.qr_code_scanner : Icons.error_outline,
                color: theme.colorScheme.onErrorContainer,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(errorText)),
            ],
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: theme.colorScheme.errorContainer,
        ),
      );
    }
  }

  void _scheduleAutoConfirm() {
    _autoConfirmTimer?.cancel();
    const delay = Duration(seconds: 2);
    final end = DateTime.now().add(delay);
    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: StreamBuilder<int>(
          stream: Stream.periodic(const Duration(milliseconds: 100), (_) {
            final remaining = end.difference(DateTime.now()).inMilliseconds;
            return (remaining / 1000).ceil().clamp(0, 2);
          }),
          builder: (context, snapshot) {
            final secs = snapshot.data ?? 2;
            return Text(l10n.autoConfirmingIn(secs));
          },
        ),
        duration: delay + const Duration(milliseconds: 500),
        action: SnackBarAction(
          label: l10n.cancel,
          onPressed: () {
            _autoConfirmTimer?.cancel();
          },
        ),
      ),
    );
    _autoConfirmTimer = Timer(delay, () {
      if (mounted) _confirm();
    });
  }

  void _shareQr() {
    HapticFeedback.lightImpact();
    final payload = buildPromptPayQrPayload(
      promptpayId: widget.promptpayId,
      amount: widget.total,
    );
    Share.share(
      '${widget.currency}${widget.total.toStringAsFixed(2)}\n$payload',
      subject: context.l10n.promptpay,
    );
  }

  void _showQrFullscreen(ThemeData theme, AppLocalizations l10n) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog.fullscreen(
        backgroundColor: AppColors.overlayBackground,
        child: SafeArea(
          child: GestureDetector(
            onTap: () => Navigator.of(ctx).pop(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(28),
                  child: PromptPayQrCode(
                    promptpayId: widget.promptpayId,
                    amount: widget.total,
                    size: 320,
                    overlayIcon: widget.settings.qrOverlayIcon,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '${widget.currency}${widget.total.toStringAsFixed(2)}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppColors.overlayIcon,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.promptpayId,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.overlayTextSecondary,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => Navigator.of(ctx).pop(),
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.overlayTextSecondary,
                  ),
                  label: Text(
                    l10n.cancel,
                    style: const TextStyle(
                      color: AppColors.overlayTextSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _cancel();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.promptpay),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: _extendTime,
              icon: const Icon(Icons.timer),
              tooltip: l10n.promptpayExtendTime,
            ),
            _buildTimerChip(theme),
          ],
        ),
        body: Column(
          children: [
            _buildTimerProgress(theme),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 720;
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                _buildCartSummary(theme, l10n),
                                const SizedBox(height: 20),
                                _buildStatusCard(theme, l10n),
                                const SizedBox(height: 20),
                                _buildReferenceInput(theme, l10n),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                _buildQrSection(theme, l10n),
                                const SizedBox(height: 20),
                                _buildActionsRow(theme, l10n),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildCartSummary(theme, l10n),
                        const SizedBox(height: 20),
                        _buildQrSection(theme, l10n),
                        const SizedBox(height: 20),
                        _buildActionsRow(theme, l10n),
                        const SizedBox(height: 20),
                        _buildStatusCard(theme, l10n),
                        const SizedBox(height: 20),
                        _buildReferenceInput(theme, l10n),
                        const SizedBox(height: 100),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        resizeToAvoidBottomInset: true,
        bottomNavigationBar: _buildStickyFooter(theme, l10n),
      ),
    );
  }

  Widget _buildTimerChip(ThemeData theme) {
    final isTimeout = _remainingSeconds <= 0;
    final isUrgent = _remainingSeconds <= 30 && _remainingSeconds > 0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isTimeout
            ? theme.colorScheme.error
            : isUrgent
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        _formattedTime,
        style: theme.textTheme.titleMedium?.copyWith(
          color: isTimeout
              ? theme.colorScheme.onError
              : isUrgent
              ? theme.colorScheme.error
              : theme.colorScheme.onPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTimerProgress(ThemeData theme) {
    final max = widget.settings.promptPayTimeout;
    final progress = (_remainingSeconds / max).clamp(0.0, 1.0);
    final isUrgent = _remainingSeconds <= 30;
    Color barColor;
    if (progress > 0.5) {
      barColor = theme.colorScheme.primary;
    } else if (progress > 0.2) {
      barColor = AppColors.warning;
    } else {
      barColor = theme.colorScheme.error;
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: _lastProgress, end: progress),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return LinearProgressIndicator(
          value: value,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(barColor),
          minHeight: isUrgent ? 6 : 4,
        );
      },
    );
  }

  Widget _buildCartSummary(ThemeData theme, AppLocalizations l10n) {
    final showCount = _cartExpanded ? widget.items.length : 5;
    final visibleItems = widget.items.take(showCount).toList();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  l10n.cart,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.items.length}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...visibleItems.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        item.product.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'x${item.qty}',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: MoneyText(
                        value: item.subtotal,
                        currency: widget.currency,
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (widget.items.length > 5)
              TextButton(
                onPressed: () => setState(() => _cartExpanded = !_cartExpanded),
                child: Text(_cartExpanded ? l10n.showLess : l10n.showMore),
              ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.total,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                MoneyText(
                  value: widget.total,
                  currency: widget.currency,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrSection(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _showQrFullscreen(theme, l10n),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Semantics(
                label:
                    'PromptPay QR code, ${widget.currency}${widget.total.toStringAsFixed(2)}',
                child: PromptPayQrCode(
                  promptpayId: widget.promptpayId,
                  amount: widget.total,
                  size: 240,
                  overlayIcon: widget.settings.qrOverlayIcon,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                widget.promptpayId,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.promptpayId));
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l10n.copyPromptpayId)));
                },
                icon: const Icon(Icons.copy, size: 18),
                tooltip: l10n.copyPromptpayId,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionsRow(ThemeData theme, AppLocalizations l10n) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        _ActionChip(
          icon: Icons.share,
          label: l10n.promptpayShareQr,
          onTap: _shareQr,
        ),
        _ActionChip(
          icon: Icons.document_scanner,
          label: l10n.slipScanTitle,
          onTap: _scanSlip,
        ),
      ],
    );
  }

  Widget _buildStatusCard(ThemeData theme, AppLocalizations l10n) {
    final hasBank = _sendingBankCode != null && _sendingBankCode!.isNotEmpty;
    final bankName = hasBank
        ? (pp.thaiBankByCode(_sendingBankCode!)?.nameTh ?? _sendingBankCode!)
        : null;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: hasBank
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
        ),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              hasBank ? Icons.verified : Icons.schedule,
              color: hasBank
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasBank
                    ? '${l10n.paymentVerified}${bankName != null ? ' — $bankName' : ''}'
                    : l10n.waitingForPayment,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: hasBank
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceInput(ThemeData theme, AppLocalizations l10n) {
    return TextField(
      controller: _referenceCtrl,
      onChanged: (v) {
        if (v.trim().isEmpty && _sendingBankCode != null) {
          setState(() => _sendingBankCode = null);
        }
      },
      decoration: InputDecoration(
        labelText: l10n.promptpayTransactionReference,
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        prefixIcon: const Icon(Icons.tag_outlined),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      textInputAction: TextInputAction.done,
      style: theme.textTheme.bodyLarge,
    );
  }

  Widget _buildStickyFooter(ThemeData theme, AppLocalizations l10n) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.95),
          border: Border(
            top: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: TextButton(onPressed: _cancel, child: Text(l10n.cancel)),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: FilledButton(
                onPressed: _confirm,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(l10n.promptpayConfirmPayment),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
