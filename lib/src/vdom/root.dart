// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid.vdom;

abstract class VRootBase<T extends html.Element> extends VElementBase<T> {
  VRootDecorator<T> parent;
  Component<T> component;

  // TODO: optimize this
  html.Node get container {
    if (parent != null) {
      return parent.innerContainer != null ? parent.innerContainer : parent.container;
    }
    return component.container;
  }

  VRootBase(
      List<VNode> children,
      String id,
      Map<String, String> attributes,
      List<String> classes,
      Map<String, String> styles)
      : super(null, children, id, attributes, classes, styles);

  void create(Context context) {
    throw new UnsupportedError('VRootBase doesn\'t support creating, you'
        ' should mount it on top of the existing Component with mountComponent');
  }

  void mount(html.Node node, Context context) {
    if (children != null) {
      mountChildren(children, node, context);
    }
  }

  void link(VRootDecorator<T> parent) {
    this.parent = parent;
  }

  void mountComponent(Component<T> component) {
    this.component = component;
    ref = component.element;
  }

  void update(VRootBase<T> other, Context context) {
    super.update(other, context);
    other.component = component;
  }
}

/// Root-level Virtual Node for [Component]s to update root-level elements
/// created with `create()` lifecycle method.
class VRoot<T extends html.Element> extends VRootBase<T> {
  VRoot(
      {List<VNode> children,
       String id,
       Map<String, String> attributes,
       List<String> classes,
       Map<String, String> styles})
      : super(children, id, attributes, classes, styles);

  void insertBefore(VNode node, html.Node nextRef, Context context) {
    component.insertBefore(node, nextRef);
  }

  void move(VNode node, html.Node nextRef, Context context) {
    component.move(node, nextRef);
  }

  void removeChild(VNode node, Context context) {
    component.removeChild(node);
  }
}

VRoot root({
  List<VNode> children,
  String id,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VRoot(
      children: children,
      id: id,
      attributes: attributes,
      classes: classes,
      styles: styles);
}
