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

A wrapper for dart http package for easier usage mainly for webscraping and personal use

## Features

webscraping tools
json parsing using your custom fromJson method

## Getting started

add this line to your pubspec.yaml file in the root of your project.
```
lol
```

## Usage

create a OkHttpClient Instance

```dart
final OkHttpClient client = OkHttpClient();
```

now you can make request using that instance

```dart

void main(List<String> args) async {
  final request =
      await client.get('https://jsonplaceholder.typicode.com/posts');

  print(request.text);
}
```

## Additional information

TODO: ye
