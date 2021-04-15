import 'package:caldav_client/src/multistatus/response.dart';
import 'package:xml/xml.dart';

class MultiStatus {
  final List<Response> response;
  final String? syncToken;

  MultiStatus({required this.response, this.syncToken});

  factory MultiStatus.fromXml(XmlDocument element) {
    var response = <Response>[];

    var multistatus = element.firstElementChild;

    if (multistatus!.name.local == 'multistatus') {
      var elements = multistatus.children.whereType<XmlElement>();

      // add responses
      elements
          .where((element) => element.name.local == 'response')
          .forEach((element) {
        response.add(Response.fromXml(element));
      });

      try {
        var syncToken = elements
            .firstWhere((element) => element.name.local == 'sync-token');

        return MultiStatus(response: response, syncToken: syncToken.text);
      } catch (e) {
        return MultiStatus(response: response);
      }
    }

    throw Error();
  }

  factory MultiStatus.fromString(String string) {
    var document = XmlDocument.parse(string);

    return MultiStatus.fromXml(document);
  }
}
