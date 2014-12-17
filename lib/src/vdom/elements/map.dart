// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid.vdom;

/// Creates a new [VMap] element.
VMap map({
  Object key,
  String name,
  List<VNode> children,
  String id,
  String type,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VMap(
      key: key,
      name: name,
      children: children,
      id: id,
      type: type,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

/// Virtual DOM Map Element.
class VMap extends VElementBase<html.MapElement> {
  final String name;

  VMap({
    Object key,
    this.name,
    List<VNode> children,
    String id,
    String type,
    Map<String, String> attributes,
    List<String> classes,
    Map<String, String> styles})
    : super(key, children, id, type, attributes, classes, styles);

  void create(Context context) { ref = new html.MapElement(); }

  void render(Context context) {
    super.render(context);
    if (name != null) {
      ref.name = name;
    }
  }

  void update(VMap other, Context context) {
    super.update(other, context);
    if (other.name != name) {
      ref.name = other.name;
    }
  }
}
