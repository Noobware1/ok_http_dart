import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:ok_http_dart/src/download.dart';
import 'package:ok_http_dart/src/insecure_client.dart';
import 'package:ok_http_dart/src/session.dart';
import 'ok_http_response.dart';
import 'ok_http_request.dart';

class OKHttpClient {
  bool _ignoreAllSSlError = false;
  bool _retryRequest = false;

  void ignoreAllSSLError(bool ignoreAllSSlError) =>
      _ignoreAllSSlError = ignoreAllSSlError;

  void retryRequest(bool retryRequest) => _retryRequest = retryRequest;

  Future<OkHttpResponse> get(
    String url, {
    Map<String, String>? headers,
    bool? followRedircts,
    String? referer,
    String? cookie,
    Map<String, dynamic>? params,
  }) {
    return request(
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
    String? cookie,
    bool? followRedircts,
    String? referer,
    Map<String, dynamic>? params,
  }) {
    return request(
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
    String? cookie,
    bool? followRedircts,
    String? referer,
    Map<String, dynamic>? params,
  }) {
    return request(
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
    String? cookie,
    bool? followRedircts,
    String? referer,
    Map<String, dynamic>? params,
  }) {
    return request(
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
    String? cookie,
    bool? followRedircts,
    String? referer,
    Map<String, dynamic>? params,
  }) {
    return request(
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
    String? cookie,
    String? referer,
    Map<String, dynamic>? params,
    bool? followRedircts,
  }) {
    return request(
        url: url,
        method: 'DELETE',
        headers: headers,
        body: body,
        cookie: cookie,
        params: params,
        referer: referer,
        followRedircts: followRedircts);
  }

  Future<OkHttpResponse> request({
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
        referer: referer);

    final client = createClient();
    final stream = await send(client, request);
    final response = await OkHttpResponse.fromStream(stream);
    client.close();
    return response;
  }

  Future<http.StreamedResponse> send(
      http.Client client, OKHttpRequest request) {
    return client.send(request);
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
  }) async {
    final client = createClient();
    final file = File(savePath);
    final downloaded = await downloader(
        client: client,
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
    client.close();
    return downloaded;
  }

  OkHttpClientSession session() => OkHttpClientSession(createClient());

  http.Client createClient() {
    final client = _ignoreAllSSlError ? InsecureClient() : http.Client();
    if (_retryRequest) {
      return RetryClient(client);
    }
    return client;
  }
}
