import 'dart:io';

import '../ok_http_request.dart';

extension HttpClientUtils on HttpClientRequest {
  void fromOkHttpRequest(OKHttpRequest request) {
    request.headers.forEach((key, value) => headers.add(key, value));
    _addBody(request);
    this
      ..followRedirects = request.followRedirects
      ..persistentConnection = request.persistentConnection;
    return;
  }

  void _addBody(OKHttpRequest request) {
    if (isValid(request) && request.body.isNotEmpty) {
      // final body = <String, String>{};?
      final entry =
          MapEntry('Content-Type', 'application/x-www-form-urlencoded');
      request.headers.add(entry);

      write(Uri(queryParameters: request.bodyFields).query);
    }
    return;
  }

  bool isValid(OKHttpRequest request) {
    if (request.method != 'GET' || request.method != 'HEAD') {
      return true;
    }
    return false;
  }
}

extension Utils<E, V> on Map<E, V> {
  void add(MapEntry<E, V> entry) {
    this[entry.key] = entry.value;
  }
}
