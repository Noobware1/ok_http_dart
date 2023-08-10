class CookieJar {
  final List<String> _cookies;
  List<String> get cookies => _cookies;

  const CookieJar(List<String> cookies) : _cookies = cookies;

  void add(String cookie) {
    _cookies.add(cookie);
  }

  void remove(String cookie) {
    final int index = _cookies.indexOf(cookie);
    if (index != -1) {
      _cookies.removeAt(index);
    }
  }

  void clear() {
    _cookies.clear();
  }
}
