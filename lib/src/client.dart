import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ok_http/src/ok_http_response.dart';
import 'ok_http_request.dart';

class OKHttpBaseClient extends http.BaseClient {
  final Object? body;
  final Map<String, String>? headers;
  final http.Client _client;

  OKHttpBaseClient(
    this._client,
    this.headers,
    this.body,
  );

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    final baseRequest = request as OKHttpRequest;
    baseRequest.addHeaders(headers);
    baseRequest.addBody(body);

    return _client.send(baseRequest);
  }
}

class OKHttpClient {
  ///inner http client
  final _client = http.Client();

  ///makes a get request to the given url

  Future<OkHttpResponse> get(String url, {Map<String, String>? headers}) {
    return request(url: url, method: 'GET', headers: headers);
  }

  ///makes a post request to the given url

  Future<OkHttpResponse> post(String url,
      {Map<String, String>? headers, Object? body}) {
    return request(url: url, method: 'POST', headers: headers, body: body);
  }

  ///makes a put request to the given url

  Future<OkHttpResponse> put(String url,
      {Map<String, String>? headers, Object? body}) {
    return request(url: url, method: 'PUT', headers: headers, body: body);
  }

  ///makes a head request to the given url

  Future<OkHttpResponse> head(String url, {Map<String, String>? headers}) {
    return request(url: url, method: 'HEAD', headers: headers);
  }

  ///makes a patch request to the given url

  Future<OkHttpResponse> patch(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return request(url: url, method: 'PATCH', headers: headers, body: body);
  }

  ///makes a delete request to the given url

  Future<OkHttpResponse> delete(String url,
      {Map<String, String>? headers, Object? body}) {
    return request(url: url, method: 'DELETE', headers: headers, body: body);
  }

  /// the underlying function that makes the above all the request possible takes in a [String] url and [String] request method and some optional params like headers or body used for the request. all exceptions are wrappped with [http.ClientException] and it retries requests whose status code is not equal to 200 upto 5 times.
  Future<OkHttpResponse> request(
      {required String url,
      required String method,
      Map<String, String>? headers,
      Object? body}) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      throw http.ClientException(
          'Cannot Parse the Given Url Please Check if the Given Url is Vaild URI = $url');
    }
    final request = OKHttpRequest(method, uri);

    try {
      final response =
          await OKHttpBaseClient(_client, headers, body).send(request);
      return OkHttpResponse.fromStream(response);
    } on HttpException catch (_) {
      final response = await retryRequest(
          request: request, client: OKHttpBaseClient(_client, headers, body));
      if (response.statusCode != 200) {
        throw http.ClientException(
            'Request Failed With Status Code ${response.statusCode}', uri);
      }
      return OkHttpResponse.fromStream(response);
    } on HandshakeException catch (_) {
      final response = await retryRequest(
          request: request, client: OKHttpBaseClient(_client, headers, body));
      return OkHttpResponse.fromStream(response);
    } catch (e) {
      throw http.ClientException(e.toString(), uri);
    }
  }


///function to retry request upto 5 times whose status code is not equal to 200
  Future<http.StreamedResponse> retryRequest(
      {required OKHttpRequest request,
      required OKHttpBaseClient client,
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
    return res;
  }
}
