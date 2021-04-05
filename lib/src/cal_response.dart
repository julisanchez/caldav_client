import 'package:xml/xml.dart';

class CalResponse {
  final String url;
  final int statusCode;
  final Map<String, dynamic> headers;
  final XmlDocument? body;

  CalResponse(
      {required this.url,
      required this.statusCode,
      required this.headers,
      this.body});

  @override
  String toString() {
    var string = '';
    string += 'URL: $url\n';
    string += 'STATUS CODE: $statusCode\n';
    string += 'HEADERS:\n$headers\n';
    string += 'BODY:\n${body != null ? body!.toXmlString(pretty: true) : null}';

    return string;
  }
}
