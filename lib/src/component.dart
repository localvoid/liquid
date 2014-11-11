// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid;

/// Abstract base class for all Components
class Component implements v.Context {
  static final ROOT = new Component.root(flags: attachedFlag);

  /// Component is attached to the DOM.
  static const attachedFlag = 1;

  /// Component is dirty and should be updated in the next Update Loop
  static const dirtyFlag    = 1 << 1;

  /// Unique key
  final Object key;

  /// Component's element
  final html.Element element;

  /// Component's parent is used to establish parent-child relationship.
  final Component parent;

  /// Context
  final int depth;

  int flags;

  /// Component is attached to the DOM.
  bool get isAttached => (flags & attachedFlag) == attachedFlag;

  /// Component is dirty, and should be updated.
  bool get isDirty => (flags & dirtyFlag) == dirtyFlag;

  /// [Component] constructor
  ///
  /// Execution context: [UpdateLoop]:write
  Component(this.key, this.element, Component parent, {this.flags: 0})
      : parent = parent == null ? ROOT : parent,
        depth = parent.depth + 1;

  Component.root({this.flags: 0}) : key = 0, element = null, parent = null, depth = 0;

  void render() {}

  /// Update [Component]'s tag tree.
  void update() {
    updateFinish();
  }

  void updateFinish() {
    flags &= ~dirtyFlag;
  }

  /// Invoked when the Component is attached to the DOM.
  ///
  /// Execution context: [UpdateLoop]:write
  void attached() {
    assert(!isAttached);
    flags |= attachedFlag;
  }

  /// Invoked when the Component is detached from the DOM.
  ///
  /// Execution context: [UpdateLoop]:write
  void detached() {
    assert(isAttached);
    flags &= ~attachedFlag;
  }

  /// Find html element that is between Component's root element and [e]
  /// that matches [selector].
  ///
  /// TODO: rename?
  html.Element queryMatchingParent(html.Element e, String selector) {
    final sentinel = element.parent;
    do {
      if (e.matches(selector)) {
        return e;
      }
      e = e.parent;
    } while (e != null || identical(e, sentinel));

    return null;
  }

  /// Add Component to the [Update]:write queue
  void invalidate() {
    if (!isDirty) {
      flags |= Component.dirtyFlag;
      Scheduler.zone.run(() {
        Scheduler.nextFrame.write(depth).then(_update);
      });
    }
  }

  /// TODO: expose this in API in a better way.
  void _update(_) {
    if (isAttached && isDirty) {
      update();
    }
  }

  Future writeDOM() => Scheduler.currentFrame.write(depth);
  Future readDOM() => Scheduler.currentFrame.read();
}
