// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid.vdom;

/// EXPERIMENTAL
class VRootDecorator<T extends html.Element> extends VRootBase<T> {
  VRootBase<T> _next;
  VRootBase<T> _last;

  html.Node innerContainer;

  VRootDecorator(
      {this.innerContainer,
       List<VNode> children,
       String id,
       String type,
       Map<String, String> attributes,
       List<String> classes,
       Map<String, String> styles})
      : super(children, id, type, attributes, classes, styles);

  VRootBase<T> decorate(VRootBase<T> root) {
    if (_next == null) {
      _next = root;
    } else {
      assert(invariant(_last is VRootDecorator<T>,
          'Failed to decorate with $_last element.'));
      (_last as VRootDecorator<T>)._next = root;
    }
    _last = root;
    root.link(this);
    return this;
  }

  void mountComponent(Component<T> component) {
    super.mountComponent(component);
    if (_next != null) {
      _next.mountComponent(component);
    }
  }

  void mount(html.Node node, context) {
    throw new UnimplementedError(
        'mount() method isn\'t implemented for RootDecorator right now.');
  }

  void render(Context context) {
    super.render(context);
    if (_next != null) {
      _next.render(context);
    }
  }

  void update(VRootDecorator<T> other, Context context) {
    super.update(other, context);
    if (_next != null) {
      _next.update(other._next, context);
    }
  }
}

VRootDecorator rootDecorator({
  html.Node innerContainer,
  List<VNode> children,
  String id,
  String type,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VRootDecorator(
      innerContainer: innerContainer,
      children: children,
      id: id,
      type: type,
      attributes: attributes,
      classes: classes,
      styles: styles);
}
