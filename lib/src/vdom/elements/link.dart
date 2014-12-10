// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid.vdom;

/// Creates a new [VLink] element.
VLink link({
  Object key,
  String href,
  String title,
  bool checked,
  List<VNode> children,
  String id,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VLink(
      key: key,
      href: href,
      title: title,
      children: children,
      id: id,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

/// Virtual DOM Anchor Element helper for links.
class VLink extends VElementBase<html.AnchorElement> {
  final String href;
  final String title;

  VLink({
    Object key,
    this.href,
    this.title,
    List<VNode> children,
    String id,
    Map<String, String> attributes,
    List<String> classes,
    Map<String, String> styles})
    : super(key, children, id, attributes, classes, styles);

  void create(Context context) { ref = new html.AnchorElement(); }

  void render(Context context) {
    super.render(context);
    if (href != null) {
      ref.href = href;
    }
    if (title != null) {
      ref.title = title;
    }
  }

  void update(VLink other, Context context) {
    super.update(other, context);
    if (other.href != href) {
      ref.href = other.href;
    }
    if (other.title != title) {
      ref.title = other.title;
    }
  }
}
