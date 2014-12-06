// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid.vdom;

abstract class VComponentBase<C extends liquid.Component<T>, T extends html.Element>
  extends VNode<T> {
  C component = null;

  VComponentBase(Object key) : super(key);

  void create(Context context);

  void init() { component.init(); }

  void render(Context context) { component.internalUpdate(); }

  void update(VComponentBase<C, T> other, Context context) {
    other.ref = ref;
    other.component = component;
  }

  void attached() { component.attach(); }

  void detached() { component.detach(); }

  String toString() => (component == null) ?
      'VComponentBase[stateless]' : 'VComponentBase[$component]';
}

abstract class VComponent<C extends liquid.Component<T>, T extends html.Element>
    extends VComponentBase<C, T> {
  Map<String, String> attributes;
  List<String> classes;
  Map<String, String> styles;

  VComponent(Object key, this.attributes, this.classes, this.styles)
       : super(key);

  void render(Context context) {
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

  void update(VComponent<C, T> other, Context context) {
    super.update(other, context);
    if (attributes != null || other.attributes != null) {
      updateMap(attributes, other.attributes, ref.attributes);
    }
    if (styles != null || other.styles != null) {
      updateStyle(styles, other.styles, ref.style);
    }
    if (classes != null || other.classes != null) {
      updateSet(classes, other.classes, ref.classes);
    }
  }

  String toString() => (component == null) ?
      'VComponent[stateless]' : 'VComponent[$component]';
}

abstract class VComponentContainer<C extends liquid.Component<T>, T extends html.Element>
    extends VComponent<C, T> with VContainer {
  List<VNode> children;

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
    } else if (children is Iterable) {
      this.children = children.toList();
    } else if (children is String) {
      this.children = [new VText(children)];
    } else {
      this.children = [children];
    }
    return this;
  }

  void render(Context context) {
    super.render(context);
    renderChildren(children, context);
  }

  void update(VComponentContainer<C, T> other, Context context) {
    super.update(other, context);
    updateChildren(children, other.children, context);
  }

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
      'VComponentContainer[stateless]' : 'VComponentContainer[$component]';
}
