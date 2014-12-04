// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid.dynamic;

class VGenericComponentContainer extends VGenericComponent with vdom.VContainer {
  List<vdom.VNode> children;

  html.Node get container => component.container;

  VGenericComponentContainer(
      this.children,
      ClassMirror typeMirror,
      Map<Symbol, _Property> propertyTypes,
      Map<Symbol, dynamic> properties,
      Object key,
      String id,
      Map<String, String> attributes,
      List<String> classes,
      Map<String, String> styles)
      : super(typeMirror, propertyTypes, properties, key, id, attributes, classes, styles);

  VGenericComponentContainer call(children) {
    if (children is List) {
      this.children = children;
    } else if (children is String) {
      this.children = [new vdom.VText(children)];
    } else {
      this.children = [children];
    }
    return this;
  }

  void render(Context context) {
    super.render(context);
    renderChildren(children, context);
  }

  void update(VGenericComponentContainer other, Context context) {
    super.update(other, context);
    updateChildren(children, other.children, context);
  }

  void insertBefore(vdom.VNode node, html.Node nextRef, Context context) {
    component.insertBefore(node, nextRef);
  }

  void move(vdom.VNode node, html.Node nextRef, Context context) {
    component.move(node, nextRef);
  }

  void removeChild(vdom.VNode node, Context context) {
    component.removeChild(node);
  }
}

class VGenericComponentContainerFactory extends VGenericComponentFactory {
  VGenericComponentContainerFactory(Type componentType) : super(componentType);

  VGenericComponent _create([Map args]) {
    if (args == null) {
      return new VGenericComponentContainer(null, _classMirror, _propertyTypes,
          null, null, null, null, null, null);
    }
    final properties = new HashMap.from(args);
    final List children = properties.remove(#children);
    final Object key = properties.remove(#key);
    final String id = properties.remove(#id);
    final Map<String, String> attributes = properties.remove(#attributes);
    final List<String> classes = properties.remove(#classes);
    final Map<String, String> styles = properties.remove(#styles);
    return new VGenericComponentContainer(
        children,
        _classMirror,
        _propertyTypes,
        properties,
        key,
        id,
        attributes,
        classes,
        styles);
  }
}

Function componentContainerFactory(Type componentType) => new VGenericComponentContainerFactory(componentType);
