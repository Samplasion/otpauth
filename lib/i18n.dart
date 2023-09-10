import 'dart:convert';

import 'package:flat/flat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localization/colored_print/colored_print.dart';

class AppLocalJsonLocalization extends LocalizationsDelegate {
  List<String> directories = ['lib/i18n'];
  bool showDebugPrintMode = true;
  AppLocalJsonLocalization._();

  static final delegate = AppLocalJsonLocalization._();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<dynamic> load(Locale locale) async {
    AppLocalizationService.instance.showDebugPrintMode = showDebugPrintMode;
    await AppLocalizationService.instance.changeLanguage(locale, directories);
  }

  @override
  bool shouldReload(AppLocalJsonLocalization old) => false;
}

class AppLocalizationService {
  static AppLocalizationService? _instance;
  bool showDebugPrintMode = true;

  static AppLocalizationService get instance {
    _instance ??= AppLocalizationService();
    return _instance!;
  }

  final _sentences = <String, String>{};

  Future changeLanguage(Locale locale, List<String> directories) async {
    clearSentences();
    for (var directory in directories) {
      await _changeLanguage(locale, directory);
    }
  }

  Future _changeLanguage(Locale locale, String directory) async {
    late String data;
    final selectedLanguage = locale.toString();
    if (directory.endsWith('/')) {
      directory = directory.substring(0, directory.length - 1);
    }
    final jsonFile = '$directory/$selectedLanguage.json';

    data = await rootBundle.loadString(jsonFile);
    ColoredPrint.log('Loaded $jsonFile');

    late Map<String, dynamic> result;

    try {
      result = json.decode(data);
    } catch (e) {
      ColoredPrint.error(e.toString());
      result = {};
    }

    for (var entry in flatten(result).entries) {
      if (_sentences.containsKey(entry.key)) {
        ColoredPrint.warning('Duplicated Key: "${entry.key}" Path: "$locale"');
      }
      _sentences[entry.key] = entry.value.toString();
    }
  }

  void addSentence(String key, String value) {
    _sentences[key] = value;
  }

  String read(String key, List<String> arguments) {
    if (!_sentences.containsKey(key)) {
      return key;
    }
    var value = _sentences[key]!;
    if (value.contains('%s')) {
      return replaceArguments(value, arguments);
    }

    return value;
  }

  String replaceArguments(String value, List<String> arguments) {
    final regExp = RegExp(r'(\%s\d?)');
    final matchers = regExp.allMatches(value);
    var argsCount = 0;

    for (var matcher in matchers) {
      for (var i = 1; i <= matcher.groupCount; i++) {
        final finded = matcher.group(i);
        if (finded == null) {
          continue;
        }

        if (finded == '%s') {
          value = value.replaceFirst('%s', arguments[argsCount]);
          argsCount++;
          continue;
        }

        var extractedId = int.tryParse(finded.replaceFirst('%s', ''));
        if (extractedId == null) {
          continue;
        }

        if (extractedId >= arguments.length) {
          continue;
        }

        value = value.replaceFirst(finded, arguments[extractedId]);
      }
    }

    return value;
  }

  void clearSentences() {
    _sentences.clear();
  }
}

extension LocalizationExtension on String {
  String i18n([List<String> arguments = const []]) {
    return AppLocalizationService.instance.read(this, arguments);
  }
}
