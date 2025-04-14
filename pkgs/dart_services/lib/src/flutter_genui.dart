// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:dartpad_shared/model.dart' as api;
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

final _logger = Logger('genui');

class _GenuiEnv {
  late final Uri? apiUrl;
  final String name;

  _GenuiEnv({
    required this.name,
    required String apiKeyVarName,
    required String url,
  }) {
    final key = Platform.environment[apiKeyVarName] ?? '';
    if (key.isEmpty) {
      _logger.warning(
        '$apiKeyVarName not set; genui features at $name DISABLED',
      );
      apiUrl = null;
    } else {
      _logger.info('$apiKeyVarName set; genui features at $name ENABLED');
      apiUrl = Uri.parse('$url?key=$key');
    }
  }

  /// Request code generation from GenUI.
  ///
  /// Returns the generated Flutter code.
  ///
  /// If not enabled or fails, logs error and returns null.
  Future<api.GenerateUiResponse> request({required String prompt}) async {
    final uri = apiUrl;
    if (uri == null) {
      throw InvalidGenUiPayloadException(
        'Genui features at $name are disabled',
      );
    }

    final response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'userPrompt': prompt}),
    );

    if (response.statusCode != 200) {
      throw InvalidGenUiPayloadException(
        'Failed to generate ui at genui, $name: ${response.statusCode}, ${response.body}',
      );
    }

    return decodeResponse(response.body);
  }
}

class InvalidGenUiPayloadException implements Exception {
  final String message;
  InvalidGenUiPayloadException(this.message);

  @override
  String toString() => 'InvalidGenUiPayloadException: $message';
}

api.GenerateUiResponse decodeResponse(String response) {
  try {
    final decoded = jsonDecode(response) as Map<String, dynamic>;
    final flutterCode = decoded['flutterCode'];
    // ignore: avoid_dynamic_calls
    final compiledJsCode = decoded['payload']?['ddc']?['compiledJsCode'];

    if (flutterCode is! String || compiledJsCode is! String) {
      throw InvalidGenUiPayloadException(
        'flutter code or compiled JavaScript code missing from the response',
      );
    }

    return api.GenerateUiResponse(
      flutterCode: flutterCode,
      compiledJsCode: compiledJsCode,
    );
  } catch (e, stackTrace) {
    throw InvalidGenUiPayloadException(
      'Error parsing GenUI response: $e\n$stackTrace',
    );
  }
}

class GenUi {
  late final _GenuiEnv _prodGenui, _stagingGenui;

  GenUi() {
    _prodGenui = _GenuiEnv(
      name: 'prod',
      apiKeyVarName: 'GENUI_API_KEY',
      url:
          'https://devgenui.pa.googleapis.com/v1internal/firstparty/generateidecode',
    );

    _stagingGenui = _GenuiEnv(
      name: 'staging',
      apiKeyVarName: 'GENUI_API_KEY_STAGING',
      url:
          'https://staging-devgenui.sandbox.googleapis.com/v1internal/firstparty/generateidecode',
    );
  }

  Future<api.GenerateUiResponse> generateCode({required String prompt}) async {
    try {
      final prodResult = await _prodGenui.request(prompt: prompt);
      return prodResult;
    } catch (e) {
      _logger.warning(
        'Failed to generate code from GenUI production: $e. Falling back to staging service',
      );
    }

    try {
      final stagingResult = await _stagingGenui.request(prompt: prompt);
      return stagingResult;
    } catch (e) {
      _logger.warning('Failed to generate code from GenUI: $e');
      rethrow;
    }
  }
}
