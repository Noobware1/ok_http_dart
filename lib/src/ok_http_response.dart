import 'dart:convert';
import 'dart:typed_data';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:http/src/utils.dart';
import 'package:http_parser/src/media_type.dart';

class OkHttpResponse extends http.BaseResponse {
  ///Get response bytes
  final Uint8List bytes;

  ///Get the response as a html document
  Document get document => parse(text);

  ///Get the encoding used for the response
  String get encoding => _encodingForHeaders(headers).name;

  ///Get the the Reponse body as a String
  String get text => _encodingForHeaders(headers).decode(bytes);

  ///See if the request was succesfull with statuscode 200
  bool get success => statusCode == 200 ? true : false;

  /// Creates a new OKHTTP response with a string body.
  OkHttpResponse(String body, int statusCode,
      {http.BaseRequest? request,
      Map<String, String> headers = const {},
      bool isRedirect = false,
      bool persistentConnection = true,
      String? reasonPhrase})
      : this.bytes(_encodingForHeaders(headers).encode(body), statusCode,
            request: request,
            headers: headers,
            isRedirect: isRedirect,
            persistentConnection: persistentConnection,
            reasonPhrase: reasonPhrase);

  /// Create a new OKHTTP response with a byte array body.
  OkHttpResponse.bytes(List<int> bytes, super.statusCode,
      {super.request,
      super.headers,
      super.isRedirect,
      super.persistentConnection,
      super.reasonPhrase})
      : bytes = Uint8List.fromList(bytes),
        super(contentLength: bytes.length);

  ///  Creates a new OKHTTP response by waiting for the full body to become
  /// available from a [StreamedResponse].
  static Future<OkHttpResponse> fromStream(
      http.StreamedResponse response) async {
    final body = await response.stream.toBytes();
    return OkHttpResponse.bytes(body, response.statusCode,
        request: response.request,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase);
  }

  /// Get the Response as json or pass a fromJson method to parse it into a Dart Object
  T json<T>([T Function(dynamic json)? fromJson]) {
    try {
      final json = jsonDecode(text);
      if (fromJson != null) return fromJson.call(json);
      return json;
    } catch (e) {
      rethrow;
    }
  }
}

Encoding _encodingForHeaders(Map<String, String> headers) =>
    encodingForCharset(_contentTypeForHeaders(headers).parameters['charset']);

MediaType _contentTypeForHeaders(Map<String, String> headers) {
  var contentType = headers['content-type'];
  if (contentType != null) return MediaType.parse(contentType);
  return MediaType('application', 'octet-stream');
}
