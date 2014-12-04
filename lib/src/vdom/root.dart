// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid;

abstract class VRootBase<T extends html.Element> extends vdom.VElementContainerBase<T> {
  Component<T> component;

  VRootBase(
      List<vdom.VNode> children,
      String id,
      Map<String, String> attributes,
      List<String> classes,
      Map<String, String> styles)
      : super(null, children, id, attributes, classes, styles);

  void create(vdom.VContext context) {
    throw new UnsupportedError('VRootBase doesn\'t support creating, you'
        ' should mount it on top of the existing Component with mountComponent');
  }

  void mount(html.Node node, vdom.VContext context) {
    throw new UnsupportedError('VRootBase doesn\'t support mounting on top of'
        ' html nodes, you should mount it on top of the existing Component'
        ' with mountComponent');
  }

  void link(VRootDecorator<T> parent) {}

  void mountComponent(Component<T> component) {
    this.component = component;
    ref = component.element;
  }

  void update(VRootBase<T> other, VContext context) {
    super.update(other, context);
    other.component = component;
  }
}

// TODO: doesn't work properly, use double-linked lists
class VRootDecorator<T extends html.Element> extends VRootBase<T> {
  VRootDecorator<T> parent;
  VRootBase<T> _next;
  html.Node container;
  vdom.VNode innerContainer;

  VRootDecorator(
      {this.innerContainer,
       List<vdom.VNode> children,
       String id,
       Map<String, String> attributes,
       List<String> classes,
       Map<String, String> styles})
      : super(children, id, attributes, classes, styles);

  void decorate(VRootBase<T> root) {
    _next = root;
    root.link(this);
  }

  void link(VRootDecorator<T> parent) {
    this.parent = parent;
  }

  void mountComponent(Component<T> component) {
    super.mountComponent(component);
    if (_next != null) {
      _next.mountComponent(component);
    }
  }

  void render(VContext context) {
    if (parent == null) {
      container = ref;
    } else {
      if (parent.innerContainer == null) {
        container = parent.container;
      } else {
        container = parent.innerContainer.ref;
      }
    }
    super.render(context);
    if (_next != null) {
      _next.render(context);
    }
  }

  void update(VRootDecorator<T> other, VContext context) {
    if (parent == null) {
      container = ref;
    } else {
      if (parent.innerContainer == null) {
        container = parent.container;
      } else {
        container = parent.innerContainer.ref;
      }
    }
    super.update(other, context);
    if (_next != null) {
      _next.update(other._next, context);
    }
  }
}

class VRoot<T extends html.Element> extends VRootBase<T> {
  VRoot(
      {List<vdom.VNode> children,
       String id,
       Map<String, String> attributes,
       List<String> classes,
       Map<String, String> styles})
      : super(children, id, attributes, classes, styles);

  void insertBefore(vdom.VNode node, html.Node nextRef, VContext context) {
    component.insertBefore(node, nextRef);
  }

  void move(vdom.VNode node, html.Node nextRef, VContext context) {
    component.move(node, nextRef);
  }

  void removeChild(vdom.VNode node, VContext context) {
    component.removeChild(node);
  }
}

VRootDecorator vRootDecorator({
  List<vdom.VNode> children,
  vdom.VNode innerContainer,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VRootDecorator(
      children: children,
      innerContainer: innerContainer,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

VRoot vRoot({
  List<vdom.VNode> children,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VRoot(
      children: children,
      attributes: attributes,
      classes: classes,
      styles: styles);
}
