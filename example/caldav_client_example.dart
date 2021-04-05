import 'package:caldav_client/caldav_client.dart';

void main() async {
  var client = CalDavClient(
      baseUrl: 'https://192.168.64.2/dav.php',
      headers: Authorization('juli', '1234').basic(),
      );

  print(await client.initialSync('/calendars/juli/'));

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

  client.createCal('/calendars/juli/default/example.ics', calendar);
}
