// import 'package:test/test.dart';
// import 'package:ok_http/ok_http.dart';

// void main() {
//   group('OKHttpClient', () {
//     // late http.Client mockClient;
//     late OKHttpClient okHttpClient;

//     setUp(() {
//       // mockClient = MockClient((http.Request request) async {
//       //   // Mock the response based on the request
//       //   final response = http.Response('Mocked Response', 200);
//       //   return response;
//       // });

//       okHttpClient = OKHttpClient();
//     });

//     test('GET request', () async {
//       final response = await okHttpClient.get('https://example.com');
      
//       // Assert the response
//       expect(response.statusCode, 200);
//       expect(response.text, 'Mocked Response');
//     });

//     test('POST request', () async {
//       final response = await okHttpClient.post(
//         'https://example.com',
//         body: {'key': 'value'},
//       );

//       // Assert the response
//       expect(response.statusCode, 200);
//       expect(response.text, 'Mocked Response');
//     });

//     // Add more tests for other HTTP methods...

//   });
// }