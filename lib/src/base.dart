// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid;

abstract class ComponentBase {
  static const renderedFlag = 1;
  static const attachedFlag = 1 << 1;
  static const cleanFlag    = 1 << 2;

  final html.Element element;
  final ComponentBase parent;
  final Object key;
  final Symbol type;
  final int depth;
  int _flags;

  // intrusive hlist of children components
  ComponentBase _children = null;
  ComponentBase _prev = null;
  ComponentBase _next = null;

  bool get isAttached => (_flags & attachedFlag) == attachedFlag;
  bool get isRendered => (_flags & renderedFlag) == renderedFlag;
  bool get isDirty => (_flags & cleanFlag) != cleanFlag;

  set isRendered(bool v) {
    if (v) {
      _flags |= renderedFlag;
    } else {
      _flags &= ~renderedFlag;
    }
  }

  set isDirty(bool v) {
    if (v) {
      _flags &= ~cleanFlag;
    } else {
      _flags |= cleanFlag;
    }
  }

  ComponentBase(this.element,
                {this.parent: null,
                 this.key: null,
                 this.type: null,
                 this.depth: 0,
                 int flags: 0})
      : _flags = flags;

  /// MainLoop state: DomWrite
  void _addChild(ComponentBase c) {
    assert(c._prev == null);
    assert(c._next == null);

    c._next = _children;
    if (_children != null) {
      _children._prev = c;
    }
    _children = c;
  }

  /// MainLoop state: DomWrite
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

  void update() {
    updateFinish();
  }

  void updateFinish() {
    _flags |= cleanFlag;
  }

  /// Invoked when the Component is attached to the Document
  ///
  /// MainLoop state: DomWrite
  void attached() {
    assert(!isAttached);
    parent._addChild(this);
    _flags |= attachedFlag;

    var c = _children;
    while (c != null) {
      c.attached();
      c = c._next;
    }

    if (isDirty) {
      update();
    }
  }

  /// Invoked when the Component is detached from the Document
  ///
  /// MainLoop state: DomWrite
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

  // Do we really need this events stuff?
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

  Component findByType(Symbol type) {
    var c = _children;
    while (c != null) {
      if (c.type == type) {
        return c;
      }
      c = c._next;
    }
    return null;
  }

  void append(Component c) {
    element.append(c.element);
    c.attached();
  }

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
