// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Annotations
library liquid.annotations;

/// List of reserved properties
const reservedProperties = const {'key': true,
                                  'children': true,
                                  'id': true,
                                  'type': true,
                                  'attributes': true,
                                  'classes': true,
                                  'styles': true};

/// Mark variable declarations as a property that can be used in virtual dom
/// nodes.
class property {
  final bool required;
  final bool immutable;

  /// When [equalCheck] is [:null:] it means that equal checking is implicit
  /// and will be automaticaly enabled for basic types: [bool], [int], [num],
  /// [double] and [String].
  final bool equalCheck;

  const property({this.required: false, this.immutable: false,
    this.equalCheck});
}
