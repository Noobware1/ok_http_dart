import 'dart:io';
import 'package:http/http.dart';
import 'package:http/io_client.dart';

class InsecureClient extends BaseClient {
  Client? _inner;

  InsecureClient([Client? inner])
      : _inner = inner ??
            IOClient(HttpClient()
              ..badCertificateCallback =
                  ((X509Certificate cert, String host, int port) => true));

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    if (_inner == null) {
      throw ClientException(
          'HTTP request failed. Client is already closed.', request.url);
    }
    return _inner!.send(request);
  }

  @override
  void close() {
    if (_inner != null) {
      _inner!.close();
      _inner = null;
    }
  }
}


