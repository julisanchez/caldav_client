import 'package:caldav_client/src/cal_response.dart';
import 'caldav_base.dart';
import 'utils.dart';

class CalDavClient extends CalDavBase {
  CalDavClient(
      {required String baseUrl,
      Duration? connectionTimeout,
      Map<String, dynamic>? headers})
      : super(
            baseUrl: baseUrl,
            connectionTimeout: connectionTimeout,
            headers: headers);

  /// Get the display name and the ctag.
  /// This ctag works like a change id.
  /// Every time the ctag has changed, you know something in the calendar has changed too.
  Future<CalResponse> initialSync(String path,
      {int? depth, bool syncToken = true}) {
    var syncTokenTag = '\n<d:sync-token />';
    var body = '''
    <d:propfind xmlns:d="DAV:" xmlns:cs="http://calendarserver.org/ns/">
      <d:prop>
      <d:displayname />
      <cs:getctag />${syncToken ? syncTokenTag : ''}
      </d:prop>
    </d:propfind>
    ''';

    return propfind(path, body, depth: depth);
  }

  /// This request will give us every object that's a VCALENDAR object, and its etag.
  Future<CalResponse> getObjects(String path, {int? depth}) {
    var body = '''
    <c:calendar-query xmlns:d="DAV:" xmlns:c="urn:ietf:params:xml:ns:caldav">
    <d:prop>
        <d:getetag />
        <c:calendar-data />
    </d:prop>
    <c:filter>
        <c:comp-filter name="VCALENDAR" />
    </c:filter>
    </c:calendar-query>
    ''';

    return report(path, body, depth: depth);
  }

  /// Request the ctag again on the calendar. If the ctag did not change, you still
  /// have the latest copy.
  /// If it did change, you must request all the etags in the entire calendar again.
  Future<CalResponse> getChanges(String path, {int? depth}) {
    var body = '''
    <c:calendar-query xmlns:d="DAV:" xmlns:c="urn:ietf:params:xml:ns:caldav">
      <d:prop>
        <d:getetag />
      </d:prop>
      <c:filter>
        <c:comp-filter name="VCALENDAR" />
      </c:filter>
    </c:calendar-query>
    ''';

    return report(path, body, depth: depth);
  }

  /// calendar-multiget REPORT is used to retrieve specific calendar object resources
  /// from within a collection, if the Request- URI is a collection, or to retrieve
  /// a specific calendar object resource, if the Request-URI is a calendar object
  /// resource.
  Future<CalResponse> multiget(String path, List<String> files, {int? depth}) {
    var links = '';

    files.forEach((file) {
      links += '<d:href>' + join(path, file) + '</d:href>\n';
    });

    var body = '''
    <c:calendar-multiget xmlns:d="DAV:" xmlns:c="urn:ietf:params:xml:ns:caldav">
      <d:prop>
        <d:getetag />
        <c:calendar-data />
      </d:prop>
      ''' +
        links +
        '''
    </c:calendar-multiget>
    ''';

    return report(path, body, depth: depth);
  }
}
