// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid;

/// Basic Component, that doesn't implement any method to render,
/// or update its subtree.
abstract class Component implements Context {
  /// Component is attached to the DOM.
  static const attachedFlag = 1;

  /// Component is dirty and should be updated in the next Update Loop
  static const dirtyFlag    = 1 << 1;

  /// Reference to the Html Element
  final html.Element element;

  /// Parent context
  final Context context;

  /// Depth relative to other contexts
  final int depth;

  /// Flags: [attachedFlag], [dirtyFlag]
  int flags;

  /// Component is attached to the DOM.
  bool get isAttached => (flags & attachedFlag) == attachedFlag;

  /// Component is dirty, and should be updated.
  bool get isDirty => (flags & dirtyFlag) == dirtyFlag;

  /// Create a new [Component]
  ///
  /// It is necessary to create [element] in the constructor, so that we can
  /// create real DOM Element as soon as possible and place it as a placeholder
  /// into the DOM.
  ///
  /// This way we can stop at any point in [update()] method and perform
  /// any async operation.
  ///
  /// Execution context: [Scheduler]:write
  Component(this.element,
      Context context,
      {this.flags: 0})
      : context = context,
        depth = context == null ? 0 : context.depth + 1;

  /// Lifecycle method that is called when [Component] is rendered for
  /// the first time.
  ///
  /// Execution context: [Scheduler]:write
  void render();

  /// Lifecycle method that is called when [Component] should be updated.
  ///
  /// Execution context: [Scheduler]:write
  void update();

  /// This method should be called when [Component] is finished updating.
  ///
  /// Execution context: [Scheduler]:write or [Scheduler]:read
  void updateFinish() {
    flags &= ~dirtyFlag;
  }

  /// Invoked when the Component is attached to the DOM.
  ///
  /// Execution context: [Scheduler]:write
  void attached() {
    assert(!isAttached);
    flags |= attachedFlag;
  }

  /// Invoked when the Component is detached from the DOM.
  ///
  /// Execution context: [Scheduler]:write
  void detached() {
    assert(isAttached);
    flags &= ~attachedFlag;
  }

  /// Find html element that is between Component's [element] and argument
  /// [e] that matches [selector].
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

  /// Mark [Component] as dirty and add it to the next frame [Scheduler]:write
  /// queue.
  void invalidate() {
    if (!isDirty) {
      flags |= Component.dirtyFlag;
      if (identical(Zone.current, Scheduler.zone)) {
        Scheduler.nextFrame.write(depth).then(_invalidatedUpdate);
      } else {
        Scheduler.zone.run(() {
          Scheduler.nextFrame.write(depth).then(_invalidatedUpdate);
        });
      }
    }
  }

  bool shouldComponentUpdate() => (isAttached && isDirty);

  void _invalidatedUpdate(_) {
    if (shouldComponentUpdate()) {
      update();
    }
  }

  /// Returns [Future] that completes when [Scheduler] launches write
  /// tasks for the current [Frame]
  Future writeDOM() => Scheduler.currentFrame.write(depth);

  /// Returns [Future] that completes when [Scheduler] launches read
  /// tasks for the current [Frame]
  Future readDOM() => Scheduler.currentFrame.read();
}
