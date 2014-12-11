// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Annotations
library liquid.annotations;

/// Mark variable declarations as a property that can be used in virtual dom
/// nodes.
class property {
  final bool required;

  const property({this.required: false});
}
