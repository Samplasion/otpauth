import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otpauth/utils.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../entities/code.dart';
import '../i18n.dart';

class ShareCode extends StatefulWidget {
  final Code code;

  const ShareCode({required this.code, super.key});

  @override
  State<ShareCode> createState() => _ShareCodeState();
}

class _ShareCodeState extends State<ShareCode> {
  bool isBW = false;

  @override
  Widget build(BuildContext context) {
    final code = widget.code;
    final uri = code.generateUri();
    // final scheme = Theme.of(context).colorScheme;
    final background = getSecondaryContainerColor(context, code.color);
    final foreground = getOnSecondaryContainerColor(context, code.color);

    return Scaffold(
      appBar: AppBar(title: Text("share.title".i18n())),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 256 + 48,
                    maxHeight: 256 + 48,
                  ),
                  child: GestureDetector(
                    onTap: () => setState(() => isBW = !isBW),
                    child: QrImageView(
                      padding: const EdgeInsets.all(16),
                      data: uri.toString(),
                      backgroundColor: isBW ? Colors.white : background,
                      eyeStyle: QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: isBW ? Colors.black : foreground,
                      ),
                      dataModuleStyle: QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: isBW ? Colors.black : foreground,
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                code.name,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              if (code.account != null)
                Text(
                  code.account!,
                  textAlign: TextAlign.center,
                ),
              const Spacer(),
              OutlinedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: uri.toString()))
                      .then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("copied.uri".i18n()),
                      behavior: SnackBarBehavior.floating,
                    ));
                  });
                },
                child: Text("share.copyUri".i18n()),
              ),
              const Spacer(),
              Text(
                "share.qrInfo".i18n(),
                style: Theme.of(context).textTheme.labelSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
