// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library liquid.transformer.liquid_elements;

import 'package:analyzer/src/generated/element.dart';
import 'package:code_transformers/resolver.dart';

/// Object that stores resolved elements from the Liquid library.
class LiquidElements {
  /// [Property] class used for @property annotation.
  static const int propertyClassFlag = 1;

  /// [Component] class.
  static const int componentClassFlag = 1 << 1;

  /// [staticTreeFactory] function from dynamic library.
  static const int staticTreeFactoryFlag = 1 << 2;

  /// [dynamicTreeFactory] function from dynamic library.
  static const int dynamicTreeFactoryFlag = 1 << 3;

  /// [componentFactory] function from dynamic library.
  static const int componentFactoryFlag = 1 << 4;

  /// [VComponent] class.
  static const int vComponentClassFlag = 1 << 5;

  Resolver _resolver;
  int elementMask = 0;
  ClassElement propertyClass;
  ClassElement componentClass;
  Element staticTreeFactory;
  Element dynamicTreeFactory;
  Element componentFactory;
  ClassElement vComponentBaseClass;

  LiquidElements(this._resolver);

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

    if ((mask & staticTreeFactoryFlag == staticTreeFactoryFlag) &&
        (elementMask & staticTreeFactoryFlag != staticTreeFactoryFlag)) {
      staticTreeFactory = _resolver.getLibraryFunction('liquid.dynamic.staticTreeFactory');
      if (staticTreeFactory != null) {
        elementMask |= staticTreeFactoryFlag;
      }
    }

    if ((mask & dynamicTreeFactoryFlag == dynamicTreeFactoryFlag) &&
        (elementMask & dynamicTreeFactoryFlag != dynamicTreeFactoryFlag)) {
      dynamicTreeFactory = _resolver.getLibraryFunction('liquid.dynamic.dynamicTreeFactory');
      if (dynamicTreeFactory != null) {
        elementMask |= dynamicTreeFactoryFlag;
      }
    }

    if ((mask & componentFactoryFlag == componentFactoryFlag) &&
        (elementMask & componentFactoryFlag != componentFactoryFlag)) {
      componentFactory = _resolver.getLibraryFunction('liquid.dynamic.componentFactory');
      if (componentFactory != null) {
        elementMask |= componentFactoryFlag;
      }
    }

    if ((mask & vComponentClassFlag == vComponentClassFlag) &&
        (elementMask & vComponentClassFlag != vComponentClassFlag)) {
      vComponentBaseClass = _resolver.getType('liquid.vdom.VComponent');
      if (vComponentBaseClass != null) {
        elementMask |= vComponentClassFlag;
      }
    }
  }
}
