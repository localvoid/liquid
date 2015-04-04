// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library liquid.transformer.compiler;

import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/element.dart';
import 'package:code_transformers/resolver.dart';
import 'package:code_transformers/messages/build_logger.dart';
import 'package:source_maps/refactor.dart';
import 'package:liquid/src/transformer/liquid_elements.dart';
import 'package:liquid/src/transformer/component_meta_data.dart';
import 'package:liquid/src/transformer/linter.dart';
import 'package:liquid/src/annotations.dart' show reservedProperties;
import 'package:source_span/source_span.dart';

class CompilerVisitor extends LinterVisitor {
  final TextEditTransaction transaction;

  CompilerVisitor(
      BuildLogger logger,
      Resolver resolver,
      LiquidElements elements,
      ComponentMetaDataExtractor extractor,
      SourceFile sourceFile,
      this.transaction)
      : super(logger, resolver, elements, extractor, sourceFile);

  void visitFactoryCallInvocation(MethodInvocation method,
                                  ClassElement componentClass,
                                  ComponentMetaData componentMetaData) {
    if (componentMetaData.properties.isNotEmpty &&
        componentMetaData.isPropertyMask) {
      final offset = method.argumentList.offset + 1;
      if (method.argumentList.arguments.isEmpty) {
        transaction.edit(offset, offset, '0');
      } else {
        int propertyMask = 0;
        for (final arg in method.argumentList.arguments) {
          final argName = arg.name.label.name;
          if (!reservedProperties.containsKey(argName) &&
              componentMetaData.properties.containsKey(argName)) {
            final propertyData = componentMetaData.properties[argName];
            if (!propertyData.required) {
              propertyMask |= 1 << propertyData.index;
            }
          }
        }
        transaction.edit(offset, offset, '$propertyMask, ');
      }
    }
  }

  void visitFactoryCreateInvocation(MethodInvocation method,
                                    ClassElement componentClass,
                                    ComponentMetaData componentMetaData) {
    final VariableDeclaration declaration = method.parent;
    final TopLevelVariableDeclaration tld = declaration.parent.parent;
    final name = declaration.name;
    final arg = method.argumentList.arguments.first;

    final result = _compileFactory(name, arg, componentMetaData);
    if (result != null) {
      transaction.edit(tld.offset, tld.end, result);
    }
  }

  String _compileFactory(SimpleIdentifier name,
                         SimpleIdentifier componentIdentifier,
                         ComponentMetaData metaData) {
    final out = new StringBuffer();

    _writeVComponent(out, name.name, componentIdentifier.name, metaData);
    _writeFactoryFunction(out, name.name, metaData);

    return out.toString();
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
        'Object key, List<__vdom.VNode> children, String id, String type, Map<String, String> attributes, List<String> classes, Map<String, String> styles)\n'
            '      : super(key, children, id, type, attributes, classes, styles);\n\n');

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
        'Map<String, String> attributes, List<String> classes, '
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
    out.write('key, children, id, type, attributes, classes, styles);\n');
  }
}
