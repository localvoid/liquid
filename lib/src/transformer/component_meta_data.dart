// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library liquid.transformer.component_meta_data;

import 'dart:collection';
import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/element.dart';
import 'package:code_transformers/resolver.dart';
import 'package:code_transformers/messages/build_logger.dart';
import 'package:liquid/src/transformer/liquid_elements.dart';
import 'package:liquid/src/annotations.dart' show reservedProperties;

class ComponentMetaDataExtractor {
  final BuildLogger _logger;
  final Resolver _resolver;
  final LiquidElements _elements;
  final Map<ClassElement, ComponentMetaData> _cache =
      new HashMap<ClassElement, ComponentMetaData>();

  ComponentMetaDataExtractor(this._logger, this._resolver, this._elements);

  ComponentMetaData extract(ClassElement componentClass) {
    ComponentMetaData result = _cache[componentClass];
    if (result != null) {
      return result;
    }

    final _AnnotationExtractor extractor = new _AnnotationExtractor(_elements);
    for (final InterfaceType supertype in componentClass.allSupertypes.reversed) {
      if (!supertype.isObject) {
        supertype.element.node.visitChildren(extractor);
      }
    }
    componentClass.node.visitChildren(extractor);

    result = new ComponentMetaData(extractor.properties);
    _cache[componentClass] = result;

    return result;
  }
}

class PropertyData {
  final String name;
  final bool required;
  final bool immutable;
  final bool equalCheck;
  final int index;
  final DartType type;

  const PropertyData(
      this.name,
      {this.required,
       this.immutable,
       this.equalCheck,
       this.index,
       this.type});
}

class ComponentMetaData {
  final Map<String, PropertyData> properties;
  int requiredPropertiesCounter = 0;
  bool isOptimizable = true;
  bool isPropertyMask = false;
  bool isImmutable = true;

  ComponentMetaData(this.properties) {
    properties.forEach((name, prop) {
      if (prop.required) {
        requiredPropertiesCounter++;
      } else {
        isPropertyMask = true;
      }
      if (!prop.immutable) {
        isImmutable = false;
        if (!prop.equalCheck) {
          isOptimizable = false;
        }
      }
    });
  }

  int createPropertyMask(List namedArguments) {
    int mask = 0;
    for (final arg in namedArguments) {
      if (!reservedProperties.containsKey(arg.name)) {
        mask |= 1 << properties[arg.name].index;
      }
    }
    return mask;
  }
}

class _AnnotationExtractor extends GeneralizingAstVisitor {
  final LiquidElements _liquidElements;

  int optionalIndex = 0;

  final Map<String, PropertyData> properties = {};

  _AnnotationExtractor(this._liquidElements);

  void visitAnnotation(Annotation annotation) {
    final AstNode parent = annotation.parent;
    if (parent is! Declaration) {
      return;
    }

    final Element element = annotation.element;
    if (element is ConstructorElement &&
        element.returnType == _liquidElements.propertyType) {

      bool required = false;
      bool immutable = false;
      bool equalCheck = null;

      for (final Expression arg in annotation.arguments.arguments) {
        if (arg is NamedExpression) {
          final String name = arg.name.label.name;

          bool value;
          final Expression valueExpression = arg.expression;
          if (valueExpression is BooleanLiteral) {
            value = valueExpression.value;
          }

          switch (name) {
            case 'required':
              required = value;
              break;
            case 'immutable':
              immutable = value;
              break;
            case 'equalCheck':
              equalCheck = value;
              break;
          }
        }
      }

      if (parent is MethodDeclaration) {

      } else if (parent is FieldDeclaration) {
        for (final VariableDeclaration variable in parent.fields.variables) {
          final String propertyName = variable.name.name;
          final int propertyIndex = required ? -1 : optionalIndex++;
          final DartType propertyType = variable.element.type;
          if (equalCheck == null) {
            if (_liquidElements.isBasicType(propertyType)) {
              equalCheck = true;
            } else {
              equalCheck = false;
            }
          }

          properties[propertyName] =
              new PropertyData(propertyName,
                  required: required,
                  immutable: immutable,
                  equalCheck: equalCheck,
                  index: propertyIndex,
                  type: propertyType);
        }
      }
    }
  }
}
