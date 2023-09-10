import 'package:flutter/material.dart';
import 'package:otp/otp.dart';

import '../entities/code.dart';
import '../widgets/color.dart';
import '../i18n.dart';

class CodeEditor extends StatefulWidget {
  final Code? base;

  const CodeEditor({this.base, super.key});

  @override
  State<CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _accountController = TextEditingController();
  final _secretController = TextEditingController();
  final _durationController = TextEditingController(text: "30");
  int _length = 6;
  Algorithm _algorithm = Algorithm.SHA1;
  bool _compatibleWithGoogle = true;
  Color _color = Colors.deepPurple;

  @override
  void initState() {
    super.initState();

    if (widget.base != null) {
      Code base = widget.base!;

      _nameController.value = TextEditingValue(text: base.name);
      _secretController.value = TextEditingValue(text: base.secret);
      if (base.account != null) {
        _accountController.value = TextEditingValue(text: base.account!);
      }
      _durationController.value =
          TextEditingValue(text: base.duration.toString());
      _length = base.length;
      _algorithm = base.algorithm;
      _compatibleWithGoogle = base.compatibleWithGoogle;
      _color = base.color;
    }
  }

  @override
  Widget build(BuildContext context) {
    const padding = SizedBox(height: 16);

    return Scaffold(
      appBar: AppBar(
        title: Text("editor.title".i18n()),
        actions: [
          IconButton(
            onPressed: _done,
            icon: const Icon(Icons.done),
            tooltip: "editor.done".i18n(),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: "editor.name".i18n(),
                icon: const Icon(Icons.abc),
              ),
              controller: _nameController,
              validator: _emptyValidator,
            ),
            padding,
            TextFormField(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: "editor.account".i18n(),
                icon: const Icon(Icons.person),
              ),
              controller: _accountController,
            ),
            padding,
            TextFormField(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: "editor.secret".i18n(),
                icon: const Icon(Icons.lock),
              ),
              controller: _secretController,
              validator: _emptyValidator,
            ),
            padding,
            TextFormField(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: "editor.duration".i18n(),
                icon: const Icon(Icons.access_time),
              ),
              controller: _durationController,
              validator: _numberValidator,
            ),
            padding,
            Row(
              children: [
                Icon(Icons.account_tree,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 16),
                Flexible(
                  child: DropdownButtonFormField(
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: "editor.length".i18n(),
                    ),
                    value: _length,
                    items: [6, 7, 8]
                        .map((n) =>
                            DropdownMenuItem(value: n, child: Text("$n")))
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        _length = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: DropdownButtonFormField(
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: "editor.algo".i18n(),
                    ),
                    value: _algorithm,
                    items: Algorithm.values
                        .map((n) =>
                            DropdownMenuItem(value: n, child: Text(n.name)))
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        // _length = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            padding,
            ColorListTile(
              onChange: (color) {
                debugPrint("$color");
                setState(() {
                  _color = color;
                });
              },
              title: Text("editor.color".i18n()),
              value: _color,
              leading: const Icon(Icons.color_lens),
              contentPadding: const EdgeInsetsDirectional.only(end: 16),
            ),
            padding,
            SwitchListTile(
              title: Text("editor.googleCompat".i18n()),
              subtitle: Text("editor.googleCompatDesc".i18n()),
              secondary: const Icon(Icons.balcony),
              contentPadding: const EdgeInsetsDirectional.only(end: 16),
              value: _compatibleWithGoogle,
              onChanged: (value) {
                setState(() {
                  _compatibleWithGoogle = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  _done() {
    assert(_formKey.currentState != null);

    if (_formKey.currentState!.validate()) {
      Navigator.pop(
        context,
        Code(
          name: _nameController.text,
          secret: _secretController.text,
          duration: int.parse(_durationController.text),
          length: _length,
          compatibleWithGoogle: _compatibleWithGoogle,
          algorithm: _algorithm,
          color: _color,
          account:
              _accountController.text.isEmpty ? null : _accountController.text,
        ),
      );
      return;
    }
  }

  String? _emptyValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "errors.empty".i18n();
    }

    return null;
  }

  String? _numberValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "errors.empty".i18n();
    }

    final intValue = int.tryParse(value);
    if (!RegExp(r'^-?\d+$').hasMatch(value.trim()) || intValue == null) {
      return "errors.nan".i18n();
    }

    if (intValue < 0) {
      return "errors.negative".i18n();
    }

    return null;
  }
}
