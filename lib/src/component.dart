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
  /// Component is attached to the document.
  static const _attachedFlag = 1;

  /// Component is dirty and should be updated at the next frame
  static const _dirtyFlag = 1 << 1;

  /// Component is rendered.
  static const _renderedFlag = 1 << 2;

  /// Component is mounted.
  static const _mountedFlag = 1 << 3;

  /// Reference to the Html Element
  T element;

  /// Parent context
  Context _context;
  void set context(Context newContext) {
    _context = newContext;
    _depth = newContext._depth + 1;
  }

  /// Depth relative to other contexts
  int _depth = 0;

  /// Flags: [_attachedFlag], [_dirtyFlag]
  int _flags = 0;

  /// Component is attached to the DOM.
  bool get isAttached => (_flags & _attachedFlag) == _attachedFlag;

  /// Component is dirty, and should be updated.
  bool get isDirty => (_flags & _dirtyFlag) == _dirtyFlag;

  /// Component is rendered.
  bool get isRendered => (_flags & _renderedFlag) == _renderedFlag;

  /// Component is mounted.
  bool get isMounted => (_flags & _mountedFlag) == _mountedFlag;

  /// Reference to the root-level Virtual DOM Element.
  VRootBase<T> vRoot;

  /// Container for children nodes.
  html.Node get container => element;

  /// Create a root-level [element].
  ///
  /// Execution context: [Scheduler]:write
  void create() { element = new html.Element.tag('div') as T; }

  /// Mount component on top of existing html
  ///
  /// Execution context: [Scheduler]:write
  void mount(T node) {
    _flags |= _mountedFlag;
    element = node;
  }

  /// Initialize
  ///
  /// Execution context: [Scheduler]:write
  void init() {}

  /// Lifecycle method that is called when [Component] is attached to the
  /// document.
  ///
  /// Execution context: [Scheduler]:write
  void attached() {}

  /// Lifecycle method that is called when [Component] is detached from the
  /// document.
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
  Future writeDOM() => domScheduler.currentFrame.write(_depth);

  /// Returns [Future] that completes when [domScheduler] launches read
  /// tasks for the current [Frame]
  Future readDOM() => domScheduler.currentFrame.read();

  /// Lifecycle method to update [Component].
  ///
  /// Execution context: [Scheduler]:write
  void update() {
    internalUpdate();
    updated();
  }

  void internalUpdate() {
    final newVRoot = build();
    if (!isRendered) {
      if (isMounted) {
        if (newVRoot != null) {
          mountVRoot(newVRoot);
        }
        mounted();
      } else {
        if (newVRoot != null) {
          updateVRoot(newVRoot);
        }
      }
      rendered();
    } else {
      if (newVRoot != null) {
        updateVRoot(newVRoot);
      }
    }
    _flags &= ~_dirtyFlag;
  }

  void mounted() { _flags &= ~_mountedFlag; }
  void rendered() { _flags &= ~_renderedFlag; }
  void updated() {}

  /// Mark [Component] as dirty and add it to the next frame [Scheduler]:write
  /// queue.
  void invalidate() {
    if (!isDirty) {
      _flags |= _dirtyFlag;
      if (identical(Zone.current, domScheduler.zone)) {
        domScheduler.nextFrame.write(_depth).then(_invalidatedUpdate);
      } else {
        domScheduler.zone.run(() {
          domScheduler.nextFrame.write(_depth).then(_invalidatedUpdate);
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
      newVRoot.mountComponent(this);
      newVRoot.render(this);
    } else {
      vRoot.update(newVRoot, this);
    }
    vRoot = newVRoot;
  }

  /// Execution context: [Scheduler]:write
  void mountVRoot(VRootBase<T> newVRoot) {
    newVRoot.mountComponent(this);
    newVRoot.mount(element, this);
    vRoot = newVRoot;
  }

  void insertBefore(vdom.Node node, html.Node nextRef) {
    node.create(this);
    container.insertBefore(node.ref, nextRef);
    if (isAttached){
      node.attached();
    }
    node.render(this);
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
    _flags |= _attachedFlag;
    if (vRoot != null) {
      vRoot.attach();
    }
  }

  void detach() {
    assert(isAttached);
    if (vRoot != null) {
      vRoot.detached();
    }
    _flags &= ~_attachedFlag;
    detached();
  }
}
