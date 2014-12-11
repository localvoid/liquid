// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid.dynamic;

/// Lookup for all declarations with `@property` annotations.
Map<Symbol, property> _lookupProperties(Iterable<DeclarationMirror> declarations,
    [bool allProperties = true, property defaultProperty = const property()]) {
  final result = new HashMap<Symbol, property>();

  for (var d in declarations) {
    property propertyType;
    for (var m in d.metadata) {
      if (m.reflectee is property) {
        propertyType = m.reflectee;
        break;
      }
    }
    if (allProperties && propertyType == null) {
      propertyType = defaultProperty;
    }
    if (propertyType != null) {
      result[d.simpleName] = propertyType;
    }
  }

  return result;
}
