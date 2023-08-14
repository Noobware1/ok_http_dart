import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:ok_http_dart/http.dart';
import 'package:ok_http_dart/ok_http_dart.dart';

//Copied From Dio
Future<OkHttpResponse> downloader({
  required http.Client client,
  String? method,
  String? url,
  required File file,
  Duration? timeout,
  String? referer,
  void Function(int recevied, int total)? onReceiveProgress,
  Map<String, dynamic>? params,
  bool deleteOnError = true,
  Map<String, String>? headers,
  Object? body,
  OKHttpRequest? request,
}) async {
  if (url == null && request == null) {
    throw ArgumentError(
        'The url for the request is null, pass a url to the download function or pass in a request object to fix the error');
  }
  try {
    final req = request ??
        OKHttpRequest.builder(
          method: method ?? 'GET',
          url: url!,
          body: body,
          headers: headers,
          params: params,
          referer: referer,
        );
    final response = await client.send(req);

    file.createSync(recursive: true);

    RandomAccessFile raf = file.openSync(mode: FileMode.write);

    final completer = Completer<OkHttpResponse>();
    var bytesCompleter = Completer<Uint8List>();

    // final sink = <int>[];
    var sink = ByteConversionSink.withCallback(
        (bytes) => bytesCompleter.complete(Uint8List.fromList(bytes)));
    // stream.listen(sink.add,
    // );
    // return completer.future;

    int received = 0;

    final stream = response.stream;

    final total =
        int.parse(response.headers['content-length']?.toString() ?? '-1');

    Future<void>? asyncWrite;
    bool closed = false;
    Future<void> closeAndDelete() async {
      if (!closed) {
        closed = true;
        await asyncWrite;
        await raf.close();
        if (deleteOnError && file.existsSync()) {
          await file.delete();
        }
      }
    }

    late StreamSubscription subscription;
    // final Stopwatch watch = Stopwatch()..start();

    subscription = stream.listen(
      (data) {
        sink.add(data);

        subscription.pause();
        // Write file asynchronously
        asyncWrite = raf.writeFrom(Uint8List.fromList(data)).then((result) {
          // Notify progress
          received += data.length;
          onReceiveProgress?.call(received, total);
          raf = result;
          subscription.resume();
        }).catchError((Object e) async {
          try {
            await subscription.cancel();
          } finally {
            completer.completeError(
              http.ClientException(e.toString(), req.url),
            );
          }
        });
      },
      onDone: () async {
        try {
          await asyncWrite;
          closed = true;
          await raf.close();
          sink.close();
          // bytesCompleter.complete(Uint8List.fromList(sink));
          completer.complete(OkHttpResponse.bytes(
              await bytesCompleter.future, response.statusCode,
              headers: response.headers,
              isRedirect: response.isRedirect,
              persistentConnection: response.persistentConnection,
              reasonPhrase: response.reasonPhrase,
              request: response.request));
        } catch (e) {
          completer.completeError(
            http.ClientException(e.toString(), req.url),
          );
        }
      },
      onError: (e) async {
        try {
          await closeAndDelete();
        } finally {
          bytesCompleter.completeError(e);
          completer.completeError(
            http.ClientException(e.toString(), req.url),
          );
        }
      },
      cancelOnError: true,
    );

    final future = completer.future;

    if (timeout != null) {
      try {
        return future.timeout(timeout);
      } on TimeoutException {
        throw TimeoutException(
            'Download cloud not be completed in the give time limit');
      }
    }

    return future;
  } catch (_) {
    throw http.ClientException(_.toString());
  }
}

