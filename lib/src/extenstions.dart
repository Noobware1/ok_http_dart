import 'package:html/dom.dart';

extension ParseDom on Document {
  ///selects all the matching [Element] for the given selector from the dom
  List<Element> select(String selector) {
    final tag = querySelectorAll(selector);
    return tag.map((element) => element).toList();
  }

  ///selects the first [Element] with matching selector form the dom
  Element selectFirst(String selector) {
    final tag = querySelector(selector);
    if (tag == null) throw _noElemntException(selector);
    return tag;
  }

  ///checks if the tag from the given selector is present in the dom
  bool isPresent(String selector) {
    final tag = querySelector(selector);
    if (tag != null) {
      return true;
    } else {
      return false;
    }
  }
}

extension ParseMulitpleTag on List<Element> {
  /// select the attribute from all elements in the list
  List<String> attr(String attr) {
    List<String> list = [];
    for (final attribute in this) {
      list.add(attribute.attr(attr));
    }
    return list;
  }

  /// get the text from all elements in the list

  List<String> text() {
    List<String> list = [];
    for (final text in this) {
      list.add(text.text);
    }
    return list;
  }
}

extension ParseTag on Element {
  ///Select a list of [Element] from a [Element]
  List<Element> select(String selector) {
    final tag = querySelectorAll(selector);
    return tag.map((element) => element).toList();
  }

  ///Select a  [Element] from a [Element]
  Element selectFirst(String selector) {
    final tag = querySelector(selector);
    if (tag == null) throw _noElemntException(selector);
    return tag;
  }

  ///Get the attribute of the selected [Element]
  String attr(String attr) {
    final attribute = attributes[attr];
    if (attribute == null) throw _noAttrException(attr);
    return attribute;
  }
}

_noElemntException(String selector) =>
    Exception('No Element for the given css selector $selector');

_noAttrException(String attr) =>
    Exception('No attr like $attr is present in the given element');
