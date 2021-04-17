import 'package:caldav_client/caldav_client.dart';
import 'package:caldav_client/src/utils.dart';

void main() async {
  var client = CalDavClient(
    baseUrl: 'https://192.168.64.2/',
    headers: Authorization('juli', '1234').basic(),
  );

  // initialSync
  var initialSyncResult = await client.initialSync('/dav.php/calendars/juli/');

  var calendars = <String>[];

  // Print calendars and save calendars path
  for (var result in initialSyncResult.multistatus!.response) {
    print('PATH: ${result.href}');

    if (result.propstat.status == 200) {
      var displayname = result.propstat.prop['displayname'];
      var ctag = result.propstat.prop['getctag'];

      if (displayname != null && ctag != null) {
        print('CALENDAR: $displayname');
        print('CTAG: $ctag');

        calendars.add(result.href);
      } else {
        print('This collection is not a calendar');
      }
    } else {
      print('Bad prop status');
    }
  }

  // Print calendar objects info
  if (calendars.isNotEmpty) {
    var getObjectsResult = await client.getObjects(calendars.first);

    for (var result in getObjectsResult.multistatus!.response) {
      print('PATH: ${result.href}');

      if (result.propstat.status == 200) {
        print('CALENDAR DATA:\n${result.propstat.prop['calendar-data']}');
        print('ETAG: ${result.propstat.prop['getetag']}');
      }
      print('Bad prop status');
    }

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

    // Create calendar
    var createCalResponse =
        await client.createCal(join(calendars.first, '/example.ics'), calendar);

    if (createCalResponse.statusCode == 201) print('Created');
  }
}
