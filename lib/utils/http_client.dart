import 'package:http/http.dart' as http;

class SharedHttpClient {
  static final SharedHttpClient _instance = SharedHttpClient._internal();
  final http.Client client = http.Client();

  factory SharedHttpClient() {
    return _instance;
  }

  SharedHttpClient._internal();

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) {
    return client.get(url, headers: headers);
  }

  Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body}) {
    return client.post(url, headers: headers, body: body);
  }

  Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body}) {
    return client.put(url, headers: headers, body: body);
  }

  Future<http.Response> delete(Uri url, {Map<String, String>? headers, Object? body}) {
    return client.delete(url, headers: headers, body: body);
  }
}
