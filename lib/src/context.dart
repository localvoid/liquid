// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid;

/// [Context] that is used to propagate information through Virtual DOM.
///
/// [Component]'s implement this interface.
abstract class Context implements v.Context {
  /// Parent is attached to the DOM
  bool get isAttached;

  /// Depth relative to other Contexts, it is used to sort write tasks by
  /// its depth, so the lowest depth have the highest priority and will
  /// be executed first.
  int get depth;
}