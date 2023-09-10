import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otpauth/widgets/timer.dart';

import '../entities/code.dart';
import '../i18n.dart';
import '../utils.dart';

class CodeEntry extends StatefulWidget {
  final Code code;
  final bool selected;
  final VoidCallback onSelect;
  final bool compact;

  const CodeEntry({
    required this.code,
    this.selected = false,
    super.key,
    required this.onSelect,
    this.compact = true,
  });

  @override
  State<CodeEntry> createState() => _CodeEntryState();
}

class _CodeEntryState extends State<CodeEntry> {
  @override
  Widget build(BuildContext context) {
    final name = widget.code.name;
    const updateInterval = Duration(milliseconds: 250);

    Color back = getPrimaryColorHarmonized(
      context,
      widget.code.color,
    );
    Color fore = getOnPrimaryColorHarmonized(
      context,
      widget.code.color,
    );

    if (widget.selected) {
      (back, fore) = (fore, back);
    }

    final borderRadius = widget.compact ? 0.0 : 12.0;

    return Card(
      clipBehavior: Clip.hardEdge,
      color: widget.compact
          ? Theme.of(context).colorScheme.background
          : getSecondaryContainerColor(context, widget.code.color),
      elevation: widget.compact ? 0 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      margin: widget.compact ? EdgeInsets.zero : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: () {
          Clipboard.setData(ClipboardData(text: widget.code.now())).then((_) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("copied.code".i18n()),
              behavior: SnackBarBehavior.floating,
            ));
          });
        },
        onLongPress: widget.onSelect,
        child: TimerWidget(
          interval: updateInterval,
          builder: (context) {
            var secs = (DateTime.now().millisecondsSinceEpoch / 1000);
            final progress = 1 - ((secs / widget.code.duration) % 1);

            return Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: back,
                    foregroundColor: fore,
                    child: widget.selected
                        ? const Icon(Icons.done)
                        : Text(name.characters.first.toUpperCase()),
                  ),
                  title: Text(name),
                  subtitle: Text.rich(TextSpan(children: [
                    if (widget.code.account != null)
                      TextSpan(text: "${widget.code.account}\n"),
                    TextSpan(
                      text: widget.code.formatCode(widget.code.now()),
                      style: TextStyle(
                        fontSize: 14 * (widget.compact ? 1.2 : 1.6),
                      ),
                    ),
                  ])),
                ),
                TweenAnimationBuilder(
                  tween: Tween(begin: progress, end: progress),
                  duration: updateInterval,
                  builder: (context, progress, _) {
                    return LinearProgressIndicator(
                      value: progress,
                      color: getPrimaryColorHarmonized(
                        context,
                        widget.code.color,
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

extension Math on Duration {
  operator /(num other) {
    return Duration(microseconds: inMicroseconds ~/ other);
  }
}
