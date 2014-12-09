// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid.static;

abstract class VStaticTree extends vdom.VElementBase {
  vdom.VNode vRoot;

  VStaticTree(
      Object key,
      List<vdom.VNode> children,
      String id,
      Map<String, String> attributes,
      List<String> classes,
      Map<String, String> styles)
      : super(key, children, id, attributes, classes, styles);

  void create(vdom.Context context) {
    vRoot = build();
    vRoot.create(context);
    ref = vRoot.ref;
  }

  void mount(html.Element node, vdom.Context context) {
    super.mount(node, context);
    vRoot.mount(node, context);
  }

  void init() { vRoot.init(); }

  void render(vdom.Context context) {
    super.render(context);
    vRoot.render(context);
  }

  vdom.VNode build();

  void attached() { vRoot.attached(); }
  void detached() { vRoot.detached(); }
  void attach() { vRoot.attach(); }
}
