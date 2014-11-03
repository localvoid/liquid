// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid;

abstract class Component extends ComponentBase {
  /// MainLoop state: DomWrite
  Component(ComponentBase parent,
      html.Element element,
      {Object key: null,
       Symbol type: null,
       int flags: 0})
      : super(element,
          parent: parent,
          key: key,
          type: type,
          depth: parent.depth + 1,
          flags: flags) {
    assert(parent != null);
  }

  /// Mark Component as a dirty.
  void invalidate() {
    assert(element != null);

    if (!isDirty) {
      _flags &= ~ComponentBase.cleanFlag;
      UpdateLoop.write(depth, _update);
    }
  }

  void _update() {
    if (isAttached && isDirty) {
      update();
    }
  }

  /// Emit event to parent
  void emit(ComponentEvent e) {
    parent.onEvent(e);
  }
}
