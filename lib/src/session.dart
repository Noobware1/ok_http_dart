import 'package:ok_http_dart/ok_http_dart.dart';
import 'package:http/http.dart' as http;
import 'package:ok_http_dart/retry.dart';

http.Client _createClient(bool ignoreAllSSlError, bool retryRequest) {
  final client = ignoreAllSSlError ? InsecureClient() : http.Client();
  if (retryRequest) {
    return RetryClient(client);
  }
  return client;
}

http.ClientException _noClientError([Uri? url]) =>
    http.ClientException('HTTP request failed. Client is already closed.', url);

class OkHttpClientSession {
  bool _ignoreAllSSlError = false;
  bool _retryRequest = false;

  void ignoreAllSSLError(bool ignoreAllSSlError) =>
      _ignoreAllSSlError = ignoreAllSSlError;

  void retryRequest(bool retryRequest) => _retryRequest = retryRequest;

  http.Client? _client;
  OkHttpClientSession([http.Client? client]) {
    _client = client ?? _createClient(_ignoreAllSSlError, _retryRequest);
  }

  Future<OkHttpResponse> get(
    String url, {
    Map<String, String>? headers,
    bool? followRedircts,
    String? referer,
    Map<String, String>? params,
  }) {
    return request(
        url: url,
        method: 'GET',
        headers: headers,
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
    Map<String, String>? params,
  }) {
    return request(
        url: url,
        method: 'POST',
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
    Map<String, String>? params,
  }) {
    return request(
        url: url,
        method: 'PUT',
        headers: headers,
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
    Map<String, String>? params,
  }) {
    return request(
        url: url,
        method: 'HEAD',
        headers: headers,
        params: params,
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
    Map<String, String>? params,
  }) {
    return request(
        url: url,
        method: 'PATCH',
        headers: headers,
        body: body,
        params: params,
        referer: referer,
        followRedircts: followRedircts);
  }

  ///makes a delete request to the given url

  Future<OkHttpResponse> delete(
    String url, {
    Map<String, String>? headers,
    Object? body,
    String? referer,
    Map<String, String>? params,
    bool? followRedircts,
  }) {
    return request(
        url: url,
        method: 'DELETE',
        headers: headers,
        body: body,
        params: params,
        referer: referer,
        followRedircts: followRedircts);
  }

  Future<OkHttpResponse> request({
    required String url,
    required String method,
    Map<String, String>? headers,
    bool? followRedircts,
    String? referer,
    Map<String, String>? params,
    Object? body,
  }) async {
    final oKHttpRequest = OKHttpRequest.builder(
        method: method,
        url: url,
        body: body,
        followRedirects: followRedircts,
        headers: headers,
        params: params,
        referer: referer);
    final request = await send(oKHttpRequest);
    final OkHttpResponse response = await OkHttpResponse.fromStream(request);

    return response;
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
    return downloader(
        client: _client!,
        method: method,
        url: url,
        onReceiveProgress: onReceiveProgress,
        request: request,
        params: params,
        referer: referer,
        savePath: savePath,
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
