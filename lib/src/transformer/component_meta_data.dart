// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library liquid.transformer.component_meta_data;

import 'dart:collection';
import 'package:analyzer/src/generated/element.dart';
import 'package:liquid/src/transformer/liquid_elements.dart';

/// List of reserved properties
const reservedProperties = const {'key': true,
                                  'children': true,
                                  'id': true,
                                  'attributes': true,
                                  'classes': true,
                                  'styles': true};

class ComponentMetaDataExtractor {
  final LiquidElements _liquidElements;

  ComponentMetaDataExtractor(this._liquidElements);

  ComponentMetaData extract(ClassElement element) {
    final List<FieldElement> properties = [];
    final HashMap<String, int> propertyPositions = new HashMap();

    for (final field in element.fields) {
      if (isPropertyField(field)) {
        propertyPositions[field.name] = properties.length;
        properties.add(field);
      }
    }

    return new ComponentMetaData(properties, propertyPositions);
  }

  bool isComponent(ClassElement element) =>
      (element.type.isSubtypeOf(_liquidElements.componentClass.type) &&
       element != _liquidElements.componentClass);

  bool isPropertyField(FieldElement element) {
    for (final meta in element.metadata) {
      final metaElement = meta.element;
      if (metaElement is ConstructorElement &&
          metaElement.returnType.element == _liquidElements.propertyClass) {
        return true;
      }
    }
    return false;
  }

}

class ComponentMetaData {
  final List<FieldElement> properties;
  final HashMap<String, int> propertyPositions;

  ComponentMetaData(this.properties, this.propertyPositions);

  int createPropertyMask(namedArguments) {
    int mask = 0;
    for (final arg in namedArguments) {
      if (!reservedProperties.containsKey(arg.name)) {
        final index = propertyPositions[arg.name];
        mask |= 1 << index;
      }
    }
    return mask;
  }
}
