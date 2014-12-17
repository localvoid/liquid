// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// TODO: get rid of "__vdom", "__liquid" imports.
// TODO: componentFactory invocation should work when Component is declared in
//       imported library.
// TODO: migrate to aggregate transformers and get rid of the inject parts hack.
// TODO: use resolver.getSourceSpan(element) when printing errors

/// Transformer that compiles [componentFactory] invocations into static and
/// optimized objects that can be used without mirror-based apis.
library liquid.transformer.factory_transformer;

import 'dart:async';
import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/element.dart';
import 'package:source_maps/refactor.dart';
import 'package:barback/barback.dart';
import 'package:code_transformers/resolver.dart';
import 'package:code_transformers/messages/build_logger.dart';
import 'package:liquid/src/transformer/options.dart';
import 'package:liquid/src/transformer/utils.dart';
import 'package:liquid/src/transformer/liquid_elements.dart';
import 'package:liquid/src/transformer/component_meta_data.dart';

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

  Future<bool> shouldApplyResolver(Asset asset) => isLibraryEntry(asset);

  void applyResolver(Transform transform, Resolver resolver) {
    final asset = transform.primaryInput;
    final id = asset.id;
    final lib = resolver.getLibrary(id);
    final unit = lib.definingCompilationUnit.node;

    final liquidElements = new LiquidElements(resolver);

    // lookup for componentFactory() function, if it isn't imported, then
    // just ignore this library.
    final requiredElements = LiquidElements.componentFactoryFlag;
    liquidElements.lookup(requiredElements);

    if ((liquidElements.elementMask & requiredElements) != requiredElements) {
      transform.addOutput(transform.primaryInput);
      return;
    }

    final logger = new BuildLogger(transform);
    final transaction = resolver.createTextEditTransaction(lib);

    // lookup for Property and Component classes
    liquidElements.lookup(LiquidElements.propertyClassFlag |
                          LiquidElements.componentClassFlag);

    final metaDataExtractor =
        new ComponentMetaDataExtractor(liquidElements);

    // replace vdom.dart to vdom_static.dart
    // and remove part directives (all parts injected into library file)
    for (final directive in unit.directives) {
      if (directive is ImportDirective &&
          directive.uri.stringValue == 'package:liquid/vdom.dart') {
        final uri = directive.uri;
        transaction.edit(uri.offset, uri.end, '\'package:liquid/vdom_static.dart\'');
      } else if (directive is PartDirective) {
        transaction.edit(directive.offset, directive.end, '');
      }
    }

    final url = id.path.startsWith('lib/') ?
        'package:${id.package}/${id.path.substring(4)}' :
        id.path;

    if (unit.directives.isNotEmpty) {
      addImport(transaction, unit, 'package:liquid/liquid.dart', '__liquid');
      addImport(transaction, unit, 'package:liquid/vdom_static.dart', '__vdom');
    }

    for (final part in lib.parts) {
      final partTransaction = resolver.createTextEditTransaction(part);
      for (final directive in part.unit.directives) {
        if (directive is PartOfDirective) {
          partTransaction.edit(directive.offset, directive.end, '');
        }
      }
      part.unit.visitChildren(
          new _FactoryCompiler(logger, liquidElements, metaDataExtractor,
              partTransaction, unit));

      final printer = partTransaction.commit();
      printer.build(url);
      final end = unit.directives.last.end;
      transaction.edit(end, end, printer.text);
    }

    unit.visitChildren(
        new _FactoryCompiler(logger, liquidElements, metaDataExtractor,
            transaction, unit));

    // commit changes
    final printer = transaction.commit();
    printer.build(url);
    transform.addOutput(new Asset.fromString(id, printer.text));
  }
}

class _FactoryCompiler extends GeneralizingAstVisitor {
  final BuildLogger _logger;
  final LiquidElements _elements;
  final ComponentMetaDataExtractor _extractor;
  final TextEditTransaction _transaction;
  final CompilationUnit _unit;
  bool _imported = false;

  _FactoryCompiler(this._logger, this._elements, this._extractor,
      this._transaction, this._unit);

