// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid.vdom;

/// Creates a new [VLabel] element.
VLabel label({
  Object key,
  String htmlFor,
  List<VNode> children,
  String id,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VLabel(
      key: key,
      htmlFor: htmlFor,
      children: children,
      id: id,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

/// Virtual DOM Label Element
class VLabel extends VElementBase<html.LabelElement> {
  final String htmlFor;

  VLabel({
    Object key,
    this.htmlFor,
    List<VNode> children,
    String id,
    Map<String, String> attributes,
    List<String> classes,
    Map<String, String> styles})
    : super(key, children, id, attributes, classes, styles);

  void create(Context context) { ref = new html.LabelElement(); }

  void render(Context context) {
    super.render(context);
    if (htmlFor != null) {
      ref.htmlFor = htmlFor;
    }
  }

  void update(VLabel other, Context context) {
    super.update(other, context);
    if (other.htmlFor != htmlFor) {
      ref.htmlFor = other.htmlFor;
    }
  }
}
