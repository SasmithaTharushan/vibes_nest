import 'package:material_ui/material_ui.dart';

/// A dialog that asks for one line of text and returns it (or null if
/// cancelled). It owns its controller, so the controller is only disposed
/// after the dialog's closing animation has finished.
Future<String?> showTextPrompt(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  String? message,
  String? label,
  String? hint,
  String initialValue = '',
  bool obscure = false,
  bool destructive = false,
  TextCapitalization capitalization = TextCapitalization.none,
}) =>
    showDialog<String>(
      context: context,
      builder: (_) => _TextPromptDialog(
        title: title,
        confirmLabel: confirmLabel,
        message: message,
        label: label,
        hint: hint,
        initialValue: initialValue,
        obscure: obscure,
        destructive: destructive,
        capitalization: capitalization,
      ),
    );

class _TextPromptDialog extends StatefulWidget {
  const _TextPromptDialog({
    required this.title,
    required this.confirmLabel,
    required this.initialValue,
    required this.obscure,
    required this.destructive,
    required this.capitalization,
    this.message,
    this.label,
    this.hint,
  });

  final String title;
  final String confirmLabel;
  final String? message;
  final String? label;
  final String? hint;
  final String initialValue;
  final bool obscure;
  final bool destructive;
  final TextCapitalization capitalization;

  @override
  State<_TextPromptDialog> createState() => _TextPromptDialogState();
}

class _TextPromptDialogState extends State<_TextPromptDialog> {
  late final _controller = TextEditingController(text: widget.initialValue);

  // Never trim passwords: spaces can be part of them.
  String _value(String v) => widget.obscure ? v : v.trim();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.message != null) ...[
            Text(widget.message!),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _controller,
            autofocus: true,
            obscureText: widget.obscure,
            textCapitalization: widget.capitalization,
            decoration: InputDecoration(
                labelText: widget.label, hintText: widget.hint),
            onSubmitted: (v) => Navigator.pop(context, _value(v)),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(
          style: widget.destructive
              ? FilledButton.styleFrom(backgroundColor: Colors.red)
              : null,
          onPressed: () => Navigator.pop(context, _value(_controller.text)),
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
