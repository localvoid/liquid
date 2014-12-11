// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// TODO: fix error when only vdom library is imported

/// Transformer that compiles [staticTreeFactory], [dynamicTreeFactory] and
/// [componentFactory] invocations into static and optimized classes that can
/// be used without mirror-based apis.
library liquid.transformer.factory_transformer;

import 'dart:async';
import 'dart:collection';
import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/element.dart';
import 'package:analyzer/src/generated/utilities_dart.dart';
import 'package:source_maps/refactor.dart';
import 'package:barback/barback.dart';
import 'package:code_transformers/resolver.dart';
import 'package:code_transformers/messages/build_logger.dart';
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
    final unit = lib.definingCompilationUnit.node;

    final liquidElements = new LiquidElements(resolver);

    // lookup for factory generator functions, if they're not found, then
    // skip processing this file.
    final requiredElements = LiquidElements.staticTreeFactoryFlag |
                             LiquidElements.dynamicTreeFactoryFlag |
                             LiquidElements.componentFactoryFlag;
    liquidElements.lookup(requiredElements);

    if ((liquidElements.elementMask & requiredElements) != requiredElements) {
      transform.addOutput(transform.primaryInput);
      return;
    }

    final buildLogger = new BuildLogger(transform);
    final transaction = resolver.createTextEditTransaction(lib);

    // lookup for Property and Component classes
    liquidElements.lookup(LiquidElements.propertyClassFlag |
                          LiquidElements.componentClassFlag);

    final componentMetaDataExtractor =
        new ComponentMetaDataExtractor(liquidElements);

    // replace vdom.dart to vdom_static.dart
    // and remove part directives (all parts injected into library file)
    // TODO: migrate to aggregate transformers and get rid of parts injecting
    for (final directive in unit.directives) {
      if (directive is ImportDirective &&
          directive.uri.stringValue == 'package:liquid/vdom.dart') {
        final uri = directive.uri;
        transaction.edit(uri.offset, uri.end, '\'package:liquid/vdom_static.dart\'');
      } else if (directive is PartDirective) {
        transaction.edit(directive.offset, directive.end, '');
      }
    }

    if (lib.importedLibraries.isNotEmpty) {
      addImport(transaction, unit, 'package:liquid/vdom_static.dart', '__vdom');
    }

    // compile factories
    final factoryGenerators =
        new FactoryGenerators(liquidElements, componentMetaDataExtractor);

    final url = id.path.startsWith('lib/')
        ? 'package:${id.package}/${id.path.substring(4)}' : id.path;

    for (final part in lib.parts) {
      final partTransaction = resolver.createTextEditTransaction(part);
      for (final directive in part.unit.directives) {
        if (directive is PartOfDirective) {
          partTransaction.edit(directive.offset, directive.end, '');
        }
      }
      part.unit.visitChildren(
          new _FactoryGeneratorCompiler(
              buildLogger,
              partTransaction,
              factoryGenerators));

      final printer = partTransaction.commit();
      printer.build(url);
      final end = unit.directives.last.end;
      transaction.edit(end, end, printer.text);
    }

    unit.visitChildren(
        new _FactoryGeneratorCompiler(
            buildLogger,
            transaction,
            factoryGenerators));

    // commit changes
    final printer = transaction.commit();
    printer.build(url);
    transform.addOutput(new Asset.fromString(id, printer.text));
  }
}

class _FactoryGeneratorCompiler extends GeneralizingAstVisitor {
  final BuildLogger _logger;
  final TextEditTransaction _transaction;
  final FactoryGenerators _factoryGenerators;

  _FactoryGeneratorCompiler(this._logger, this._transaction,
      this._factoryGenerators);

  visitMethodInvocation(MethodInvocation method) {
    final factoryMethod = _factoryGenerators[method.methodName.bestElement];
    if (factoryMethod != null) {
      if (method.parent is! VariableDeclaration) {
        _logger.error(
            'Factory Generator functions should be called from top-level'
            'declarations in "final myFactory = factory(args);" format.');
        return;
      }
      final VariableDeclaration declaration = method.parent;

      if (declaration.parent.parent is! TopLevelVariableDeclaration) {
        _logger.error(
            'Factory Generator functions should be called from top-level'
            'declarations in "final myFactory = factory(args);" format.');
        return;
      }
      final TopLevelVariableDeclaration tld = declaration.parent.parent;

      final name = declaration.name;
      factoryMethod.compile(_logger, _transaction, tld, name, method);
    } else {
      super.visitMethodInvocation(method);
    }
  }
}
