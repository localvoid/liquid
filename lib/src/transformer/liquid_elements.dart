// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library liquid.transformer.liquid_elements;

import 'dart:collection';
import 'package:analyzer/src/generated/element.dart';
import 'package:code_transformers/resolver.dart';

/// Object that stores resolved elements from the Liquid library.
class LiquidElements {
  /// [property] class.
  static const int propertyFlag = 1;

  /// [Component] class.
  static const int componentFlag = 1 << 1;

  /// [VNode] class.
  static const int vNodeFlag = 1 << 2;

  /// [VComponent] class.
  static const int vComponentFlag = 1 << 3;

  /// [componentFactory] function from dynamic library.
  static const int componentFactoryFlag = 1 << 4;

  /// [VGenericComponentFactory] class from dynamic library.
  static const int vGenericComponentFactoryFlag = 1 << 5;

  Resolver _resolver;
  int elementMask = 0;

  InterfaceType boolType;
  InterfaceType numType;
  InterfaceType intType;
  InterfaceType doubleType;
  InterfaceType stringType;
  InterfaceType objectType;
  InterfaceType mapType;
  InterfaceType listType;

  InterfaceType propertyType;
  InterfaceType componentType;
  InterfaceType vNodeType;
  InterfaceType vComponentType;
  InterfaceType vGenericComponentFactoryType;
  FunctionElement componentFactory;

  HashMap<String, InterfaceType> reservedPropertyTypes =
      new HashMap<String, InterfaceType>();


  LiquidElements(this._resolver) {
    // TODO: is there any way to get TypeProvider instance?
    boolType = _resolver.getType('dart.core.bool').type;
    numType = _resolver.getType('dart.core.num').type;
    intType = _resolver.getType('dart.core.int').type;
    doubleType = _resolver.getType('dart.core.double').type;
    stringType = _resolver.getType('dart.core.String').type;
    objectType = _resolver.getType('dart.core.Object').type;
    mapType = _resolver.getType('dart.core.Map').type;
    listType = _resolver.getType('dart.core.List').type;

    final propertyClass = _resolver.getType('liquid.annotations.property');
    final componentClass = _resolver.getType('liquid.component.Component');
    final vNodeClass = _resolver.getType('liquid.vdom.VNode');
    final vComponentClass = _resolver.getType('liquid.vdom.VComponent');
    final vGenericComponentFactoryClass = _resolver.getType('liquid.dynamic.VGenericComponentFactory');
    componentFactory = _resolver.getLibraryFunction('liquid.dynamic.componentFactory');

    if (propertyClass != null) {
      propertyType = propertyClass.type;
      elementMask |= propertyFlag;
    }

    if (componentClass != null) {
      componentType = componentClass.type;
      elementMask |= componentFlag;
    }

    if (vNodeClass != null) {
      vNodeType = vNodeClass.type;
      elementMask |= vNodeFlag;
    }

    if (vComponentClass != null) {
      vComponentType = vComponentClass.type;
      elementMask |= vComponentFlag;
    }

    if (vGenericComponentFactoryClass != null) {
      vGenericComponentFactoryType = vGenericComponentFactoryClass.type;
      elementMask |= vGenericComponentFactoryFlag;
    }

    if (componentFactory != null) {
      elementMask |= componentFactoryFlag;
    }

    reservedPropertyTypes['key'] = objectType;
    reservedPropertyTypes['children'] = listType.substitute4([vNodeType]);
    reservedPropertyTypes['id'] = stringType;
    reservedPropertyTypes['type'] = stringType;
    reservedPropertyTypes['attributes'] = mapType.substitute4([stringType, stringType]);
    reservedPropertyTypes['classes'] = listType.substitute4([stringType]);
    reservedPropertyTypes['styles'] = mapType.substitute4([stringType, stringType]);
  }

  bool isBasicType(DartType t) =>
      t == boolType ||
      t == numType ||
      t == intType ||
      t == doubleType ||
      t == stringType;
}
