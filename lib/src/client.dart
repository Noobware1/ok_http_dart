import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ok_http_dart/src/http_client.dart';
import 'ok_http_response.dart';
import 'ok_http_request.dart';

class OKHttpClient {
  ///inner http client
  http.Client _client = http.Client();

  ///makes a get request to the given url

  Future<OkHttpResponse> get(String url,
      {Map<String, String>? headers, bool followRedircts = false}) {
    return request(
        url: url,
        method: 'GET',
        headers: headers,
        followRedircts: followRedircts);
  }

  ///makes a post request to the given url

  Future<OkHttpResponse> post(String url,
      {Map<String, String>? headers,
      Object? body,
      bool followRedircts = false}) {
    return request(
        url: url,
        method: 'POST',
        headers: headers,
        body: body,
        followRedircts: followRedircts);
  }

  ///makes a put request to the given url

  Future<OkHttpResponse> put(String url,
      {Map<String, String>? headers,
      Object? body,
      bool followRedircts = false}) {
    return request(
        url: url,
        method: 'PUT',
        headers: headers,
        body: body,
        followRedircts: followRedircts);
  }

  ///makes a head request to the given url

  Future<OkHttpResponse> head(String url,
      {Map<String, String>? headers, bool followRedircts = false}) {
    return request(
        url: url,
        method: 'HEAD',
        headers: headers,
        followRedircts: followRedircts);
  }

  ///makes a patch request to the given url

  Future<OkHttpResponse> patch(
    String url, {
    Map<String, String>? headers,
    Object? body,
    bool followRedircts = false,
  }) {
    return request(
        url: url,
        method: 'PATCH',
        headers: headers,
        body: body,
        followRedircts: followRedircts);
  }

  ///makes a delete request to the given url

  Future<OkHttpResponse> delete(String url,
      {Map<String, String>? headers,
      Object? body,
      bool followRedircts = false}) {
    return request(
        url: url,
        method: 'DELETE',
        headers: headers,
        body: body,
        followRedircts: followRedircts);
  }

  /// the underlying function that makes the above all the request possible takes in a [String] url and [String] request method and some optional params like headers or body used for the request. all exceptions are wrappped with [http.ClientException] and it retries requests whose status code is not equal to 200 upto 5 times.
  Future<OkHttpResponse> request(
      {required String url,
      required String method,
      Map<String, String>? headers,
      bool followRedircts = false,
      Object? body}) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      throw http.ClientException(
          'Cannot Parse the Given Url Please Check if the Given Url is Vaild URI = $url');
    }
    final request = OKHttpRequest(method, uri)
      ..addHeaders(headers)
      ..addBody(body)
      ..followRedirects = followRedircts;

    try {
      final response = await _client.send(request);
      return OkHttpResponse.fromStream(response);
    } on HttpException catch (_) {
      final response =
          await retryRequest(request: request.copyRequest(), client: _client);
      if (response.statusCode != 200) {
        throw http.ClientException(
            'Request Failed With Status Code ${response.statusCode}', uri);
      }
      return response;
    } on HandshakeException catch (_) {
      final response =
          await retryRequest(request: request.copyRequest(), client: _client);
      return response;
    } catch (e) {
      throw http.ClientException(e.toString(), uri);
    }
  }

  ///function to retry request upto 5 times whose status code is not equal to 200
  Future<OkHttpResponse> retryRequest(
      {required OKHttpRequest request,
      required http.Client client,
      int retries = 5}) async {
    http.StreamedResponse res = await client.send(request);
    if (res.statusCode != 200) {
      for (var i = 1; i < retries; i++) {
        if (res.statusCode == 200) {
          break;
        } else {
          continue;
        }
      }
    }
    return OkHttpResponse.fromStream(res);
  }

  void ignoreAllSSLError() {
    _client = SSLClient();
    return;
  }
}
