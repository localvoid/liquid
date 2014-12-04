// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid;

abstract class VComponentBase<C extends Component<T>, T extends html.Element>
  extends vdom.VNode<T> {
  C component = null;

  VComponentBase(Object key) : super(key);

  void create(VContext context);

  void init() { component.init(); }

  void render(VContext context) { component.internalUpdate(); }

  void update(VComponentBase<C, T> other, VContext context) {
    other.ref = ref;
    other.component = component;
  }

  void attached() { component.attach(); }

  void detached() { component.detach(); }

  String toString() => (component == null) ?
      'VComponentBase[stateless]' : 'VComponentBase[$component]';
}

abstract class VComponent<C extends Component<T>, T extends html.Element>
    extends VComponentBase<C, T> {
  Map<String, String> attributes;
  List<String> classes;
  Map<String, String> styles;

  VComponent(Object key, this.attributes, this.classes, this.styles)
       : super(key);

  void render(VContext context) {
    super.render(context);
    if (attributes != null) {
      attributes.forEach((key, value) {
        ref.setAttribute(key, value);
      });
    }
    if (styles != null) {
      styles.forEach((key, value) {
        ref.style.setProperty(key, value);
      });
    }
    if (classes != null) {
      ref.classes.addAll(classes);
    }
  }

  void update(VComponent<C, T> other, VContext context) {
    super.update(other, context);
    if (attributes != null || other.attributes != null) {
      vdom.updateMap(attributes, other.attributes, ref.attributes);
    }
    if (styles != null || other.styles != null) {
      vdom.updateStyle(styles, other.styles, ref.style);
    }
    if (classes != null || other.classes != null) {
      vdom.updateSet(classes, other.classes, ref.classes);
    }
  }

  String toString() => (component == null) ?
      'VComponent[stateless]' : 'VComponent[$component]';
}

abstract class VComponentContainer<C extends Component<T>, T extends html.Element>
    extends VComponent<C, T> with vdom.VContainer {
  List<vdom.VNode> children;

  html.Node get container => component.container;

  VComponentContainer(Object key,
      this.children,
      Map<String, String> attributes,
      List<String> classes,
      Map<String, String> styles)
      : super(key, attributes, classes, styles);

  VComponentContainer<C, T> call(children) {
    if (children is List) {
      this.children = children;
    } else if (children is String) {
      this.children = [new vdom.VText(children)];
    } else {
      this.children = [children];
    }
    return this;
  }

  void render(VContext context) {
    super.render(context);
    renderChildren(children, context);
  }

  void update(VComponentContainer<C, T> other, VContext context) {
    super.update(other, context);
    updateChildren(children, other.children, context);
  }

  void insertBefore(vdom.VNode node, html.Node nextRef, VContext context) {
    component.insertBefore(node, nextRef);
  }

  void move(vdom.VNode node, html.Node nextRef, VContext context) {
    component.move(node, nextRef);
  }

  void removeChild(vdom.VNode node, VContext context) {
    component.removeChild(node);
  }

  String toString() => (component == null) ?
      'VComponentContainer[stateless]' : 'VComponentContainer[$component]';
}
