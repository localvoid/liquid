// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library liquid.transformer.component_meta_data;

import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/element.dart';
import 'package:liquid/src/transformer/liquid_elements.dart';
import 'package:liquid/src/annotations.dart' show reservedProperties;

class ComponentMetaDataExtractor {
  final LiquidElements _liquidElements;

  ComponentMetaDataExtractor(this._liquidElements);

  ComponentMetaData extractFromComponent(ClassElement element) {
    // TODO: visit component parents / mixins
    final extractor = new _AnnotationExtractor(_liquidElements);
    element.node.visitChildren(extractor);
    return new ComponentMetaData(extractor.properties);
  }

  ComponentMetaData extractFromVComponent(ClassElement element) {
    final extractor = new _AnnotationExtractor(_liquidElements);
    element.node.visitChildren(extractor);
    return new ComponentMetaData(extractor.properties);
  }

  bool isComponent(ClassElement element) =>
      element.type.isSubtypeOf(_liquidElements.componentClass.type);
}

class PropertyMetaData {
  final bool required;
  final bool immutable;
  final bool equalCheck;
  final int index;
  final DartType type;

  const PropertyMetaData(this.required, this.immutable, this.equalCheck, this.index,
      this.type);
}

class ComponentMetaData {
  final Map<String, PropertyMetaData> properties;
  bool isOptimizable = true;
  bool isPropertyMask = false;
  bool isImmutable = true;

  ComponentMetaData(this.properties) {
    for (final prop in properties.values) {
      if (!prop.required) {
        isPropertyMask = true;
      }
      if (!prop.immutable) {
        isImmutable = false;
        if (!prop.equalCheck) {
          isOptimizable = false;
        }
      }
    }
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

  final properties = {};

  _AnnotationExtractor(this._liquidElements);

  void visitAnnotation(Annotation annotation) {
    final parent = annotation.parent;
    if (parent is! Declaration) {
      return;
    }

    final element = annotation.element;
    if (element is ConstructorElement &&
        element.returnType.element == _liquidElements.propertyClass) {

      bool required = false;
      bool immutable = false;
      bool equalCheck = null;

      for (final arg in annotation.arguments.arguments) {
        if (arg is NamedExpression) {
          final name = arg.name.label.name;
          var value;
          final valueExpression = arg.expression;
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
        for (final variable in parent.fields.variables) {
          final varType = variable.element.type;
          if (equalCheck == null) {
            if (_liquidElements.isCoreBasicClass(varType.element)) {
              equalCheck = true;
            } else {
              equalCheck = false;
            }
          }
          properties[variable.name.name] = new PropertyMetaData(required, immutable,
              equalCheck, properties.length, varType);
        }
      }
    }
  }
}
