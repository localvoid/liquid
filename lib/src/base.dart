// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid;

/// Abstract base class for all Components
///
/// TODO: Add Iterator for traversing children
/// TODO: Expose method that is registered in [Scheduler] when Component
/// is invalidated.
abstract class ComponentBase implements v.Context {
  /// Component is rendered its subtree.
  static const renderedFlag = 1;

  /// Component is attached to the DOM.
  static const attachedFlag = 1 << 1;

  /// Component is dirty and should be updated in the next Update Loop
  static const dirtyFlag    = 1 << 2;

  /// Components should have HtmlElement that it owns, it can be mounted to
  /// an existing element, or create its own.
  final html.Element element;

  /// Component's parent is used to establish parent-child relationship, in our
  /// model parent-child relationship is not exactly the same as in DOM.
  ///
  /// Component can be inside of another Components subtree, but have different
  /// parent.
  final ComponentBase parent;

  /// Unique key
  final Object key;

  /// Context
  final int depth;

  /// Type
  final Symbol type;

  int _flags;

  // intrusive hlist of children components
  ComponentBase _children = null;
  ComponentBase _prev = null;
  ComponentBase _next = null;

  /// Component is rendered its subtree.
  bool get isRendered => (_flags & renderedFlag) == renderedFlag;

  /// Component is attached to the DOM.
  bool get isAttached => (_flags & attachedFlag) == attachedFlag;

  /// Component is dirty, and should be updated.
  bool get isDirty => (_flags & dirtyFlag) == dirtyFlag;

  /// TODO: get rid of this?
  set isRendered(bool v) {
    if (v) {
      _flags |= renderedFlag;
    } else {
      _flags &= ~renderedFlag;
    }
  }

  /// TODO: get rid of this?
  set isDirty(bool v) {
    if (v) {
      _flags |= dirtyFlag;
    } else {
      _flags &= ~dirtyFlag;
    }
  }

  /// [ComponentBase] constructor
  ///
  /// Execution context: [UpdateLoop]:write
  ComponentBase(this.element,
                {this.parent: null,
                 this.depth: 0,
                 this.key: null,
                 this.type: null,
                 int flags: 0})
      : _flags = flags;

  /// Execution context: [UpdateLoop]:write
  ///
  /// TODO: expose this to the API?
  void _addChild(ComponentBase c) {
    assert(c._prev == null);
    assert(c._next == null);

    c._next = _children;
    if (_children != null) {
      _children._prev = c;
    }
    _children = c;
  }

  /// Execution context: [UpdateLoop]:write
  ///
  /// TODO: expose this to the API?
  void _removeChild(ComponentBase c) {
    if (c._prev == null) {
      _children = c._next;
      c._next = null;
    } else {
      c._prev._next = c._next;
      if (c._next != null) {
        c._next._prev = c._prev;
        c._next = null;
      }
      c._prev = null;
    }
  }

  /// Update [Component]'s tag tree.
  void update() {
    _flags &= ~dirtyFlag;
  }

  /// Invoked when the Component is attached to the DOM.
  ///
  /// Execution context: [UpdateLoop]:write
  void attached() {
    assert(!isAttached);
    parent._addChild(this);
    _flags |= attachedFlag;
  }

  /// Invoked when the Component is detached from the DOM.
  ///
  /// Execution context: [UpdateLoop]:write
  void detached() {
    assert(isAttached);
    parent._removeChild(this);
    _flags &= ~attachedFlag;

    var c = _children;
    while (c != null) {
      c.detached();
      c = c._next;
    }
  }

  // TODO: do we really need this events stuff?
  void onEvent(ComponentEvent e) {}
  void onBroadcastEvent(ComponentEvent e) {}

  /// Broadcast event to children
  void broadcast(ComponentEvent e, [Symbol type]) {
    var c = _children;
    while (c != null) {
      if (type == null || c.type == type) {
        c.onBroadcastEvent(e);
        c = c._next;
      }
    }
  }

  /// Find child Component by [key]
  Component findByKey(Object key) {
    var c = _children;
    while (c != null) {
      if (c.key == key) {
        return c;
      }
      c = c._next;
    }
    return null;
  }

  /// Find child Components by [type]
  ///
  /// TODO: return lazy iterator
  List<Component> findByType(Symbol type) {
    final result = [];
    var c = _children;
    while (c != null) {
      if (c.type == type) {
        result.add(c);
      }
      c = c._next;
    }
    return result;
  }

  /// Append Component
  ///
  /// TODO: this is ugly.
  void append(Component c) {
    element.append(c.element);
    c.attached();
    c.update();
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
}
