import 'package:caldav_client/src/authorization.dart';
import 'package:caldav_client/src/caldav_client.dart';
import 'package:test/test.dart';
import 'package:xml/xml.dart';

void main() {
  group('A group of tests', () {
    late CalDavClient client;
    final url = 'https://192.168.64.2/';
    //final url = 'https://1998f2fb-f92e-4f04-a6aa-e6afde7cfc7b.mock.pstmn.io';
    final username = 'juli';
    final password = '1234';

    setUp(() {
      client = CalDavClient(
          baseUrl: url,
          headers: Authorization(username, password).basic());
    });

    test('Initial Sync', () async {
      var result = await client.initialSync('/dav.php/calendars/juli', depth: 1);

      print(result);
      var document = result.body;
      var rootTag = document!.rootElement.name.toString().split(':');
      var rootName = rootTag.length == 1 ? rootTag[0] : rootTag[1];

      expect(rootName, 'multistatus');
      expect(document.rootElement.children.length, isNot(equals(0)));
    });

    test('Get Objects', () async {
      var result =
          await client.getObjects('/dav.php/calendars/juli/default/', depth: 1);

      var document = result.body;

      print(result);
      expect(
          document!.rootElement.name.toString().contains('multistatus'), true);
      expect(document.rootElement.children.indexWhere((child) {
        if (child is XmlElement) {
          return child.name.toString().contains('response');
        }
        return false;
      }), isNot(equals(-1)));
    });

    test('Get Changes', () async {
      var result =
          await client.getChanges('/dav.php/calendars/juli/default/', depth: 1);

      var document = result.body;

      print(result);

      expect(
          document!.rootElement.name.toString().contains('multistatus'), true);
      expect(document.rootElement.children.length, isNot(equals(0)));
      expect(
          document.rootElement.children.indexWhere((child) =>
              child.document!.rootElement.name.toString().contains('response')),
          isNot(equals(-1)));
    });

    test('Download Object', () async {
      var result = await client.downloadIcs('/dav.php/calendars/juli/default/test.ics', './1.ics');

      //print(result.request.headers);
      print(result);
    });

    test('Multiget', () async {
      var files = ['calendar.ics', 'test.ics'];

      var result = await client.multiget('/dav.php/calendars/juli/default/', files);
      print(result.body);

      var document = result.body;
      expect(
          document!.rootElement.name.toString().contains('multistatus'), true);
      expect(document.rootElement.children.length, isNot(equals(0)));
    });

    test('Create Calendar', () async {
      var calendar = '''
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//PYVOBJECT//NONSGML Version 1//EN
BEGIN:VEVENT
UID:test@example.com
DTSTART;VALUE=DATE:20190306
CLASS:PRIVATE
DESCRIPTION:Arman and Adrian released their SRT-file parser library for Dar
 t
DTSTAMP;X-VOBJ-FLOATINGTIME-ALLOWED=TRUE:20190306T000000
LOCATION:Heilbronn
PRIORITY:0
RRULE:FREQ=YEARLY
STATUS:CONFIRMED
SUMMARY:SRT-file Parser Release
URL:https://pub.dartlang.org/packages/srt_parser
END:VEVENT
END:VCALENDAR''';

      var result = await client.createCal(
          '/dav.php/calendars/juli/default/123.ics', calendar);

      print(result);

      expect(result.statusCode, 201);
    });

    test('Update Calendar', () async {
      var calendar = '''
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//PYVOBJECT//NONSGML Version 1//EN
BEGIN:VEVENT
UID:test@example.com
DTSTART;VALUE=DATE:20190306
CLASS:PRIVATE
DESCRIPTION: Hellooo :)
DTSTAMP;X-VOBJ-FLOATINGTIME-ALLOWED=TRUE:20190306T000000
LOCATION:Heilbronn
PRIORITY:0
RRULE:FREQ=YEARLY
STATUS:CONFIRMED
SUMMARY:SRT-file Parser Release
URL:https://pub.dartlang.org/packages/srt_parser
END:VEVENT
END:VCALENDAR''';

      var result = await client.updateCal('/dav.php/calendars/juli/default/test.ics', '4a8d9170f72c7e3327b85fda0ea2f7b0', calendar);

      print(result);
      expect(result.statusCode, 204);
    });

    test('Delete Calendar', () async {
      var result = await client.deleteCal('/dav.php/calendars/juli/default/calendar.ics', '4a8d9170f72c7e3327b85fda0ea2f7b0');
      print(result);
    });
  });
}
