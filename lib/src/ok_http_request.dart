import 'package:http/http.dart';
import 'utils.dart';

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

  void addReferer(String? referer) {
    if (referer != null &&
        (headers['referer'] == null || headers['Referer'] == null)) {
      headers['Referer'] = referer;
    }
  }

  void addCookie(String? cookie) {
    if (cookie != null) {
      headers['Cookie'] = cookie;
    }
  }

  factory OKHttpRequest.builder({
    required String method,
    required String url,
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    String? cookie,
    Object? body,
    String? referer,
    bool? followRedirects,
  }) {
    final uri = addParams(url, params);
    return OKHttpRequest(method, uri)
      ..addBody(body)
      ..addHeaders(headers)
      ..addCookie(cookie)
      ..addReferer(referer)
      ..followRedirects = followRedirects ?? true;
  }

  OKHttpRequest cloneRequest() {
    final clone = OKHttpRequest(method, url)
      ..addHeaders(headers)
      ..addBody(body)
      ..followRedirects = followRedirects
      ..persistentConnection = persistentConnection;
    return clone;
  }
}
