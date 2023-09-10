import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

import 'dialog.dart';

/// A [SettingsTile] that allows the user to select a color.
///
/// The color is saved to the shared preferences using the provided key.
class ColorListTile extends StatefulWidget {
  final Widget title;
  final Widget? subtitle;
  final Color value;
  final ValueChanged<Color> onChange;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? leading;

  const ColorListTile({
    Key? key,
    required this.onChange,
    this.subtitle,
    required this.title,
    required this.value,
    this.contentPadding,
    this.leading,
  }) : super(key: key);

  @override
  State<ColorListTile> createState() => _ColorListTileState();
}

class _ColorListTileState extends State<ColorListTile> {
  late Color _color;

  @override
  void initState() {
    super.initState();
    _color = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    final matLoc = MaterialLocalizations.of(context);

    return ListTile(
      title: widget.title,
      subtitle: widget.subtitle ??
          Text("#${_color.value.toRadixString(16).substring(2).toUpperCase()}"),
      leading: widget.leading,
      trailing: CircleAvatar(backgroundColor: _color),
      contentPadding: widget.contentPadding,
      onTap: () {
        Color oldColor = _color;
        showDialogSuper<bool>(
          context: context,
          barrierDismissible: true,
          onDismissed: (val) {
            if (val == null || !val) {
              setState(() {
                _color = oldColor;
              });
            }
          },
          barrierColor: Theme.of(context).colorScheme.scrim.withOpacity(0.54),
          builder: (context) {
            return AlertDialog(
              title: widget.title,
              content: SingleChildScrollView(
                child: MaterialColorPicker(
                  allowShades: false,
                  selectedColor: _color,
                  onMainColorChange: (color) {
                    if (color == null) return;

                    setState(() {
                      _color = color;
                    });
                  },
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(matLoc.cancelButtonLabel),
                  onPressed: () {
                    setState(() {
                      _color = oldColor;
                    });
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text(matLoc.okButtonLabel),
                  onPressed: () {
                    widget.onChange(_color);
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
