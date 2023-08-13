<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

A wrapper for dart's http package.
Mainly for easier and personal usage and to provide extra functionality to the package.

## Features

webscraping like request and beautiful soup
json parsing using your custom fromJson method
download feature (copied from dio)
easy to use


## Getting started

create a OkHttpClient Instance

```dart
final OkHttpClient client = OkHttpClient();
```

## Usage


now you can make requests using that instance

```dart
  final request =
      await client.get('https://jsonplaceholder.typicode.com/posts', headers: {'User-Agent':
	'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:101.0) Gecko/20100101 Firefox/101.0'});

  print(request.text);
  print(request.statusCode);
  print(request.success);
```

## Additional information

it still working progress bugs are excepted.
