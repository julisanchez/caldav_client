import 'dart:convert';
import 'dart:io';

import 'package:xml/xml.dart';
import 'package:caldav_client/src/multistatus/multistatus.dart';

class CalResponse {
  final String url;
  final int statusCode;
  final Map<String, dynamic> headers;
  final XmlDocument? document;
  final MultiStatus? multistatus;

  CalResponse(
      {required this.url,
      required this.statusCode,
      required this.headers,
      this.document})
      : multistatus = document != null ? MultiStatus.fromXml(document) : null;

  static Future<CalResponse> fromHttpResponse(
      HttpClientResponse response, String url) async {
    var headers = <String, dynamic>{};
    
    // set headers
    response.headers.forEach((name, values) {
      headers[name] = values.length == 1 ? values[0] : values;
    });
    
    var body = await utf8.decoder.bind(response).join();

    XmlDocument? document;

    try {
      document = XmlDocument.parse(body);
    } catch (e) {
      document = null;
    }

    return CalResponse(
        url: url,
        statusCode: response.statusCode,
        headers: headers,
        document: document);
  }

  @override
  String toString() {
    var string = '';
    string += 'URL: $url\n';
    string += 'STATUS CODE: $statusCode\n';
    string += 'HEADERS:\n$headers\n';
    string +=
        'BODY:\n${document != null ? document!.toXmlString(pretty: true) : null}';

    return string;
  }
}
