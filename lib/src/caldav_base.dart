import 'dart:io';

import 'package:caldav_client/src/cal_response.dart';
import 'package:caldav_client/src/utils.dart';

class CalDavBase {
  final HttpClient client;
  final String baseUrl;
  final Map<String, dynamic>? headers;

  CalDavBase({
    required this.baseUrl,
    this.headers,
    Duration? connectionTimeout,
  }) : client = HttpClient() {
    client.connectionTimeout = connectionTimeout;
  }

  /// Allows the client to fetch properties from a url.
  Future<CalResponse> propfind(String path, dynamic body,
      {int? depth, Map<String, dynamic>? headers}) async {
    var uri = _fullUri(path);
    var request = await client.openUrl('PROPFIND', Uri.parse(uri));

    // headers
    request.headers.contentType =
        ContentType('application', 'xml', charset: 'utf-8');

    var temp = <String, dynamic>{
      'Prefer': 'return-minimal',
      HttpHeaders.acceptCharsetHeader: 'utf-8',
      if (depth != null) 'Depth': depth,
      ...?headers,
      ...?this.headers
    };

    temp.forEach((key, value) {
      request.headers.add(key, value);
    });

    request.write(body);

    var response = await request.close();

    return convertResponse(response, uri);
  }

  /// REPORT performs a search for all calendar object resources that match a
  /// specified filter. The response of this report will contain all the WebDAV
  /// properties and calendar object resource data specified in the request.
  Future<CalResponse> report(String path, dynamic body,
      {int? depth, Map<String, dynamic>? headers}) async {
    var uri = _fullUri(path);
    var request = await client.openUrl('REPORT', Uri.parse(uri));

    // headers
    request.headers.contentType =
        ContentType('application', 'xml', charset: 'utf-8');

    var temp = <String, dynamic>{
      HttpHeaders.acceptHeader: 'application/xml,text/xml',
      HttpHeaders.acceptCharsetHeader: 'utf-8',
      if (depth != null) 'Depth': depth,
      ...?headers,
      ...?this.headers
    };

    temp.forEach((key, value) {
      request.headers.add(key, value);
    });

    request.write(body);

    var response = await request.close();

    return convertResponse(response, uri);
  }

  /// Fetch the contents for the object
  Future<CalResponse> downloadIcs(String path, String savePath,
      {Map<String, dynamic>? headers}) async {
    var uri = _fullUri(path);
    var request = await client.getUrl(Uri.parse(uri));

    var temp = <String, dynamic>{...?headers, ...?this.headers};

    temp.forEach((key, value) {
      request.headers.add(key, value);
    });

    var response = await request.close();
    await response.pipe(File(savePath).openWrite());

    return convertResponse(response, uri);
  }

  /// Update calendar ifMatch the etag
  Future<CalResponse> updateCal(String path, String etag, dynamic calendar,
      {Map<String, dynamic>? headers}) async {
    var uri = _fullUri(path);
    var request = await client.putUrl(Uri.parse(uri));

    request.headers.contentType =
        ContentType('text', 'calendar', charset: 'utf-8');

    var temp = <String, dynamic>{
      'If-Match': '"$etag"',
      ...?headers,
      ...?this.headers
    };

    temp.forEach((key, value) {
      request.headers.add(key, value);
    });

    request.write(calendar);

    var response = await request.close();

    return convertResponse(response, uri);
  }

  /// Create calendar
  Future<CalResponse> createCal(String path, dynamic calendar,
      {Map<String, dynamic>? headers}) async {
    var uri = _fullUri(path);

    var request = await client.putUrl(Uri.parse(uri));

    request.headers.contentType =
        ContentType('text', 'calendar', charset: 'utf-8');

    var temp = <String, dynamic>{...?headers, ...?this.headers};

    temp.forEach((key, value) {
      request.headers.add(key, value);
    });

    request.write(calendar);

    var response = await request.close();

    return convertResponse(response, uri);
  }

  /// Delete calendar
  Future<CalResponse> deleteCal(String path, String etag,
      {Map<String, dynamic>? headers}) async {
    var uri = _fullUri(path);
    var request = await client.deleteUrl(Uri.parse(uri));

    var temp = <String, dynamic>{
      'If-Match': '"$etag"',
      ...?headers,
      ...?this.headers
    };

    temp.forEach((key, value) {
      request.headers.add(key, value);
    });

    var response = await request.close();

    return convertResponse(response, uri);
  }

  String _fullUri(String path) {
    return join(baseUrl, path);
  }
}
