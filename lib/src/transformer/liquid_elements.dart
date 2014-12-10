// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library liquid.transformer.liquid_elements;

import 'package:analyzer/src/generated/element.dart';
import 'package:code_transformers/resolver.dart';

/// Object that stores resolved elements from the Liquid library.
class LiquidElements {
  static const int propertyClassFlag = 1;
  static const int componentClassFlag = 1 << 1;
  static const int staticTreeFactoryFlag = 1 << 2;
  static const int dynamicTreeFactoryFlag = 1 << 3;
  static const int componentFactoryFlag = 1 << 4;
  static const int allElements = propertyClassFlag | componentClassFlag |
      staticTreeFactoryFlag | dynamicTreeFactoryFlag | componentFactoryFlag;

  // TODO: fix this
  static const int vComponentBaseClassFlag = 1 << 5;


  Resolver _resolver;
  int elementMask = 0;
  ClassElement propertyClass;
  ClassElement componentClass;
  Element staticTreeFactory;
  Element dynamicTreeFactory;
  Element componentFactory;
  ClassElement vComponentBaseClass;

  LiquidElements(this._resolver);

  void lookup(int mask) {
    if ((mask & propertyClassFlag == propertyClassFlag) &&
        (elementMask & propertyClassFlag != propertyClassFlag)) {
      propertyClass = _resolver.getType('liquid.property.Property');
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

    if ((mask & vComponentBaseClassFlag == vComponentBaseClassFlag) &&
        (elementMask & vComponentBaseClassFlag != vComponentBaseClassFlag)) {
      vComponentBaseClass = _resolver.getType('liquid.vdom.VComponent');
      if (vComponentBaseClass != null) {
        elementMask |= vComponentBaseClassFlag;
      }
    }
  }
}
