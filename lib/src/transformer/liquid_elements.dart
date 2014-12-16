// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library liquid.transformer.liquid_elements;

import 'package:analyzer/src/generated/element.dart';
import 'package:code_transformers/resolver.dart';

/// Object that stores resolved elements from the Liquid library.
class LiquidElements {
  /// [property] class.
  static const int propertyClassFlag = 1;

  /// [Component] class.
  static const int componentClassFlag = 1 << 1;

  /// [VComponent] class.
  static const int vComponentClassFlag = 1 << 2;

  /// [componentFactory] function from dynamic library.
  static const int componentFactoryFlag = 1 << 3;

  Resolver _resolver;
  int elementMask = 0;

  ClassElement boolClass;
  ClassElement numClass;
  ClassElement intClass;
  ClassElement doubleClass;
  ClassElement stringClass;

  ClassElement propertyClass;
  ClassElement componentClass;
  ClassElement vComponentClass;
  Element componentFactory;

  LiquidElements(this._resolver) {
    // TODO: is there any way to get TypeProvider instance?
    boolClass = _resolver.getType('dart.core.bool');
    numClass = _resolver.getType('dart.core.num');
    intClass = _resolver.getType('dart.core.int');
    doubleClass = _resolver.getType('dart.core.double');
    stringClass = _resolver.getType('dart.core.String');
  }

  bool isCoreBasicClass(ClassElement e) =>
      e == boolClass ||
      e == numClass ||
      e == intClass ||
      e == doubleClass ||
      e == stringClass;

  /// Lookup all [Element]s for elements specified in [mask] argument.
  void lookup(int mask) {
    if ((mask & propertyClassFlag == propertyClassFlag) &&
        (elementMask & propertyClassFlag != propertyClassFlag)) {
      propertyClass = _resolver.getType('liquid.annotations.property');
      if (propertyClass != null) {
        elementMask |= propertyClassFlag;
      }
    }

    if ((mask & componentClassFlag == componentClassFlag) &&
        (elementMask & componentClassFlag != componentClassFlag)) {
      componentClass = _resolver.getType('liquid.component.Component');
      if (componentClass != null) {
        elementMask |= componentClassFlag;
      }
    }

    if ((mask & vComponentClassFlag == vComponentClassFlag) &&
        (elementMask & vComponentClassFlag != vComponentClassFlag)) {
      vComponentClass = _resolver.getType('liquid.vdom.VComponent');
      if (vComponentClass != null) {
        elementMask |= vComponentClassFlag;
      }
    }

    if ((mask & componentFactoryFlag == componentFactoryFlag) &&
        (elementMask & componentFactoryFlag != componentFactoryFlag)) {
      componentFactory = _resolver.getLibraryFunction('liquid.dynamic.componentFactory');
      if (componentFactory != null) {
        elementMask |= componentFactoryFlag;
      }
    }
  }
}
