// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid.vdom;

/// Creates a new [VArea] element.
VArea area({
  Object key,
  String shape,
  String coords,
  String href,
  String alt,
  List<VNode> children,
  String id,
  String type,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VArea(
      key: key,
      shape: shape,
      coords: coords,
      href: href,
      alt: alt,
      children: children,
      id: id,
      type: type,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

/// Virtual DOM Area Element.
class VArea extends VElementBase<html.AreaElement> {
  final String shape;
  final String coords;
  final String href;
  final String alt;

  VArea({
    Object key,
    this.shape,
    this.coords,
    this.href,
    this.alt,
    List<VNode> children,
    String id,
    String type,
    Map<String, String> attributes,
    List<String> classes,
    Map<String, String> styles})
    : super(key, children, id, type, attributes, classes, styles);

  void create(Context context) { ref = new html.AreaElement(); }

  void render(Context context) {
    super.render(context);
    if (shape != null) {
      ref.shape = shape;
    }
    if (coords != null) {
      ref.coords = coords;
    }
    if (href != null) {
      ref.href = href;
    }
    if (alt != null) {
      ref.alt = alt;
    }
  }

  void update(VArea other, Context context) {
    super.update(other, context);
    if (other.shape != shape) {
      ref.shape = other.shape;
    }
    if (other.coords != coords) {
      ref.coords = other.coords;
    }
    if (other.href != href) {
      ref.href = other.href;
    }
    if (other.alt != alt) {
      ref.alt = other.alt;
    }
  }
}