  visitMethodInvocation(MethodInvocation method) {
    if (method.methodName.bestElement == _elements.componentFactory) {
      if (_elements.componentClass == null) {
        _logger.error(
            'Invalid "componentFactory(componentType)" invocation: '
            'Cannot find "liquid.component.Component" class.');
        return;
      }
      if (_elements.propertyClass == null) {
        _logger.error(
            'Invalid "componentFactory(componentType)" invocation: '
            'Cannot find "liquid.annotations.property" class.');
        return;
      }
      if (method.parent is! VariableDeclaration ||
          method.parent.parent is! VariableDeclarationList ||
          method.parent.parent.parent is! TopLevelVariableDeclaration) {
        _logger.error(
            'Invalid "componentFactory(componentType) invocation: '
            '"componentFactory" function should be called from top-level '
            'declarations.');
        return;
      }
      if (method.argumentList.arguments.isEmpty) {
        _logger.error(
            'Invalid "componentFactory(componentType)" invocation: '
            '"componentType" argument is missing.');
        return;
      }

      final arg = method.argumentList.arguments.first;

      if (arg is! SimpleIdentifier ||
          arg.bestElement is! ClassElement) {
        _logger.error(
            'Invalid componentFactory(componentType) invocation: '
            '"componentType" argument should have type "Type".');
        return;
      }

      final VariableDeclaration declaration = method.parent;
      final TopLevelVariableDeclaration tld = declaration.parent.parent;
      final name = declaration.name;
      final component = arg.bestElement;

      final metaData = _extractor.extractFromComponent(component);
      if (metaData.properties.length > 48) {
        _logger.error(
            'Invalid Component "${component.name}" '
            'Component can\'t have more than 48 properties.');
        return;
      }
      if (metaData.properties.length > 32) {
        _logger.info(
            'Component "${component.name}" have more than 32 properties, '
            'it is recommended to reduce the number of properties.');
      }

      final result = _compile(name, arg, metaData);
      if (result != null) {
        _transaction.edit(tld.offset, tld.end, result);
      }
    } else {
      super.visitMethodInvocation(method);
    }
  }

  ///   class __V${name} extends __vdom.VComponentBase {
  ///   final int propertyMask;
  ///   ${fn.namedArgs}
  ///
  ///   __V${name}(this.propertyMask, ${fn.namedArgs} + defaultArgs) : super(propertyMask, defaultArgs);
  ///
  ///   void create(__vdom.Context context) {
  ///     component = new ${componentType}();
  ///     component.context = context;
  ///
  ///     if (propertyMask & 1) {
  ///       component.prop1 = prop1;
  ///     }
  ///     if (propertyMask & (1 << 1)) {
  ///       component.prop2 = prop2;
  ///     }
  ///     ...
  ///
  ///     component.create();
  ///     ref = component.element;
  ///   }
  ///
  ///   void update(__V${name} other, __vdom.Context context) {
  ///     super.update(other, context);
  ///     other.component = component;
  ///
  ///     if (propertyMask & 1) {
  ///       component.prop1 = prop1;
  ///     }
  ///     if (propertyMask & (1 << 1)) {
  ///       component.prop2 = prop2;
  ///     }
  ///     ...
  ///
  ///     component.dirty = true;
  ///     component.internalUpdate();
  ///   }
  /// }
  ///
  String _compile(SimpleIdentifier name, SimpleIdentifier componentIdentifier,
                  ComponentMetaData metaData) {
    final out = new StringBuffer();

    _writeVComponent(out, name.name, componentIdentifier.name, metaData);
    _writeFactoryFunction(out, name.name, metaData);

    return out.toString();
  }

  void _writePropertyAnnotation(StringBuffer out, PropertyMetaData annotation) {
    out.write('@__liquid.property(');
    final props = [];
    if (annotation.required) {
      props.add('required: true');
    }
    if (annotation.immutable) {
      props.add('immutable: true');
    }
    if (annotation.equalCheck != null){
      props.add('equalCheck: ${annotation.equalCheck}');
    }
    out.write(props.join(', '));
    out.write(')');
  }

