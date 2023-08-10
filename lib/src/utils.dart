

Uri addParams(String uri, Map<String, dynamic>? params) {
  final old = Uri.parse(uri);
  if (params != null && params.isNotEmpty) {
    final String query;
    if (old.hasQuery) {
      query = _makeQuery(params, true);
    } else {
      query = _makeQuery(params, false);
    }
    return Uri.parse(old.toString() + query);
  }
  return old;
}

String _makeQuery(Map<String, dynamic> params, [bool hasQuery = false]) {
  String query = '';
  params.forEach((key, value) => query += '$key=${value.toString()}&');

  query = query.substring(0, query.length - 1);
  if (!hasQuery) {
    return '?$query';
  }
  return '&$query';
}
