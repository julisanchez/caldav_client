import 'package:caldav_client/src/multistatus/element.dart';
import 'package:caldav_client/src/multistatus/multistatus.dart';
import 'package:test/test.dart';

void main() {
  group('CalDav response test', () {
    final responseString = '''
    <?xml version="1.0"?>
<d:multistatus xmlns:d="DAV:" xmlns:s="http://sabredav.org/ns" xmlns:cal="urn:ietf:params:xml:ns:caldav" xmlns:cs="http://calendarserver.org/ns/" xmlns:card="urn:ietf:params:xml:ns:carddav">
    <d:response>
        <d:href>/dav.php/calendars/juli/default/</d:href>
        <d:propstat>
            <d:prop>
                <d:resourcetype>
                    <d:collection/>
                    <cal:calendar/>
                    <cs:shared-owner/>
                </d:resourcetype>
                <d:displayname>Default calendar</d:displayname>
                <cs:getctag>http://sabre.io/ns/sync/3</cs:getctag>
                <d:sync-token>http://sabre.io/ns/sync/3</d:sync-token>
                <cal:supported-calendar-component-set>
                    <cal:comp name="VEVENT"/>
                    <cal:comp name="VTODO"/>
                </cal:supported-calendar-component-set>
            </d:prop>
            <d:status>HTTP/1.1 200 OK</d:status>
        </d:propstat>
    </d:response>
    <d:response>
        <d:href>/dav.php/calendars/juli/inbox/</d:href>
        <d:propstat>
            <d:prop>
                <d:resourcetype>
                    <d:collection/>
                    <cal:schedule-inbox/>
                </d:resourcetype>
            </d:prop>
            <d:status>HTTP/1.1 200 OK</d:status>
        </d:propstat>
    </d:response>
</d:multistatus>
    ''';

    late MultiStatus multistatus;

    setUp(() {
      multistatus = MultiStatus.fromString(responseString);
    });

    test('Multistatus', () {
      expect(multistatus.response.length, 2);
      expect(multistatus.syncToken, null);
    });

    test('Response 0', () {
      final response = multistatus.response[0];

      expect(response.href, '/dav.php/calendars/juli/default/');
    });

    test('Response 0 - Propstat', () {
      final propstat = multistatus.response[0].propstat;

      expect(propstat.prop.length, 5);
      expect(propstat.status, 200);

      expect(propstat.prop['displayname'], 'Default calendar');
      expect(propstat.prop['getctag'], 'http://sabre.io/ns/sync/3');
    });

    test('resourcetype', () {
      final elements = (multistatus.response[0].propstat.prop['resourcetype']
          as List<Element>);

      expect(elements.length, 3);
      expect(elements[2].name, 'shared-owner');
    });

    test('supported-calendar-component-set',(){
       final elements =
          (multistatus.response[0].propstat.prop['supported-calendar-component-set'] as List<Element>);

      expect(elements[1].name, 'comp');
      expect(elements[1].atributes['name'], 'VTODO');
    });
  });
}
