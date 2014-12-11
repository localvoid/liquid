// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid.transformer.factory_transformer;

/// class __V${name} extends __vdom.VStaticTree {
///   ${fn.namedArgs}
///
///   __V${name}(${fn.namedArgs} + defaultArgs) : super(defaultArgs);
///
///  __vdom.VNode build() ${fn.body}
/// }
///
/// __VmyTree myTree(${fn.namedArgs} + defaultArgs) =>
///     new __VmyTree(${fn.namedArgs} + defaultArgs);
class StaticTreeFactoryGenerator extends FactoryGenerator {
  void compile(BuildLogger logger, TextEditTransaction transaction,
               TopLevelVariableDeclaration tld, SimpleIdentifier name,
               MethodInvocation method) {
    final buildFunction = method.argumentList.arguments[0];
    final parameters = buildFunction.parameters.parameters;
    final List<DefaultFormalParameter> namedArgs = [];
    for (var p in parameters) {
      if (p.kind == ParameterKind.NAMED) {
        namedArgs.add(p);
      }
    }
    final out = new StringBuffer();

    final className = '__V${name}';

    // Preamble
    out.write('\n\nclass $className extends __vdom.VStaticTree {\n');
    for (var a in namedArgs) {
      out.write('  final ${a.parameter.toSource()};\n');
    }
    out.write('\n  $className(');
    for (var a in namedArgs) {
      out.write('this.${a.identifier.toSource()}, ');
    }
    out.write(
        'Object key, List<__vdom.VNode> children, String id, Map<String, String> arguments, List<String> classes, Map<String, String> styles)\n'
            '      : super(key, children, id, arguments, classes, styles);\n\n');

    out.write('  __vdom.VNode build() ');

    transaction.edit(tld.offset, buildFunction.body.offset, out.toString());

    // Epilogue
    out.clear();
    if (buildFunction.body is ExpressionFunctionBody) {
      out.write(';');
    }
    out.write('\n  }\n');
    out.write('__V${name} ${name}({');
    for (var a in namedArgs) {
      out.write('${a.toSource()}, ');
    }
    out.write('Object key, List<__vdom.VNode> children, String id, '
        'Map<String, String> arguments, List<String> classes, '
        'Map<String, String> styles');
    out.write('}) =>\n    new __V${name}(');
    for (var a in namedArgs) {
      out.write('${a.identifier.toSource()}, ');
    }
    out.write('key, children, id, arguments, classes, styles);\n');

    transaction.edit(buildFunction.body.end, tld.end, out.toString());
  }
}
