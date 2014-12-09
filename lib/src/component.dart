// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library liquid.component;

import 'dart:async';
import 'dart:html' as html;
import 'package:vdom/vdom.dart' as vdom;
import 'package:liquid/src/vdom.dart' as vdom;
import 'package:liquid/src/context.dart';
import 'package:liquid/src/main.dart';

/// Liquid Component is a base class for all Components.
///
/// ```
/// class MyComponent extends Component {
///   build() => vRoot()('Hello Component');
/// }
/// ```
///
/// If you want to read from the DOM, just override [update] method, it is
/// called right after it Component is rendered, mounted and each time after
/// initial VRoot update:
///
/// ```
/// class MyComponent extends Component {
///   int _childWidth = 0;
///   ...
///
///   Future update() {
///     await readDOM();
///     _childWidth = _childElement.ref.width;
///     await writeDOM();
///     updateVRoot(build());
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
    depth = newContext.depth + 1;
  }

  /// Depth relative to other contexts
  int depth = 0;

  /// Flags: [_attachedFlag], [_dirtyFlag]
  int _flags = _dirtyFlag;

  /// Component is attached to the DOM.
  bool get isAttached => (_flags & _attachedFlag) == _attachedFlag;

  /// Component is dirty, and should be updated.
  bool get dirty => (_flags & _dirtyFlag) == _dirtyFlag;
  void set dirty(bool v) {
    if (v) {
      _flags |= _dirtyFlag;
    } else {
      _flags &= ~_dirtyFlag;
    }
  }

  /// Component is rendered.
  bool get isRendered => (_flags & _renderedFlag) == _renderedFlag;

  /// Component is mounted.
  bool get isMounted => (_flags & _mountedFlag) == _mountedFlag;

  /// Reference to the root-level Virtual DOM Element.
  vdom.VRootBase<T> vRoot;

  /// Container for children nodes.
  html.Node get container => element;

  /// Create a root-level [element].
  ///
  /// Execution context: [domScheduler]:write
  void create() { element = new html.Element.tag('div') as T; }

  /// Mount component on top of existing html
  ///
  /// Execution context: [domScheduler]:write
  void mount(T node) {
    _flags |= _mountedFlag;
    element = node;
  }

  /// Initialize
  ///
  /// Execution context: [domScheduler]:write
  void init() {}

  /// Lifecycle method that is called when [Component] is attached to the
  /// document.
  ///
  /// Execution context: [domScheduler]:write
  void attached() {}

  /// Lifecycle method that is called when [Component] is detached from the
  /// document.
  ///
  /// Execution context: [domScheduler]:write
  void detached() {}

  /// Build Virtual DOM for the current state of the [VComponent].
  ///
  /// Execution context: [domScheduler]:write
  vdom.VRootBase<T> build() => null;

  /// Lifecycle method to update [Component].
  ///
  /// Execution context: [domScheduler]:write
  Future update() => null;

  bool shouldComponentUpdate() => true;

  void mounted() {}
  void rendered() {}
  void updated() {}

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

  void insertBefore(vdom.VNode node, html.Node nextRef) {
    node.create(this);
    node.init();
    container.insertBefore(node.ref, nextRef);
    if (isAttached){
      node.attached();
    }
    node.render(this);
  }

  void move(vdom.VNode node, html.Node nextRef) {
    container.insertBefore(node.ref, nextRef);
  }

  void removeChild(vdom.VNode node) {
    node.dispose(this);
  }

  /// Mark [Component] as dirty and add it to the next frame
  /// [domScheduler]:write queue.
  void invalidate() {
    if (!dirty) {
      _flags |= _dirtyFlag;
      if (identical(Zone.current, domScheduler.zone)) {
        domScheduler.nextFrame.write(depth).then(_invalidatedUpdate);
      } else {
        domScheduler.zone.run(() {
          domScheduler.nextFrame.write(depth).then(_invalidatedUpdate);
        });
      }
    }
  }

  void _invalidatedUpdate(_) {
    internalUpdate();
  }

  /// Returns [Future] that completes when [domScheduler] launches write
  /// tasks for the current [Frame]
  Future writeDOM() => domScheduler.currentFrame.write(depth);

  /// Returns [Future] that completes when [domScheduler] launches read
  /// tasks for the current [Frame]
  Future readDOM() => domScheduler.currentFrame.read();

  // TODO: refactor this
  void internalUpdate() {
    if (!dirty) {
      return;
    }

    _flags &= ~_dirtyFlag;
    if (!isRendered) {
      final newVRoot = build();
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
      _flags |= _renderedFlag;
      rendered();
    } else if (shouldComponentUpdate()) {
      final newVRoot = build();
      if (newVRoot != null) {
        updateVRoot(newVRoot);
      }
    } else {
      return;
    }
    final updateFuture = update();
    if (updateFuture == null) {
      updated();
    } else {
      updateFuture.then(_updateFinish);
    }
  }

  void _updateFinish(_) { updated(); }

  /// Update [Component] using Virtual DOM.
  ///
  /// Execution context: [domScheduler]:write
  void updateVRoot(vdom.VRootBase<T> newVRoot) {
    if (vRoot == null) {
      newVRoot.mountComponent(this);
      newVRoot.render(this);
    } else {
      vRoot.update(newVRoot, this);
    }
    vRoot = newVRoot;
  }

  /// Execution context: [domScheduler]:write
  void mountVRoot(vdom.VRootBase<T> newVRoot) {
    newVRoot.mountComponent(this);
    newVRoot.mount(element, this);
    vRoot = newVRoot;
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
}
