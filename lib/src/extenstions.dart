import 'package:html/dom.dart';

extension ParseDom on Document {
  ///selects all the matching [Element] for the given selector from the dom
  List<Element> select(String selector) {
    try {
      final tag = querySelectorAll(selector);
      return tag.map((element) => element).toList();
    } catch (e) {
      return [Element.tag('div')];
    }
  }

  ///selects the first [Element] with matching selector form the dom
  Element selectFirst(String selector) {
    try {
      final tag = querySelector(selector) ?? Element.tag('div');
      return tag;
    } catch (e) {
      return Element.tag('div');
    }
  }

  ///checks if the tag from the given selector is present in the dom
  bool isPresent(String selector) {
    try {
      final tag = querySelector(selector);
      if (tag != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}

extension ParseMulitpleTag on List<Element> {
  /// select the attribute from all elements in the list
  List<String> attr(String attr) {
    try {
      List<String> list = [];
      for (final attribute in this) {
        list.add(attribute.attr(attr));
      }
      return list;
    } catch (e) {
      return [''];
    }
  }

  /// get the text from all elements in the list

  List<String> text() {
    try {
      List<String> list = [];
      for (final text in this) {
        list.add(text.text);
      }
      return list;
    } catch (e) {
      return [''];
    }
  }
}

extension ParseTag on Element {
  ///Select a list of [Element] from a [Element]
  List<Element> select(String selector) {
    try {
      final tag = querySelectorAll(selector);
      return tag.map((element) => element).toList();
    } catch (e) {
      return [Element.tag('div')];
    }
  }

  ///Select a  [Element] from a [Element]
  Element selectFirst(String selector) {
    try {
      final tag = querySelector(selector) ?? Element.tag('div');
      return tag;
    } catch (e) {
      return Element.tag('div');
    }
  }

  ///Get the attribute of the selected [Element]
  String attr(String attr) {
    try {
      return attributes[attr] ?? '';
    } catch (e) {
      return '';
    }
  }
}
