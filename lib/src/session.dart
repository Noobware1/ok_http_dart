import 'dart:io';

import 'package:ok_http_dart/ok_http_dart.dart';
import 'package:http/http.dart' as http;

http.ClientException _noClientError([Uri? url]) =>
    http.ClientException('HTTP request failed. Client is already closed.', url);

class OkHttpClientSession {
  http.Client? _client;

  OkHttpClientSession([http.Client? client]) {
    _client = client;
  }

  Future<OkHttpResponse> get(
    String url, {
    Map<String, String>? headers,
    bool? followRedircts,
    String? referer,
    String? cookie,
    Map<String, dynamic>? params,
  }) {
    return _request(
        url: url,
        method: 'GET',
        headers: headers,
        cookie: cookie,
        params: params,
        referer: referer,
        followRedircts: followRedircts);
  }

  ///makes a post request to the given url

  Future<OkHttpResponse> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
    bool? followRedircts,
    String? referer,
    String? cookie,
    Map<String, dynamic>? params,
  }) {
    return _request(
        url: url,
        method: 'POST',
        cookie: cookie,
        headers: headers,
        body: body,
        params: params,
        referer: referer,
        followRedircts: followRedircts);
  }

  ///makes a put request to the given url

  Future<OkHttpResponse> put(
    String url, {
    Map<String, String>? headers,
    Object? body,
    bool? followRedircts,
    String? referer,
    String? cookie,
    Map<String, dynamic>? params,
  }) {
    return _request(
        url: url,
        method: 'PUT',
        headers: headers,
        cookie: cookie,
        body: body,
        params: params,
        referer: referer,
        followRedircts: followRedircts);
  }

  ///makes a head request to the given url

  Future<OkHttpResponse> head(
    String url, {
    Map<String, String>? headers,
    bool? followRedircts,
    String? referer,
    String? cookie,
    Map<String, dynamic>? params,
  }) {
    return _request(
        url: url,
        method: 'HEAD',
        headers: headers,
        params: params,
        cookie: cookie,
        referer: referer,
        followRedircts: followRedircts);
  }

  ///makes a patch request to the given url

  Future<OkHttpResponse> patch(
    String url, {
    Map<String, String>? headers,
    Object? body,
    bool? followRedircts,
    String? referer,
    String? cookie,
    Map<String, dynamic>? params,
  }) {
    return _request(
        url: url,
        method: 'PATCH',
        headers: headers,
        body: body,
        cookie: cookie,
        params: params,
        referer: referer,
        followRedircts: followRedircts);
  }

  ///makes a delete request to the given url

  Future<OkHttpResponse> delete(
    String url, {
    Map<String, String>? headers,
    Object? body,
    bool? followRedircts,
    String? referer,
    String? cookie,
    Map<String, dynamic>? params,
  }) {
    return _request(
      url: url,
      method: 'DELETE',
      headers: headers,
      body: body,
      cookie: cookie,
      params: params,
      referer: referer,
      followRedircts: followRedircts,
    );
  }

  Future<OkHttpResponse> request(OKHttpRequest request) async {
    if (_client == null) {
      throw _noClientError(request.url);
    }
    final stream = await _client!.send(request);
    final response = await OkHttpResponse.fromStream(stream);
    return response;
  }

  Future<OkHttpResponse> _request({
    required String url,
    required String method,
    Map<String, String>? headers,
    bool? followRedircts,
    String? cookie,
    String? referer,
    Map<String, dynamic>? params,
    Object? body,
  }) async {
    final request = OKHttpRequest.builder(
      method: method,
      url: url,
      body: body,
      cookie: cookie,
      followRedirects: followRedircts,
      headers: headers,
      params: params,
      referer: referer,
    );
    return this.request(request);
  }

  Future<http.StreamedResponse> send(OKHttpRequest request) {
    if (_client == null) {
      throw _noClientError(request.url);
    }
    return _client!.send(request);
  }

  Future<OkHttpResponse> download({
    String? method,
    String? url,
    required dynamic savePath,
    Duration? timeout,
    String? referer,
    void Function(int recevied, int total)? onReceiveProgress,
    Map<String, dynamic>? params,
    bool deleteOnError = true,
    Map<String, String>? headers,
    Object? body,
    OKHttpRequest? request,
  }) {
    if (_client == null) throw _noClientError();

    final file = File(savePath);

    return downloader(
        client: _client!,
        method: method,
        url: url,
        onReceiveProgress: onReceiveProgress,
        request: request,
        params: params,
        referer: referer,
        file: file,
        body: body,
        deleteOnError: deleteOnError,
        headers: headers,
        timeout: timeout);
  }

  void close() {
    if (_client != null) {
      _client!.close();
      _client == null;
    }
  }
}
