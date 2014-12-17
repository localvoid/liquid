// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid.vdom;

/// Creates a new [VImg] element.
VImg img({
  Object key,
  String src,
  String alt,
  String title,
  bool checked,
  List<VNode> children,
  String id,
  String type,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VImg(
      key: key,
      src: src,
      alt: alt,
      title: title,
      children: children,
      id: id,
      type: type,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

/// Virtual DOM Image Element helper for images.
class VImg extends VElementBase<html.ImageElement> {
  final String src;
  final String alt;
  final String title;

  VImg({
    Object key,
    this.src,
    this.alt,
    this.title,
    List<VNode> children,
    String id,
    String type,
    Map<String, String> attributes,
    List<String> classes,
    Map<String, String> styles})
    : super(key, children, id, type, attributes, classes, styles);

  void create(Context context) { ref = new html.ImageElement(); }

  void render(Context context) {
    super.render(context);
    if (src != null) {
      ref.src = src;
    }
    if (alt != null) {
      ref.alt = alt;
    }
    if (title != null) {
      ref.title = title;
    }
  }

  void update(VImg other, Context context) {
    super.update(other, context);
    if (other.src != src) {
      ref.src = other.src;
    }
    if (other.alt != alt) {
      ref.alt = other.alt;
    }
    if (other.title != title) {
      ref.title = other.title;
    }
  }
}
