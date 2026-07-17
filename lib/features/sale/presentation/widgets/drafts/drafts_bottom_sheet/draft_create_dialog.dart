import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/safe_text_controller.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

class DraftCreateDialog {
  DraftCreateDialog._();

  /// null = cancel; empty string = untitled; else trimmed name.
  static Future<String?> show(BuildContext context, AppLocalizations l10n) {
    return showDialog<String>(
      context: context,
      builder: (_) => _DraftCreateDialogBody(
        title: l10n.newDraft,
        hint: l10n.draftNameHint,
        cancelLabel: l10n.cancel,
        saveLabel: l10n.save,
      ),
    );
  }
}

class _DraftCreateDialogBody extends StatefulWidget {
  const _DraftCreateDialogBody({
    required this.title,
    required this.hint,
    required this.cancelLabel,
    required this.saveLabel,
  });

  final String title;
  final String hint;
  final String cancelLabel;
  final String saveLabel;

  @override
  State<_DraftCreateDialogBody> createState() => _DraftCreateDialogBodyState();
}

class _DraftCreateDialogBodyState extends State<_DraftCreateDialogBody> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
  }

  @override
  void dispose() {
    disposeTextEditingControllerAfterFrame(_ctrl);
    super.dispose();
  }

  void _pop([String? value]) {
    unfocusForDialogClose();
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        decoration: InputDecoration(hintText: widget.hint),
        onSubmitted: (_) => _pop(_ctrl.text.trim()),
      ),
      actions: [
        TextButton(onPressed: () => _pop(), child: Text(widget.cancelLabel)),
        FilledButton(
          onPressed: () => _pop(_ctrl.text.trim()),
          child: Text(widget.saveLabel),
        ),
      ],
    );
  }
}
