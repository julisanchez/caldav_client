import 'dart:convert';
import 'dart:io';

import 'package:caldav_client/src/cal_response.dart';
import 'package:xml/xml.dart';

String trim(String str, [String? chars]) {
  var pattern =
      (chars != null) ? RegExp('^[$chars]+|[$chars]+\$') : RegExp(r'^\s+|\s+$');
  return str.replaceAll(pattern, '');
}

String ltrim(String str, [String? chars]) {
  var pattern = chars != null ? RegExp('^[$chars]+') : RegExp(r'^\s+');
  return str.replaceAll(pattern, '');
}

String rtrim(String str, [String? chars]) {
  var pattern = chars != null ? RegExp('[$chars]+\$') : RegExp(r'\s+$');
  return str.replaceAll(pattern, '');
}

String join(String path0, String path1) {
  return rtrim(path0, '/') + '/' + ltrim(path1, '/');
}

Future<CalResponse> convertResponse(
    HttpClientResponse response, String url) async {
  var headers = <String, dynamic>{};

  response.headers.forEach((name, values) {
    headers[name] = values.length == 1 ? values[0] : values;
  });

  var body = await response.transform(Utf8Decoder()).join();

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
      body: document);
}

