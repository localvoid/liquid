// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library liquid.transformer.linter;

import 'dart:collection';
import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/element.dart';
import 'package:code_transformers/resolver.dart';
import 'package:code_transformers/messages/build_logger.dart';
import 'package:source_span/source_span.dart';
import 'package:liquid/src/transformer/liquid_elements.dart';
import 'package:liquid/src/transformer/component_meta_data.dart';
import 'package:liquid/src/annotations.dart' show reservedProperties;

class LinterVisitor extends GeneralizingAstVisitor {
  final BuildLogger logger;
  final Resolver resolver;
  final LiquidElements elements;
  final ComponentMetaDataExtractor extractor;
  final SourceFile sourceFile;

  LinterVisitor(this.logger, this.resolver, this.elements, this.extractor,
      this.sourceFile);

  /// factory invocations
  void visitFactoryCallInvocation(MethodInvocation method,
                                  ClassElement componentClass,
                                  ComponentMetaData componentMetaData) {
  }

  /// componentFactory(Type componentType) invocation
  void visitFactoryCreateInvocation(MethodInvocation method,
                                    ClassElement componentClass,
                                    ComponentMetaData componentMetaData) {
  }

  bool _isFactoryCall(Element element) =>
      (element is PropertyAccessorElement &&
       element.variable.propagatedType != null &&
       element.variable.propagatedType == elements.vGenericComponentFactoryType);

  bool _isFactoryCreate(Element element) =>
      (element is FunctionElement &&
       element == elements.componentFactory);

  SourceSpan getSpan(AstNode node, [SourceFile file]) =>
      file == null ? sourceFile.span(node.offset, node.end) :
                     file.span(node.offset, node.end);

  visitMethodInvocation(MethodInvocation method) {
    final Element element = method.methodName.bestElement;

    if (_isFactoryCall(element)) {
      if (_missingImports()) {
        return;
      }
      if (element is! PropertyAccessorElement) {
        logger.error(
            'Call to an Invalid Factory: ${method.toSource()}',
            span: getSpan(method));
        return;
      }

      final Expression initializer =
          (element as PropertyAccessorElement).variable.node.initializer;

      if (initializer is! MethodInvocation) {
        logger.error(
            'Call to an Invalid Factory: ${method.toSource()}',
            span: getSpan(method));
        return;
      }
      final MethodInvocation componentFactoryMethod = initializer;

      if (!_isFactoryCreate(componentFactoryMethod.methodName.bestElement)) {
        logger.error(
              'Call to an Invalid Factory: ${method.toSource()}',
              span: getSpan(method));
        return;
      }

      if (!_isValidFactory(componentFactoryMethod, false)) {
        logger.error(
              'Call to an Invalid Factory: ${method.toSource()}',
              span: getSpan(method));
        return;
      }

      final SimpleIdentifier arg = componentFactoryMethod.argumentList.arguments.first;
      final ClassElement component = arg.bestElement;
      final ComponentMetaData metaData = extractor.extract(component);
      if (metaData == null) {
        return;
      }

      int requiredPropertiesCounter = metaData.requiredPropertiesCounter;

      for (final arg in method.argumentList.arguments) {
        final String argName = arg.name.label.name;
        if (reservedProperties.containsKey(argName)) {
          final DartType argType = arg.bestType;
          final DartType targetType = elements.reservedPropertyTypes[argName];
          if (!argType.isAssignableTo(targetType)) {
            logger.warning(
                'Invalid Factory Call: '
                'The argument type \'${argType.displayName}\' cannot be '
                'assigned to the parameter type \'${targetType.displayName}\'.',
                span: getSpan(arg));
          }
        } else if (metaData.properties.containsKey(argName)) {
          final DartType argType = arg.bestType;
          final PropertyData propertyData = metaData.properties[argName];
          if (propertyData.required) {
            requiredPropertiesCounter--;
          }

          final DartType targetType = propertyData.type;
          if (!argType.isAssignableTo(targetType)) {
            logger.warning(
                'Invalid Factory Call: '
                'The argument type \'${argType.displayName}\' cannot be '
                'assigned to the parameter type \'${targetType.displayName}\'.',
                span: getSpan(arg));
          }
        } else {
          logger.warning(
              'Invalid Factory Call: '
              'The named parameter \'$argName\' is not defined.',
              span: getSpan(arg.name.label));
        }
      }

      if (requiredPropertiesCounter > 0) {
        final HashSet<String> argumentsIndex = new HashSet<String>();
        final List<String> requiredProperties = [];

        for (final PropertyData propertyData in metaData.properties.values) {
          if (propertyData.required) {
            requiredProperties.add(propertyData.name);
          }
        };
        for (final arg in method.argumentList.arguments) {
          argumentsIndex.add(arg.name.label.name);
        }

        final List<String> missingProperties =
            requiredProperties.where((p) => !argumentsIndex.contains(p)).toList();

        logger.warning(
            'Invalid Factory Call: '
            'Missing required properties: ${missingProperties.join(', ')}.',
            span: getSpan(method));
      }

      visitFactoryCallInvocation(method, component, metaData);

    } else if (_isFactoryCreate(element)) {
      if (_missingImports()) {
        return;
      }
      if (!_isValidFactory(method)) {
        return;
      }

      final SimpleIdentifier arg = method.argumentList.arguments.first;
      final ClassElement component = arg.bestElement;
      final ComponentMetaData metaData = extractor.extract(component);
      if (metaData == null) {
        return;
      }

      if (metaData.properties.length > 48) {
        logger.warning(
            'Invalid Component "${component.name}": '
            'Component can\'t have more than 48 properties.',
            span: getSpan(method));
      }

      visitFactoryCreateInvocation(method, component, metaData);
    } else {
      super.visitMethodInvocation(method);
    }
  }

