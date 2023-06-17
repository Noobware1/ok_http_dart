import 'package:http/http.dart';

class OKHttpRequest extends Request {
  OKHttpRequest(super.method, super.url);

  ///add headers to the request
  void addHeaders(Map<String, String>? headers) {
    if (headers != null) this.headers.addAll(headers);
  }

  ///add any body to the request
  void addBody(Object? body) {
    if (body != null) {
      if (body is String) {
        this.body = body;
      } else if (body is List) {
        bodyBytes = body.cast<int>();
      } else if (body is Map) {
        bodyFields = body.cast<String, String>();
      } else {
        throw ArgumentError('Invalid request body "$body".');
      }
    }
  }
}
