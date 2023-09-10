import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:otp/otp.dart';

enum Type { totp, hotp }

class Code {
  String name;
  String? account;
  Color color;
  String secret;
  int duration;
  int length;
  bool compatibleWithGoogle;
  Algorithm algorithm;

  Code({
    required this.name,
    required this.color,
    required this.secret,
    required this.duration,
    required this.length,
    required this.compatibleWithGoogle,
    required this.algorithm,
    this.account,
  });

  String now() => OTP.generateTOTPCodeString(
        secret,
        DateTime.now().millisecondsSinceEpoch,
        isGoogle: compatibleWithGoogle,
        algorithm: Algorithm.SHA1,
        interval: duration,
        length: length,
      );

  String formatCode(String code) => switch (length) {
        6 => "${code.substring(0, 3)} ${code.substring(3)}",
        7 =>
          "${code.substring(0, 1)} ${code.substring(1, 4)} ${code.substring(4)}",
        8 => "${code.substring(0, 4)} ${code.substring(4)}",
        _ => throw RangeError.range(length, 6, 8),
      };

  Uri generateUri() => Uri(
        scheme: "otpauth",
        host: Type.totp.name.toLowerCase(),
        pathSegments: [
          [name, if (account != null) account].join(":")
        ],
        queryParameters: {
          "secret": secret,
          "issuer": name,
          "algorithm": algorithm.name,
          "digits": length.toString(),
          "period": duration.toString(),
        },
      );
}

class CodeAdapter extends TypeAdapter<Code> {
  @override
  final typeId = 0;

  @override
  Code read(BinaryReader reader) {
    final name = reader.readString();
    final color = Color(reader.readInt());
    final secret = reader.readString();
    final duration = reader.readInt();
    final length = reader.readInt();
    final compatibleWithGoogle = reader.readBool();
    final algorithm = _deserializeAlgorithm(reader.readString());
    final account = reader.readBool() ? reader.readString() : null;
    return Code(
      name: name,
      color: color,
      secret: secret,
      duration: duration,
      length: length,
      compatibleWithGoogle: compatibleWithGoogle,
      algorithm: algorithm,
      account: account,
    );
  }

  @override
  void write(BinaryWriter writer, Code obj) {
    writer.writeString(obj.name);
    writer.writeInt(obj.color.value);
    writer.writeString(obj.secret);
    writer.writeInt(obj.duration);
    writer.writeInt(obj.length);
    writer.writeBool(obj.compatibleWithGoogle);
    writer.writeString(obj.algorithm.serialized);
    writer.writeBool(obj.account != null);
    if (obj.account != null) writer.writeString(obj.account!);
  }
}

extension _Serialization on Algorithm {
  get serialized => switch (this) {
        Algorithm.SHA1 => "SHA1",
        Algorithm.SHA256 => "SHA256",
        Algorithm.SHA512 => "SHA512",
      };
}

_deserializeAlgorithm(String serialized) => switch (serialized.toUpperCase()) {
      "SHA1" => Algorithm.SHA1,
      "SHA256" => Algorithm.SHA256,
      "SHA512" => Algorithm.SHA512,
      _ =>
        throw RangeError("$serialized must be one of (SHA1, SHA256, SHA512).")
    };

Code parseQR(Uri uri, {Color color = Colors.deepPurple}) {
  if (uri.scheme != "otpauth") {
    throw Exception("The URI scheme must be otpauth");
  }
  if (!["totp", "hotp"].contains(uri.host)) {
    throw Exception("The URI host must be one of (totp, hotp)");
  }

  if (!uri.queryParameters.containsKey("secret")) {
    throw Exception("The secret query parameter is required");
  }

  // TODO: Support HOTP
  if (uri.path == "hotp") throw Exception("HOTP is not currently supported.");

  if (uri.path == "hotp" && !uri.queryParameters.containsKey("counter")) {
    throw Exception("The counter query parameter is required for HOTP codes");
  }

  final params = uri.queryParameters;

  final secret = params["secret"]!;

  final path = Uri.decodeComponent(uri.path.substring(1));
  final parts = path.split(":");
  final account = parts.length > 1 ? parts[1] : null;
  final name = params["issuer"] ??
      (uri.hasEmptyPath ? DateTime.now().toIso8601String() : parts.first)
          .trim();
  final algorithm = _deserializeAlgorithm(params["algorithm"] ?? "SHA1");
  final digits = int.tryParse(params['digits'] ?? "6") ?? 6;
  final interval = int.tryParse(params['period'] ?? "30") ?? 30;

  return Code(
    name: name,
    secret: secret,
    color: color,
    duration: interval,
    length: digits,
    algorithm: algorithm,
    compatibleWithGoogle: true,
    account: account,
  );
}
