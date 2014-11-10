// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid;

/// Raw DOM Component
abstract class Component extends ComponentBase {
  static final ROOT = new RootComponent();

  /// Execution context: [Update]:write
  Component(Object key, html.Element element, ComponentBase parent, {int flags: 0})
      : super(key, element, parent, parent.depth + 1, flags: flags) {
    assert(parent != null);
  }

  /// Add Component to the [Update]:write queue
  void invalidate() {
    if (!isDirty) {
      flags |= ComponentBase.dirtyFlag;
      Scheduler.zone.run(() {
        writeDOM().then(_update);
      });
    }
  }

  /// TODO: expose this in API in a better way.
  void _update(_) {
    if (isAttached && isDirty) {
      update();
    }
  }

  Future writeDOM() => Scheduler.write(depth);
  Future readDOM() => Scheduler.read();
}
