import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
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

    int received = 0;

    final stream = response.stream.asBroadcastStream();

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

    subscription = stream.asyncMap((bytes) => Uint8List.fromList(bytes)).listen(
      (data) {
        subscription.pause();
        // Write file asynchronously
        asyncWrite = raf.writeFrom(data).then((result) {
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
          completer.complete(OkHttpResponse.fromBytes(stream, response));
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

