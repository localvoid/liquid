// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid;

/// Abstract Component
abstract class Component<T extends html.Element> implements Context {
  /// Component is attached to the attached Context.
  static const attachedFlag = 1;

  /// Component is dirty and should be updated at the next frame
  static const dirtyFlag = 1 << 1;

  /// Reference to the Html Element
  final T element;

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

  /// Create a new [ComponentBase]
  ///
  /// Execution context: [Scheduler]:write
  Component(this.element, Context context, {this.flags: 0})
      : context = context,
        depth = context == null ? 0 : context.depth + 1;

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

  /// Find [e] ancestor that matches [selector].
  html.Element closest(html.Element e, String selector) {
    final sentinel = element.parent;
    do {
      if (e.matches(selector)) {
        return e;
      }
      e = e.parent;
    } while (e != null || identical(e, sentinel));

    return null;
  }

  /// Returns [Future] that completes when [domScheduler] launches write
  /// tasks for the current [Frame]
  Future writeDOM() => domScheduler.currentFrame.write(depth);

  /// Returns [Future] that completes when [domScheduler] launches read
  /// tasks for the current [Frame]
  Future readDOM() => domScheduler.currentFrame.read();

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

  /// Mark [Component] as dirty and add it to the next frame [Scheduler]:write
  /// queue.
  void invalidate() {
    if (!isDirty) {
      flags |= dirtyFlag;
      if (identical(Zone.current, domScheduler.zone)) {
        domScheduler.nextFrame.write(depth).then(_invalidatedUpdate);
      } else {
        domScheduler.zone.run(() {
          domScheduler.nextFrame.write(depth).then(_invalidatedUpdate);
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
}
