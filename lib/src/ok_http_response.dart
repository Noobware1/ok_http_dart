import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http_parser/http_parser.dart';

import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart';

class OkHttpResponse extends BaseResponse {
  /// The bytes comprising the body of this response.
  final Uint8List bodyBytes;

  // CookieJar get cookies => _cookies;

  // static const CookieJar _cookies = CookieJar([]);

  String get cookie => headers['set-cookie'] ?? headers['cookie'] ?? '';

  ///Get the response as a html document
  Document get document => parse(text);

  Encoding get encoding => _encodingForHeaders(headers);

  /// The body of the response as a string.
  ///
  /// This is converted from [bodyBytes] using the `charset` parameter of the
  /// `Content-Type` header field, if available. If it's unavailable or if the
  /// encoding name is unknown, [latin1] is used by default, as per
  /// [RFC 2616][].
  ///
  /// [RFC 2616]: http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html
  String get text => _encodingForHeaders(headers).decode(bodyBytes);

  ///See if the request was succesfull with statuscode 200
  bool get success => statusCode == 200 ? true : false;

  /// Creates a new HTTP response with a string body.
  OkHttpResponse(String body, int statusCode,
      {BaseRequest? request,
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

  /// Create a new HTTP response with a byte array body.
  OkHttpResponse.bytes(List<int> bodyBytes, super.statusCode,
      {super.request,
      super.headers,
      super.isRedirect,
      super.persistentConnection,
      super.reasonPhrase})
      : bodyBytes = _toUint8List(bodyBytes),
        super(contentLength: bodyBytes.length);

  /// Creates a new HTTP response by waiting for the full body to become
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

  factory OkHttpResponse.fromResponse(Response response) {
    return OkHttpResponse(response.body, response.statusCode,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase,
        request: response.request);
  }

  static Future<OkHttpResponse> fromBytes(
      ByteStream stream, StreamedResponse response) async {
    final body = await stream.toBytes();
    return OkHttpResponse.bytes(body, response.statusCode,
        request: response.request,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase);
  }

  /// Get the Response as json or pass a fromJson method to parse it into a Dart Object
  T json<T>([T Function(dynamic json)? fromJson]) {
    final json = jsonDecode(text);
    if (fromJson != null) return fromJson.call(json);
    return json;
  }

  /// Get the Response as json or pass a fromJson method to parse it into a Dart Object but returns null if an Error Occurs
  T? jsonSafe<T>([T Function(dynamic json)? fromJson]) {
    try {
      final json = jsonDecode(text);
      if (fromJson != null) return fromJson.call(json);
      return json;
    } catch (_) {
      return null;
    }
  }
}

Uint8List _toUint8List(List<int> input) {
  if (input is Uint8List) return input;
  if (input is TypedData) {
    // TODO(nweiz): remove "as" when issue 11080 is fixed.
    return Uint8List.view((input as TypedData).buffer);
  }
  return Uint8List.fromList(input);
}

/// Returns the encoding to use for a response with the given headers.
///
/// Defaults to [latin1] if the headers don't specify a charset or if that
/// charset is unknown.
Encoding _encodingForHeaders(Map<String, String> headers) =>
    encodingForCharset(_contentTypeForHeaders(headers).parameters['charset']);

/// Returns the [MediaType] object for the given headers's content-type.
///
/// Defaults to `application/octet-stream`.
MediaType _contentTypeForHeaders(Map<String, String> headers) {
  var contentType = headers['content-type'];
  if (contentType != null) return MediaType.parse(contentType);
  return MediaType('application', 'octet-stream');
}

/// Returns the [Encoding] that corresponds to [charset].
///
/// Returns [fallback] if [charset] is null or if no [Encoding] was found that
/// corresponds to [charset].
Encoding encodingForCharset(String? charset, [Encoding fallback = latin1]) {
  if (charset == null) return fallback;
  return Encoding.getByName(charset) ?? fallback;
}


// Future<Uint8List> _toBytes(Stream<List<int>> stream) {
//   var completer = Completer<Uint8List>();
//   var sink = ByteConversionSink.withCallback(
//       (bytes) => completer.complete(Uint8List.fromList(bytes)));
//   stream.listen(sink.add,
//       onError: completer.completeError,
//       onDone: sink.close,
//       cancelOnError: true);
//   return completer.future;
// }


