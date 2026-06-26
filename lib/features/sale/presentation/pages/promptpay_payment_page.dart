import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/sound_player.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/promptpay/promptpay_payment_page/promptpay_layout.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/promptpay/promptpay_payment_page/promptpay_slip_handler.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/promptpay/promptpay_payment_page/promptpay_sticky_footer.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/promptpay/timer_chip.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/promptpay/timer_progress_bar.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/promptpay_qr_code.dart'
    show buildPromptPayQrPayload;
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
    _autoConfirmTimer?.cancel();
    await PromptPaySlipHandler.scanSlip(
      context,
      settings: widget.settings,
      referenceCtrl: _referenceCtrl,
      onBankCodeChanged: (code) => setState(() => _sendingBankCode = code),
      onValidSlip: () {
        _autoConfirmTimer = PromptPaySlipHandler.scheduleAutoConfirm(
          context,
          _confirm,
        );
      },
    );
  }

  void _shareQr() {
    HapticFeedback.lightImpact();
    final payload = buildPromptPayQrPayload(
      promptpayId: widget.promptpayId,
      amount: widget.total,
    );
    SharePlus.instance.share(
      ShareParams(
        text: '${widget.currency}${widget.total.toStringAsFixed(2)}\n$payload',
        subject: context.l10n.promptpay,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            TimerChip(
              remainingSeconds: _remainingSeconds,
              formattedTime: _formattedTime,
            ),
          ],
        ),
        body: Column(
          children: [
            TimerProgressBar(
              remainingSeconds: _remainingSeconds,
              maxSeconds: widget.settings.promptPayTimeout,
              lastProgress: _lastProgress,
            ),
            Expanded(
              child: PromptPayLayout(
                l10n: l10n,
                theme: Theme.of(context),
                items: widget.items,
                total: widget.total,
                currency: widget.currency,
                promptpayId: widget.promptpayId,
                settings: widget.settings,
                cartExpanded: _cartExpanded,
                onToggleExpand: () =>
                    setState(() => _cartExpanded = !_cartExpanded),
                sendingBankCode: _sendingBankCode,
                referenceController: _referenceCtrl,
                onReferenceChanged: (v) {
                  if (v.trim().isEmpty && _sendingBankCode != null) {
                    setState(() => _sendingBankCode = null);
                  }
                },
                onShare: _shareQr,
                onScanSlip: _scanSlip,
              ),
            ),
          ],
        ),
        resizeToAvoidBottomInset: true,
        bottomNavigationBar: PromptPayStickyFooter(
          l10n: l10n,
          onCancel: _cancel,
          onConfirm: _confirm,
        ),
      ),
    );
  }
}
