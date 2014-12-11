// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid.dynamic;

/// Lookup for all declarations with `@property` annotations.
Map<Symbol, Property> _lookupProperties(Iterable<DeclarationMirror> declarations,
    [bool allProperties = true]) {
  final result = new HashMap<Symbol, Property>();

  for (var d in declarations) {
    Property propertyType;
    for (var m in d.metadata) {
      if (m.reflectee is Property) {
        propertyType = m.reflectee;
        break;
      }
    }
    if (allProperties && propertyType == null) {
      propertyType = const Property();
    }
    if (propertyType != null) {
      result[d.simpleName] = propertyType;
    }
  }

  return result;
}
