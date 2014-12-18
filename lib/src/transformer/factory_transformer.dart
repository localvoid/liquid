// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// TODO: get rid of "__vdom", "__liquid" imports.
// TODO: componentFactory invocation should work when Component is declared in
//       imported library.

/// Transformer that compiles [componentFactory] invocations into static and
/// optimized objects that can be used without mirror-based apis, and adds
/// property masks to factory invocations to specify which properties should
/// be updated.
///
/// In Development Mode Transformer works as a linter tool.
///
/// propertyMask is used only for optional properties (required == false).
library liquid.transformer.factory_transformer;

import 'dart:async';
import 'package:analyzer/src/generated/ast.dart';
import 'package:barback/barback.dart';
import 'package:code_transformers/resolver.dart';
import 'package:code_transformers/messages/build_logger.dart';
import 'package:liquid/src/transformer/options.dart';
import 'package:liquid/src/transformer/utils.dart';
import 'package:liquid/src/transformer/liquid_elements.dart';
import 'package:liquid/src/transformer/component_meta_data.dart';
import 'package:liquid/src/transformer/linter.dart';
import 'package:liquid/src/transformer/compiler.dart';

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

  Future<bool> shouldApplyResolver(Asset asset) => isNotPartOf(asset);

  void applyResolver(Transform transform, Resolver resolver) {
    final asset = transform.primaryInput;
    final id = asset.id;
    final lib = resolver.getLibrary(id);
    final unit = lib.definingCompilationUnit.node;

    final liquidElements = new LiquidElements(resolver);

    final requiredElements = LiquidElements.componentFactoryFlag |
                             LiquidElements.vGenericComponentFactoryFlag;
    if ((liquidElements.elementMask & requiredElements) != requiredElements) {
      transform.addOutput(transform.primaryInput);
      return;
    }

    final logger = new BuildLogger(transform);
    final metaDataExtractor =
        new ComponentMetaDataExtractor(logger, resolver, liquidElements);

    if (!options.applyCodeTransformations) {
      for (final part in lib.parts) {
        final partTransaction = resolver.createTextEditTransaction(part);
        part.unit.visitChildren(new LinterVisitor(logger, resolver,
            liquidElements, metaDataExtractor,
            resolver.getSourceFile(part.unit.element)));
      }
      unit.visitChildren(new LinterVisitor(logger, resolver,
          liquidElements, metaDataExtractor, resolver.getSourceFile(unit.element)));

      transform.addOutput(transform.primaryInput);

    } else {
      final transaction = resolver.createTextEditTransaction(lib);

      // replace vdom.dart to vdom_static.dart
      // and remove part directives (all parts injected into library file)
      for (final directive in unit.directives) {
        if (directive is ImportDirective &&
            directive.uri.stringValue == 'package:liquid/vdom.dart') {
          final uri = directive.uri;
          transaction.edit(uri.offset, uri.end, '\'package:liquid/vdom_static.dart\'');
        }
      }

      final url = id.path.startsWith('lib/') ?
          'package:${id.package}/${id.path.substring(4)}' :
          id.path;

      for (final part in lib.parts) {
        final partTransaction = resolver.createTextEditTransaction(part);
        part.unit.visitChildren(new CompilerVisitor(logger, resolver,
            liquidElements, metaDataExtractor,
            resolver.getSourceFile(part.unit.element), partTransaction));

        if (partTransaction.hasEdits) {
          final PartOfDirective partOfDirective =
              part.unit.directives.firstWhere((d) => (d is PartOfDirective));

          final PartDirective partDirective =
              unit.directives.firstWhere((d) => (d is PartDirective &&
                                                 d.uri.stringValue == part.uri));

          partTransaction.edit(partOfDirective.offset, partOfDirective.end, '');
          transaction.edit(partDirective.offset, partDirective.end, '');

          final printer = partTransaction.commit();
          printer.build(url);
          final offset = unit.end;
          transaction.edit(offset, offset, '\n\n${printer.text}');
        }
      }

      unit.visitChildren(new CompilerVisitor(logger, resolver,
          liquidElements, metaDataExtractor, resolver.getSourceFile(unit.element),
          transaction));

      // commit changes
      var result = transform.primaryInput;
      if (transaction.hasEdits) {
        addImport(transaction, unit, 'package:liquid/liquid.dart', '__liquid');
        addImport(transaction, unit, 'package:liquid/vdom_static.dart', '__vdom');

        final printer = transaction.commit();
        printer.build(url);
        result = new Asset.fromString(id, printer.text);
      }

      transform.addOutput(result);
    }
  }
}