  bool _isValidFactory(MethodInvocation method, [bool printErrors = false]) {
    if (method.parent is! VariableDeclaration ||
        method.parent.parent is! VariableDeclarationList ||
        method.parent.parent.parent is! TopLevelVariableDeclaration) {
      if (printErrors) {
        logger.error(
            'Invalid "componentFactory(componentType) invocation: '
            '"componentFactory" function should be called from top-level '
            'declarations.',
            span: getSpan(method, resolver.getSourceFile(method.methodName.bestElement)));
      }
      return false;
    }
    if (method.argumentList.arguments.isEmpty) {
      if (printErrors) {
        logger.error(
            'Invalid "componentFactory(componentType)" invocation: '
            '"componentType" argument is missing.',
            span: getSpan(method, resolver.getSourceFile(method.methodName.bestElement)));
      }
      return false;
    }

    final Expression arg = method.argumentList.arguments.first;

    if (arg is! SimpleIdentifier ||
        (arg as SimpleIdentifier).bestElement is! ClassElement) {
      if (printErrors) {
        logger.error(
            'Invalid componentFactory(componentType) invocation: '
            '"componentType" argument should have type "Type".',
            span: getSpan(method, resolver.getSourceFile(method.methodName.bestElement)));
      }
      return false;
    }

    final ClassElement component = (arg as SimpleIdentifier).bestElement;
    final InterfaceType componentType = component.type;

    if (!componentType.isAssignableTo(elements.componentType.substitute4([elements.objectType]))) {
      if (printErrors) {
        logger.error(
            'Invalid componentFactory(componentType) invocation: '
            'Component "$component" should be a subclass of the \'Component\''
            ' type.',
            span: getSpan(method, resolver.getSourceFile(method.methodName.bestElement)));
      }
      return false;
    }

    return true;
  }

  bool _missingImports() {
    if (elements.componentType == null) {
      logger.error('Cannot find "liquid.component.Component" type.');
      return true;
    }
    if (elements.propertyType == null) {
      logger.error('Cannot find "liquid.annotations.property" type.');
      return true;
    }
    return false;
  }
}
