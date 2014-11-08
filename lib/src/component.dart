// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid;

/// Raw DOM Component
abstract class Component extends ComponentBase {
  /// Execution context: [UpdateLoop]:write
  Component(html.Element element,
      ComponentBase parent,
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

  /// Add Component to the [UpdateLoop]:write queue
  void invalidate() {
    assert(element != null);
    if (!isDirty) {
      _flags |= ComponentBase.dirtyFlag;
      Scheduler.zone.run(() {
        Scheduler.write(depth).then(_update);
      });
    }
  }

  /// TODO: expose this in API in a better way.
  void _update(_) {
    if (isAttached && isDirty) {
      update();
    }
  }

  /// Emit event to the parent.
  void emit(ComponentEvent e) {
    parent.onEvent(e);
  }
}
