import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:otpauth/pages/editor.dart';
import 'package:otpauth/pages/scan.dart';
import 'package:otpauth/pages/share.dart';

import '../entities/code.dart';
import '../widgets/entry.dart';
import '../i18n.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  late final animationController = BottomSheet.createAnimationController(this);

  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box("settings").listenable(keys: ["viewStyle"]),
      builder: (context, box, _) {
        final isCompact = box.get("viewStyle") == "compact";
        return ValueListenableBuilder(
          valueListenable: Hive.box<Code>("codes").listenable(),
          builder: (context, box, _) {
            final codes = [...box.values];
            return Scaffold(
              appBar: _getAppBar(codes),
              body: ListView.builder(
                padding: isCompact ? null : const EdgeInsets.all(16),
                itemCount: codes.length,
                itemBuilder: (context, index) {
                  return Container(
                    child: CodeEntry(
                      code: codes[index],
                      compact: isCompact,
                      selected: selectedIndex == index,
                      onSelect: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                    ),
                  );
                },
              ),
              floatingActionButton: FloatingActionButton(
                tooltip: "newCode".i18n(),
                child: const Icon(Icons.add),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return BottomSheet(
                        showDragHandle: false,
                        enableDrag: true,
                        animationController: animationController,
                        onClosing: () {},
                        builder: (context) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    "newCode".i18n(),
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ListTile(
                                  leading: const Icon(Icons.edit),
                                  title: Text("new.fromScratch".i18n()),
                                  onTap: _newFromScratch,
                                ),
                                ListTile(
                                  leading: const Icon(Icons.public),
                                  title: Text("new.fromUri".i18n()),
                                  onTap: _newFromUri,
                                ),
                                ListTile(
                                  leading: const Icon(Icons.qr_code_2),
                                  title: Text("new.fromQR".i18n()),
                                  textColor: _qrIsSupported
                                      ? null
                                      : Theme.of(context).disabledColor,
                                  iconColor: _qrIsSupported
                                      ? null
                                      : Theme.of(context).disabledColor,
                                  onTap: _qrIsSupported ? _newFromQR : null,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  _getAppBar(List<Code> codes) {
    if (selectedIndex == null) {
      return AppBar(
        title: Text("app.title".i18n()),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.list),
            tooltip: "list.view.tooltip".i18n(),
            itemBuilder: (_) => [
              for (final style in ["cards", "compact"])
                PopupMenuItem(
                  child: Row(
                    children: [
                      Radio(
                        value: style,
                        groupValue: Hive.box("settings").get("viewStyle"),
                        onChanged: (_) {
                          Hive.box("settings").put("viewStyle", style);
                          Navigator.pop(context);
                        },
                      ),
                      Text("list.view.$style".i18n())
                    ],
                  ),
                  onTap: () {
                    Hive.box("settings").put("viewStyle", style);
                  },
                ),
            ],
          ),
        ],
      );
    }

    final code = codes[selectedIndex!];
    return AppBar(
      title: Text(code.name),
      leading: IconButton(
        icon: const Icon(Icons.done),
        tooltip: "unselect".i18n(),
        onPressed: () {
          setState(() => selectedIndex = null);
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          tooltip: "edit".i18n(),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return Dialog.fullscreen(
                  child: CodeEditor(base: code),
                );
              },
            ).then((possibleCode) {
              final code = possibleCode;
              if (code == null) return;

              Hive.box<Code>("codes").putAt(selectedIndex!, code);
              setState(() => selectedIndex = null);
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.qr_code_2),
          tooltip: "share.title".i18n(),
          onPressed: () {
            final code = codes[selectedIndex!];
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ShareCode(code: code)),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          tooltip: "delete".i18n(),
          onPressed: () {
            final idx = selectedIndex!;
            setState(() => selectedIndex = null);
            Hive.box<Code>("codes").deleteAt(idx);
          },
        ),
      ],
    );
  }

  _newFromScratch() {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) {
        return const Dialog.fullscreen(
          child: CodeEditor(),
        );
      },
    ).then((possibleCode) {
      final code = possibleCode;
      if (code == null) return;

      Hive.box<Code>("codes").add(code);
    });
  }

  _newFromUri() {
    Navigator.pop(context);
    showDialog<Code>(
      context: context,
      builder: (context) {
        return const FromUriDialog();
      },
    ).then(_editCode);
  }

  get _qrIsSupported => Platform.isAndroid || Platform.isIOS;

  _newFromQR() {
    Navigator.pop(context);
    Navigator.push<Code>(
      context,
      MaterialPageRoute(builder: (context) => const ScannerPage()),
    ).then(_editCode);
  }

  _editCode(Code? possibleCode) {
    final code = possibleCode;
    if (code == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog.fullscreen(
          child: CodeEditor(base: code),
        );
      },
    ).then((possibleCode) {
      final code = possibleCode;
      if (code == null) return;

      Hive.box<Code>("codes").add(code);
    });
  }
}

class FromUriDialog extends StatefulWidget {
  const FromUriDialog({
    super.key,
  });

  @override
  State<FromUriDialog> createState() => _FromUriDialogState();
}

class _FromUriDialogState extends State<FromUriDialog> {
  final _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final matLoc = MaterialLocalizations.of(context);

    return AlertDialog(
      title: Text("new.fromUri".i18n()),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _textController,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "errors.empty".i18n();
            }

            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(matLoc.cancelButtonLabel),
        ),
        TextButton(
          onPressed: () {
            assert(_formKey.currentState != null);

            if (_formKey.currentState!.validate()) {
              final uri = Uri.tryParse(_textController.text);
              if (uri == null) {
                _displayDialog(
                    context, "uri.notValid".i18n(), "uri.notAUri".i18n());
                return;
              }

              try {
                final code = parseQR(uri);
                Navigator.pop(context, code);
              } on Exception catch (e) {
                _displayDialog(context, "uri.notValid".i18n(), e.toString());
              }
            }
          },
          child: Text(matLoc.okButtonLabel),
        ),
      ],
    );
  }
}

_displayDialog(BuildContext context, String title, String subtitle) {
  final matLoc = MaterialLocalizations.of(context);
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(subtitle),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(matLoc.okButtonLabel),
        ),
      ],
    ),
  );
}
