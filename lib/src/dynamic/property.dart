// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid.dynamic;

HashMap<Symbol, Property> _lookupProperties(Iterable<DeclarationMirror> declarations) {
  final result = new HashMap<Symbol, Property>();

  for (var d in declarations) {
    Property propertyType;
    for (var m in d.metadata) {
      if (m.reflectee is Property) {
        propertyType = m.reflectee;
        break;
      }
    }
    if (propertyType == null) {
      propertyType = const Property();
    }
    result[d.simpleName] = propertyType;
  }

  return result;
}
