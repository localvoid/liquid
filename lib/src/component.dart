// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid;

/// Abstract Component
abstract class Component<T extends html.Element> extends ComponentBase<T> {
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
  Component(T node,
      Context context,
      {int flags: 0})
      : super(node, context, flags: flags);

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
    flags &= ~ComponentBase.dirtyFlag;
  }

  /// Mark [Component] as dirty and add it to the next frame [Scheduler]:write
  /// queue.
  void invalidate() {
    if (!isDirty) {
      flags |= ComponentBase.dirtyFlag;
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
