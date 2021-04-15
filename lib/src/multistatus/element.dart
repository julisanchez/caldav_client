import 'package:xml/xml.dart';

class Element {
  final String name;
  final Map<String, dynamic> atributes;
  final String text;

  Element(
      {required this.name,
      this.atributes = const <String, dynamic>{},
      this.text = ''});

  factory Element.fromXml(XmlElement element) {
    var attributes = <String, dynamic>{};

    element.attributes.forEach((attribute) {
      attributes[attribute.name.local] = attribute.value;
    });

    return Element(
        name: element.name.local, text: element.text, atributes: attributes);
  }
}