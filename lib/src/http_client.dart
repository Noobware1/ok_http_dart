import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart';
import 'package:ok_http_dart/ok_http_dart.dart';
import 'package:ok_http_dart/src/extenstions/http_client_extenstion.dart';

class SSLClient implements Client {
  final ignoreSSLClient = HttpClient()
    ..badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);

  @override
  void close() {}

  @override
  Future<Response> delete(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return _send('DELETE', url, headers: headers, body: body);
  }

  @override
  Future<Response> get(Uri url, {Map<String, String>? headers}) {
    return _send('GET', url, headers: headers);
  }

  @override
  Future<Response> head(Uri url, {Map<String, String>? headers}) {
    return _send('HEAD', url, headers: headers);
  }

  @override
  Future<Response> patch(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return _send('PATCH', url, body: body, headers: headers);
  }

  @override
  Future<Response> post(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return _send('POST', url, headers: headers, body: body);
  }

  @override
  Future<Response> put(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    return _send('PUT', url, headers: headers, body: body);
  }

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) async {
    final response = await get(url, headers: headers);
    _checkResponseSuccess(url, response);
    return response.body;
  }

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) async {
    final response = await get(url, headers: headers);
    _checkResponseSuccess(url, response);
    return response.bodyBytes;
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final req = await _readRequest(request);
    req.fromOkHttpRequest(request as OKHttpRequest);
    final res = await req.close();
    return _readResponse(res, request);
  }

  Future<Response> _send(
    String method,
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final request = OKHttpRequest(method, url);
    if (headers != null) {
      request.addHeaders(headers);
    }
    if (body != null) {
      request.addBody(body);
    }
    print(request.body);
    return Response.fromStream(await send(request));
  }

  StreamedResponse _readResponse(
      HttpClientResponse response, BaseRequest request) {
    final headers = <String, String>{};
    response.headers.forEach((key, value) => headers[key] = value.join(','));

    return StreamedResponse(
      response.asBroadcastStream(),
      response.statusCode,
      persistentConnection: response.persistentConnection,
      isRedirect: response.isRedirect,
      headers: headers,
      reasonPhrase: null,
      request: request,
    );
  }

  Future<HttpClientRequest> _readRequest(BaseRequest request) {
    final url = request.url;
    switch (request.method) {
      case 'GET':
        return ignoreSSLClient.getUrl(url);
      case 'POST':
        return ignoreSSLClient.postUrl(url);
      case 'PUT':
        return ignoreSSLClient.patchUrl(url);
      case 'PATCH':
        return ignoreSSLClient.patchUrl(url);
      case 'HEAD':
        return ignoreSSLClient.headUrl(url);
      case 'DELETE':
        return ignoreSSLClient.deleteUrl(url);
      default:
        throw StateError(
            '[Invaild Request]: Cannot identify the request method');
    }
  }



  void _checkResponseSuccess(Uri url, Response response) {
    if (response.statusCode < 400) return;
    var message = 'Request to $url failed with status ${response.statusCode}';
    if (response.reasonPhrase != null) {
      message = '$message: ${response.reasonPhrase}';
    }
    throw ClientException('$message.', url);
  }


}
