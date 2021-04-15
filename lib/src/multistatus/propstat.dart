import 'package:caldav_client/src/multistatus/element.dart';
import 'package:xml/xml.dart';

class Propstat {
  final Map<String, dynamic> prop;
  final int status;

  Propstat({required this.prop, required this.status});

  factory Propstat.fromXml(XmlElement element) {
    if (element.name.local == 'propstat') {
      var prop = <String, dynamic>{};

      var elements = element.children.whereType<XmlElement>();

      // get prop
      var props = elements
          .firstWhere((element) => element.name.local == 'prop')
          .children
          .whereType<XmlElement>();

      // set prop value
      props.forEach((element) {
        var children = element.children
            .whereType<XmlElement>()
            .map((element) => Element.fromXml(element))
            .toList();

        var value = children.isEmpty ? element.text : children;

        prop[element.name.local] = value;
      });

      // get status
      var status = elements
          .firstWhere((element) => element.name.local == 'status')
          .text
          .split(' ')[1];

      return Propstat(prop: prop, status: int.parse(status));
    }

    throw Error();
  }

  @override
  String toString() {
    var string = '';

    prop.forEach((key, value) {
      var valueString = value.toString();

      string += '$key: ${valueString.length > 200 ? '\n' : ''}$valueString';
    });

    return string;
  }
}
