// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library liquid.transformer.utils;

import 'package:analyzer/src/generated/ast.dart';
import 'package:source_maps/refactor.dart' show TextEditTransaction;

/// Injects an import into the list of imports in the file.
void addImport(TextEditTransaction transaction, CompilationUnit unit,
               String uri, String prefix) {
  final last = unit.directives.where((d) => d is ImportDirective).last;
  transaction.edit(last.end, last.end, '\nimport \'$uri\' as $prefix;');
}

/// Injects a declaration at the end of the file.
void addDeclaration(TextEditTransaction transaction, CompilationUnit unit,
                    String declaration) {
  final last = unit.declarations.last;
  transaction.edit(last.end, last.end, declaration);
}
