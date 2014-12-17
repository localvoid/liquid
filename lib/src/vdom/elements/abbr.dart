// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid.vdom;

/// Creates a new [VAbbr] element.
VAbbr abbr({
  Object key,
  String title,
  List<VNode> children,
  String id,
  String type,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VAbbr(
      key: key,
      title: title,
      children: children,
      id: id,
      type: type,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

/// Virtual DOM Abbr Element.
class VAbbr extends VElementBase<html.Element> {
  final String title;

  VAbbr({
    Object key,
    this.title,
    List<VNode> children,
    String id,
    String type,
    Map<String, String> attributes,
    List<String> classes,
    Map<String, String> styles})
    : super(key, children, id, type, attributes, classes, styles);

  void create(Context context) { ref = new html.Element.tag('abbr'); }

  void render(Context context) {
    super.render(context);
    if (title != null) {
      ref.title = title;
    }
  }

  void update(VAbbr other, Context context) {
    super.update(other, context);
    if (other.title != title) {
      ref.title = other.title;
    }
  }
}
