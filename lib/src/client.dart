import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:ok_http_dart/src/download.dart';
import 'package:ok_http_dart/src/insecure_client.dart';
import 'package:ok_http_dart/src/session.dart';
import 'ok_http_response.dart';
import 'ok_http_request.dart';

class OkHttpClient {
  Future<OkHttpResponse> get(
    String url, {
    Map<String, String>? headers,
    bool? followRedirects,
    String? referer,
    String? cookie,
    Map<String, dynamic>? params,
    bool? verify,
    bool? retry,
  }) {
    return _request(
        url: url,
        method: 'GET',
        headers: headers,
        cookie: cookie,
        params: params,
        referer: referer,
        followRedirects: followRedirects);
  }

  ///makes a post request to the given url

  Future<OkHttpResponse> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
    bool? followRedirects,
    String? referer,
    String? cookie,
    Map<String, dynamic>? params,
    bool? verify,
    bool? retry,
  }) {
    return _request(
        url: url,
        method: 'POST',
        cookie: cookie,
        headers: headers,
        body: body,
        params: params,
        referer: referer,
        followRedirects: followRedirects);
  }

  ///makes a put request to the given url

  Future<OkHttpResponse> put(
    String url, {
    Map<String, String>? headers,
    Object? body,
    bool? followRedirects,
    String? referer,
    String? cookie,
    Map<String, dynamic>? params,
    bool? verify,
    bool? retry,
  }) {
    return _request(
        url: url,
        method: 'PUT',
        headers: headers,
        cookie: cookie,
        body: body,
        params: params,
        referer: referer,
        followRedirects: followRedirects);
  }

  ///makes a head request to the given url

  Future<OkHttpResponse> head(
    String url, {
    Map<String, String>? headers,
    bool? followRedirects,
    String? referer,
    String? cookie,
    Map<String, dynamic>? params,
    bool? verify,
    bool? retry,
  }) {
    return _request(
        url: url,
        method: 'HEAD',
        headers: headers,
        params: params,
        cookie: cookie,
        referer: referer,
        followRedirects: followRedirects);
  }

  ///makes a patch request to the given url

  Future<OkHttpResponse> patch(
    String url, {
    Map<String, String>? headers,
    Object? body,
    bool? followRedirects,
    String? referer,
    String? cookie,
    Map<String, dynamic>? params,
    bool? verify,
    bool? retry,
  }) {
    return _request(
        url: url,
        method: 'PATCH',
        headers: headers,
        body: body,
        cookie: cookie,
        params: params,
        referer: referer,
        followRedirects: followRedirects);
  }

  ///makes a delete request to the given url

  Future<OkHttpResponse> delete(
    String url, {
    Map<String, String>? headers,
    Object? body,
    bool? followRedirects,
    String? referer,
    String? cookie,
    Map<String, dynamic>? params,
    bool? verify,
    bool? retry,
  }) {
    return _request(
        url: url,
        method: 'DELETE',
        headers: headers,
        body: body,
        cookie: cookie,
        params: params,
        referer: referer,
        followRedirects: followRedirects);
  }

  Future<OkHttpResponse> request(OKHttpRequest request) async {
    final client = createClient(request.verify, request.retry);
    final stream = await client.send(request);
    final response = await OkHttpResponse.fromStream(stream);
    client.close();
    return response;
  }

  Future<OkHttpResponse> _request({
    required String url,
    required String method,
    Map<String, String>? headers,
    bool? followRedirects,
    String? cookie,
    String? referer,
    Map<String, dynamic>? params,
    bool? verify,
    bool? retry,
    Object? body,
  }) async {
    final request = OKHttpRequest.builder(
      method: method,
      url: url,
      body: body,
      cookie: cookie,
      followRedirects: followRedirects,
      headers: headers,
      params: params,
      referer: referer,
      verify: verify,
      retry: retry,
    );
    return this.request(request);
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

  http.Client createClient([bool verify = true, bool retry = false]) {
    final client = !verify ? InsecureClient() : http.Client();
    if (retry) {
      return RetryClient(client);
    }
    return client;
  }
}
