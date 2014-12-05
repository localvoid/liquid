// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library liquid.transformer.factory_transformer;

import 'dart:async';
import 'dart:collection';
import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/element.dart';
import 'package:analyzer/src/generated/utilities_dart.dart';
import 'package:source_maps/refactor.dart';
import 'package:barback/barback.dart';
import 'package:code_transformers/resolver.dart';
import 'package:liquid/src/transformer/options.dart';
import 'package:liquid/src/transformer/utils.dart';
import 'package:liquid/src/transformer/liquid_elements.dart';
import 'package:liquid/src/transformer/component_meta_data.dart';

part 'package:liquid/src/transformer/factory_transformer/factory_generator.dart';
part 'package:liquid/src/transformer/factory_transformer/static_tree_factory_generator.dart';
part 'package:liquid/src/transformer/factory_transformer/dynamic_tree_factory_generator.dart';
part 'package:liquid/src/transformer/factory_transformer/component_factory_generator.dart';

class FactoryTransformer extends Transformer with ResolverTransformer {
  TransformerOptions options;

  FactoryTransformer(this.options, Resolvers resolvers) {
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

    final liquidElements = new LiquidElements(resolver);
    liquidElements.lookup(LiquidElements.allElements);

    if ((liquidElements.elementMask & LiquidElements.allElements) != LiquidElements.allElements) {
      transform.addOutput(transform.primaryInput);
      return;
    }

    final componentMetaDataExtractor = new ComponentMetaDataExtractor(liquidElements);

    // replace vdom.dart to vdom_static.dart
    for (final directive in unit.directives) {
      if (directive is ImportDirective &&
          directive.uri.stringValue == 'package:liquid/vdom.dart') {
        final uri = directive.uri;
        transaction.edit(uri.offset, uri.end, '\'package:liquid/vdom_static.dart\'');
      }
    }

    addImport(transaction, unit, 'package:liquid/vdom_static.dart', '__vdom');

    // compile factories
    final factoryGenerators = new FactoryGenerators(liquidElements, componentMetaDataExtractor);
    unit.visitChildren(new _FactoryGeneratorCompiler(transaction, factoryGenerators));

    // commit changes
    final printer = transaction.commit();
    var url = id.path.startsWith('lib/')
            ? 'package:${id.package}/${id.path.substring(4)}' : id.path;
    printer.build(url);
    transform.addOutput(new Asset.fromString(id, printer.text));
  }
}

class _FactoryGeneratorCompiler extends GeneralizingAstVisitor {
  final TextEditTransaction _transaction;
  final FactoryGenerators _factoryGenerators;

  _FactoryGeneratorCompiler(this._transaction, this._factoryGenerators);

  visitMethodInvocation(MethodInvocation m) {
    final factoryMethod = _factoryGenerators[m.methodName.bestElement];
    if (factoryMethod != null) {
      final arg = m.argumentList.arguments[0];
      final VariableDeclaration declaration = m.parent;
      final TopLevelVariableDeclaration tld = declaration.parent.parent;
      final name = declaration.name;
      factoryMethod.compile(_transaction, tld, name, arg);
    } else {
      super.visitMethodInvocation(m);
    }
  }
}
