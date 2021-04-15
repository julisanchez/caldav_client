import 'package:caldav_client/src/multistatus/propstat.dart';
import 'package:xml/xml.dart';

class Response {
  final String href;
  final Propstat propstat;

  Response({required this.href, required this.propstat});

  factory Response.fromXml(XmlElement element) {
    if (element.name.local == 'response') {
      var elements = element.children.whereType<XmlElement>();

      var href =
          elements.firstWhere((element) => element.name.local == 'href').text;

      var propstatXml =
          elements.firstWhere((element) => element.name.local == 'propstat');

      return Response(href: href, propstat: Propstat.fromXml(propstatXml));
    }

    throw Error();
  }
}