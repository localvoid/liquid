// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid.vdom;

abstract class VComponent<C extends Component<T>, T extends html.Element>
  extends VElementBase<T> {
  C component;

  html.Node get container => component.container;

  VComponent(
      Object key,
      List<VNode> children,
      String id,
      Map<String, String> attributes,
      List<String> classes,
      Map<String, String> styles)
      : super(key, children, id, attributes, classes, styles);

  void init() { component.init(); }

  void render(Context context) {
    super.render(context);
    component.internalUpdate();
  }

  void update(VComponent<C, T> other, Context context) {
    other.ref = ref;
    other.component = component;
  }

  void attached() { component.attach(); }

  void detached() { component.detach(); }

  void insertBefore(VNode node, html.Node nextRef, Context context) {
    component.insertBefore(node, nextRef);
  }

  void move(VNode node, html.Node nextRef, Context context) {
    component.move(node, nextRef);
  }

  void removeChild(VNode node, Context context) {
    component.removeChild(node);
  }

  String toString() => (component == null) ?
      'VComponentBase[stateless]' : 'VComponentBase[$component]';
}
