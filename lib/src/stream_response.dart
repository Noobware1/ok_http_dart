import 'package:http/http.dart' as http;
import 'package:ok_http_dart/http.dart';

class OkHttpStreamResponse extends BaseResponse {
  final http.ByteStream stream;

  /// Creates a new streaming response.
  ///
  /// [stream] is a broadcaststream stream.
  OkHttpStreamResponse(Stream<List<int>> stream, super.statusCode,
      {super.contentLength,
      super.request,
      super.headers,
      super.isRedirect,
      super.persistentConnection,
      super.reasonPhrase})
      : stream = _toByteStream(stream);
}

http.ByteStream _toByteStream(Stream<List<int>> stream) {
  if (stream is http.ByteStream) return stream;
  return http.ByteStream(stream.asBroadcastStream());
}