  void _writeVComponent(StringBuffer out, String name, String componentType,
                        ComponentMetaData metaData) {
    final className = '__V$name';

    out.write('\n\nclass $className extends __vdom.VComponent {\n');

    // properties
    if (metaData.properties.isNotEmpty) {
      if (metaData.isPropertyMask) {
        out.write('  final int propertyMask;\n\n');
      }
      metaData.properties.forEach((p, meta) {
        out.write('  ');
        _writePropertyAnnotation(out, meta);
        out.write('\n');
        out.write('  final ${meta.type.name} $p;\n\n');
      });
    }

    // constructor
    out.write('  $className(');
    if (metaData.properties.isNotEmpty) {
      if (metaData.isPropertyMask) {
        out.write('this.propertyMask, ');
      }
      for (var p in metaData.properties.keys) {
        out.write('this.$p, ');
      }
    }
    out.write(
        'Object key, List<__vdom.VNode> children, String id, String type, Map<String, String> arguments, List<String> classes, Map<String, String> styles)\n'
            '      : super(key, children, id, type, arguments, classes, styles);\n\n');

    // create()
    out.write('  void create(__vdom.Context context) {\n');
    out.write('    component = new ${componentType}();\n');
    out.write('    component.context = context;\n');
    metaData.properties.forEach((p, meta) {
      if (meta.required) {
        out.write('    component.$p = $p;\n');
      } else {
        final flag = 1 << meta.index;
        out.write('    if ((propertyMask & $flag) == $flag) {\n');
        out.write('      component.$p = $p;\n');
        out.write('    }\n');
      }
    });
    out.write('    component.create();\n');
    out.write('    ref = component.element;\n');
    out.write('    component.dirty = true;\n');
    out.write('  }\n\n');

    //   update()
    if (!metaData.isImmutable) {
      if (metaData.properties.isNotEmpty) {
        out.write('  void update($className other, __vdom.Context context) {\n');
        out.write('    super.update(other, context);\n');
        if (metaData.isOptimizable) {
          out.write('    bool dirty = false;\n');
        }
        metaData.properties.forEach((p, meta) {
          if (!meta.immutable) {
            if (metaData.isOptimizable && meta.equalCheck) {
              out.write('    if (component.$p != other.$p) {\n');
            }
            if (meta.required) {
              out.write('      component.$p = other.$p;\n');
            } else {
              final flag = 1 << meta.index;
              out.write('      if ((other.propertyMask & $flag) == $flag) {\n');
              out.write('        component.$p = other.$p;\n');
              out.write('      }\n');
            }
            if (metaData.isOptimizable && meta.equalCheck) {
              out.write('      dirty = true;\n');
              out.write('    }\n');
            }
          }
        });
        if (metaData.isOptimizable) {
          out.write('    if (dirty) {\n');
        }
        out.write('      component.dirty = true;\n');
        out.write('      component.internalUpdate();\n');
        if (metaData.isOptimizable) {
          out.write('    }\n');
        }
        out.write('  }\n\n');
      }
    }

    out.write('\n}\n');
  }

  void _writeFactoryFunction(StringBuffer out,
                             String name,
                             ComponentMetaData metaData) {
    out.write('__V$name $name(');
    if (metaData.properties.isNotEmpty) {
      if (metaData.isPropertyMask) {
        out.write('int propertyMask, ');
      }
      out.write('{');
      metaData.properties.forEach((p, meta) {
        out.write('${meta.type.name} $p, ');
      });
    } else {
      out.write('{');
    }
    out.write(
        'Object key, List<__vdom.VNode> children, String id, String type, '
        'Map<String, String> arguments, List<String> classes, '
        'Map<String, String> styles');
    out.write('}) =>\n    new __V$name(');
    if (metaData.properties.isNotEmpty) {
      if (metaData.isPropertyMask) {
        out.write('propertyMask, ');
      }
      for (final p in metaData.properties.keys) {
        out.write('$p, ');
      }
    }
    out.write('key, children, id, type, arguments, classes, styles);\n');
  }
}
