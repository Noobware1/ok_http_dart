import 'dart:convert';
import 'dart:typed_data';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
// import 'package:http/http.dart'
import 'package:http/http.dart';

class OkHttpResponse extends BaseResponse {
  ///Get response bytes
  final Uint8List bytes;
//final a = http.Response
  ///Get the response as a html document
  Document get document => parse(text);

  ///Get the encoding used for the response
  String get encoding => encodingForHeaders(headers).name;

  ///Get the the Reponse body as a String
  String get text => encodingForHeaders(headers).decode(bytes);

  ///See if the request was succesfull with statuscode 200
  bool get success => statusCode == 200 ? true : false;

  /// Creates a new OKHTTP response with a string body.
  OkHttpResponse(String body, int statusCode,
      {BaseRequest? request,
      Map<String, String> headers = const {},
      bool isRedirect = false,
      bool persistentConnection = true,
      String? reasonPhrase})
      : this.bytes(encodingForHeaders(headers).encode(body), statusCode,
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
  static Future<OkHttpResponse> fromStream(StreamedResponse response) async {
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
