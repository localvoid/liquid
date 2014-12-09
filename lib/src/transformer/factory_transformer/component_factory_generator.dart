// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid.transformer.factory_transformer;

// TODO: use 0 as a default value for properties with number types

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
class ComponentFactoryGenerator extends FactoryGenerator {
  final LiquidElements _elements;
  final ComponentMetaDataExtractor _extractor;

  ComponentFactoryGenerator(this._elements, this._extractor);

  void compile(TextEditTransaction transaction, TopLevelVariableDeclaration tld,
               SimpleIdentifier name, SimpleIdentifier type) {
    final ClassElement component = type.bestElement;
    final metaData = _extractor.extract(component);

    final className = '__V${name}';

    final out = new StringBuffer();

    // VComponent
    out.write('\n\nclass $className extends __vdom.VComponentBase {\n');

    // properties
    if (metaData.properties.isNotEmpty) {
      out.write('  final int propertyMask;\n');
      for (var a in metaData.properties) {
        out.write('  @property final ${a.name};\n');
      }
      out.write('\n');
    }

    // constructor
    out.write('  $className(');
    if (metaData.properties.isNotEmpty) {
      out.write('this.propertyMask, ');
      for (var a in metaData.properties) {
        out.write('this.${a.name}, ');
      }
    }
    out.write(
        'Object key, List<__vdom.VNode> children, String id, Map<String, String> arguments, List<String> classes, Map<String, String> styles)\n'
            '      : super(key, children, id, arguments, classes, styles);\n\n');

    // create()
    out.write('  void create(__vdom.Context context) {\n');
    out.write('    component = new ${type}();\n');
    out.write('    component.context = context;\n');
    for (var i = 0; i < metaData.properties.length; i++) {
      final property = metaData.properties[i];
      final flag = 1 << i;
      out.write('    if ((propertyMask & $flag) == $flag) {\n');
      out.write('      component.${property.name} = ${property.name};\n');
      out.write('    }\n');
    }
    out.write('    component.create();\n');
    out.write('    ref = component.element;\n');
    out.write('    component.dirty = true;\n');
    out.write('  }\n\n');

    // update()
    if (metaData.properties.isNotEmpty) {
      out.write('  void update($className other, __vdom.Context context) {\n');
      out.write('    super.update(other, context);\n');
      for (var i = 0; i < metaData.properties.length; i++) {
        final property = metaData.properties[i];
        final flag = 1 << i;
        out.write('    if ((other.propertyMask & $flag) == $flag) {\n');
        out.write('      component.${property.name} = other.${property.name};\n');
        out.write('    }\n');
      }
      out.write('    component.dirty = true;\n');
      out.write('    component.internalUpdate();\n');
      out.write('  }\n\n');
    }

    out.write('\n}\n');
    // end of VComponent

    // factory
    out.write('__V${name} ${name}(');
    if (metaData.properties.isNotEmpty) {
      out.write('int propertyMask, {');
      for (var a in metaData.properties) {
        out.write('${a.name}, ');
      }
    } else {
      out.write('{');
    }
    out.write('Object key, List<__vdom.VNode> children, String id, '
        'Map<String, String> arguments, List<String> classes, '
        'Map<String, String> styles');
    out.write('}) =>\n    new __V${name}(');
    if (metaData.properties.isNotEmpty) {
      out.write('propertyMask, ');
      for (var a in metaData.properties) {
        out.write('${a.name}, ');
      }
    }
    out.write('key, children, id, arguments, classes, styles);\n');

    transaction.edit(tld.offset, tld.end, out.toString());
  }
}
