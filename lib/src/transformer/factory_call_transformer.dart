// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Transformer that adds `propertyMask` to specify which properties should be
/// updated.
///
/// ```dart
/// final myComponent = componentFactory(MyComponent);
/// class MyComponent extends Component {
///   @property() int prop1;
///   @property() int prop2;
///   ...
/// }
///
/// myComponent(prop2: 10);
/// // will be transformed into:
/// myComponent(0b10, prop2: 10);
/// // 0b10 is a property mask that indicates that property with index 2 should
/// // be updated
/// ```
///
/// propertyMask is used only for optional properties (required == false).
library liquid.transformer.factory_call_transformer;

import 'dart:async';
import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/element.dart';
import 'package:source_maps/refactor.dart';
import 'package:barback/barback.dart';
import 'package:code_transformers/resolver.dart';
import 'package:liquid/src/transformer/liquid_elements.dart';
import 'package:liquid/src/transformer/options.dart';
import 'package:liquid/src/transformer/component_meta_data.dart';
import 'package:liquid/src/annotations.dart' show reservedProperties;

class FactoryCallTransformer extends Transformer with ResolverTransformer {
  TransformerOptions options;

  FactoryCallTransformer(this.options, Resolvers resolvers) {
    this.resolvers = resolvers;
  }

  Future<bool> isPrimary(AssetId assetId) {
    if (assetId.extension != '.dart') {
      return new Future.value(false);
    }
    if (assetId.package == 'liquid' && assetId.path.startsWith('lib')) {
      return new Future.value(false);
    }
    return new Future.value(true);
  }

  Future<bool> shouldApplyResolver(Asset asset) => new Future.value(true);

  void applyResolver(Transform transform, Resolver resolver) {
    final asset = transform.primaryInput;
    final id = asset.id;
    final lib = resolver.getLibrary(id);
    final transaction = resolver.createTextEditTransaction(lib);
    final unit = lib.definingCompilationUnit.node;

    for (final directive in unit.directives) {
      if (directive is PartOfDirective) {
        transform.addOutput(transform.primaryInput);
        return;
      }
    }


    final liquidElements = new LiquidElements(resolver);

    final lookupFlags = LiquidElements.propertyClassFlag |
                        LiquidElements.componentClassFlag |
                        LiquidElements.vComponentClassFlag;

    liquidElements.lookup(lookupFlags);

    if ((liquidElements.elementMask & lookupFlags) != lookupFlags) {
      transform.addOutput(transform.primaryInput);
      return;
    }

    final metaDataExtractor =
        new ComponentMetaDataExtractor(liquidElements);

    unit.visitChildren(new _FactoryCallVisitor(
        transaction,
        unit,
        liquidElements,
        metaDataExtractor));

    var result = transform.primaryInput;

    if (transaction.hasEdits) {
      final printer = transaction.commit();
      final url = id.path.startsWith('lib/')
          ? 'package:${id.package}/${id.path.substring(4)}' :
            id.path;
      printer.build(url);
      result = new Asset.fromString(id, printer.text);
    }

    transform.addOutput(result);
  }
}

class _FactoryCallVisitor extends GeneralizingAstVisitor {
  final TextEditTransaction _transaction;
  final _unit;
  final LiquidElements _liquidElements;
  final ComponentMetaDataExtractor _metaDataExtractor;

  _FactoryCallVisitor(this._transaction, this._unit, this._liquidElements,
      this._metaDataExtractor);

  visitMethodInvocation(MethodInvocation m) {
    if (m.bestType != null &&
        !m.bestType.isVoid &&
        !m.bestType.isDynamic &&
        m.bestType.isSubtypeOf(_liquidElements.vComponentClass.type)) {
      final ClassElement cls = m.bestType.element;
      final metaData = _metaDataExtractor.extractFromVComponent(cls);
      if (metaData.properties.isNotEmpty && metaData.isPropertyMask) {
        if (m.argumentList.arguments.isEmpty) {
          _transaction.edit(m.argumentList.offset + 1,
              m.argumentList.offset + 1,
              '0');
        } else {
          int propertyMask = 0;
          for (var arg in m.argumentList.arguments) {
            final argName = arg.bestParameterElement.name;
            if (!reservedProperties.containsKey(argName)) {
              propertyMask |= 1 << metaData.properties[arg.bestParameterElement.name].index;
            }
          }
          _transaction.edit(m.argumentList.offset + 1,
              m.argumentList.offset + 1,
              '$propertyMask, ');
        }
      }
    } else {
      super.visitMethodInvocation(m);
    }
  }
}
