// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid;

/// Component that support rendering and updating with Virtual DOM.
///
/// ```
/// class MyComponent extends Component<html.DivElement> {
///   MyComponent(Context context) : super(new html.DivElement(), context);
///
///   RootElement build() => new RootElement([vdom.t('Hello VComponent')]);
/// }
/// ```
///
/// If you want to read from the DOM, just override [update] method and
/// call [updateFinish] when you finish updating:
///
/// ```
/// class MyComponent extends Component<html.DivElement> {
///   int _childWidth = 0;
///   ...
///
///   void update() {
///     updateVirtual(build());
///     readDOM().then((_) {
///       _childWidth = _childElement.ref.width;
///       writeDOM().then((_) {
///         updateVirtual(build());
///         updateFinish();
///       });
///     });
///   }
/// }
///
/// ```
abstract class Component<T extends html.Element> implements Context {
  /// Component is attached to the attached Context.
  static const attachedFlag = 1;

  /// Component is dirty and should be updated at the next frame
  static const dirtyFlag = 1 << 1;

  /// Reference to the Html Element
  T element;

  /// Parent context
  Context _context;
  Context get context => _context;
  void set context(Context newContext) {
    _context = newContext;
    depth = newContext.depth + 1;
  }

  /// Depth relative to other contexts
  int depth = 0;

  /// Flags: [attachedFlag], [dirtyFlag]
  int flags = 0;

  /// Component is attached to the DOM.
  bool get isAttached => (flags & attachedFlag) == attachedFlag;

  /// Component is dirty, and should be updated.
  bool get isDirty => (flags & dirtyFlag) == dirtyFlag;

  /// Reference to the root-level Virtual DOM Element.
  VRootBase<T> vRoot;

  /// Container for children nodes.
  html.Node get container => element;

  /// Create a root-level [element].
  ///
  /// Execution context: [Scheduler]:write
  void create() {
    element = new html.Element.tag('div') as T;
  }

  /// Lifecycle method that is called when [Component] is attached to the
  /// attached [context].
  ///
  /// Execution context: [Scheduler]:write
  void attached() {}

  /// Lifecycle method that is called when [Component] is detached from the
  /// attached [context].
  ///
  /// Execution context: [Scheduler]:write
  void detached() {}

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
  void render() {
    assert(vRoot == null);
    update();
  }

  /// Lifecycle method that is called when [Component] should be updated.
  ///
  /// Execution context: [Scheduler]:write
  void update() {
    final newVRoot = build();
    if (newVRoot != null) {
      updateVRoot(newVRoot);
    }
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

  /// Build Virtual DOM for the current state of the [VComponent].
  ///
  /// Execution context: [Scheduler]:write
  VRootBase<T> build() => null;

  /// Update [Component] using Virtual DOM.
  ///
  /// Execution context: [Scheduler]:write
  void updateVRoot(VRootBase<T> newVRoot) {
    if (vRoot == null) {
      newVRoot.mount(this);
      newVRoot.render(this);
    } else {
      vRoot.update(newVRoot, this);
    }
    vRoot = newVRoot;
  }

  void insertBefore(vdom.Node node, html.Node nextRef) {
    vdom.injectBefore(node, container, nextRef, this);
  }

  void move(vdom.Node node, html.Node nextRef) {
    container.insertBefore(node.ref, nextRef);
  }

  void removeChild(vdom.Node node) {
    node.dispose(this);
  }

  void attach() {
    assert(!isAttached);
    attached();
    flags |= attachedFlag;
    if (shouldComponentUpdate()) {
      update();
    }
    if (vRoot != null) {
      vRoot.attached();
    }
  }

  void detach() {
    assert(isAttached);
    if (vRoot != null) {
      vRoot.detached();
    }
    flags &= ~attachedFlag;
    detached();
  }
}
