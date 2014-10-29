// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid;

abstract class ComponentBase {
  final ComponentBase parent;

  // intrusive hlist of children components
  ComponentBase _children = null;
  ComponentBase _prev = null;
  ComponentBase _next = null;

  // intrusive hlist of invalidated children
  ComponentBase _invalidatedChildren = null;
  ComponentBase _invalidatedPrev = null;
  ComponentBase _invalidatedNext = null;

  bool _isAttached = false;
  bool get isAttached => _isAttached;

  ComponentBase([this.parent = null]);

  /// update/patch phase
  void _addChild(ComponentBase c) {
    assert(c._prev == null);
    assert(c._next == null);

    c._next = _children;
    _children = c;
  }

  /// update/patch phase
  void _removeChild(ComponentBase c) {
    if (c._prev == null) {
      _children = c._next;
      c._next = null;
    } else {
      c._prev._next = c._next;
      c._next._prev = c._prev;
      c._prev = null;
      c._next = null;
    }
  }

  void _addInvalidatedChild(ComponentBase c) {
    assert(c._invalidatedPrev == null);
    assert(c._invalidatedNext == null);

    c._invalidatedNext = _invalidatedChildren;
    _invalidatedChildren = c;
  }

  void _removeInvalidatedChild(ComponentBase c) {
    if (c._invalidatedPrev == null) {
      _invalidatedChildren = c._invalidatedNext;
      c._invalidatedNext = null;
    } else {
      c._invalidatedPrev._invalidatedNext = c._invalidatedNext;
      c._invalidatedNext._invalidatedPrev = c._invalidatedPrev;
      c._invalidatedPrev = null;
      c._invalidatedNext = null;
    }
  }

  void update() {
    var c = _invalidatedChildren;
    while (c != null) {
      c.update();
      c = c._invalidatedNext;
    }
  }

  /// update/patch phase
  void attached() {
    assert(_isAttached == false);

    var c = _children;
    while (c != null) {
      c.attached();
      c = c._next;
    }

    _isAttached = true;
  }

  /// update/patch phase
  void detached() {
    assert(_isAttached == true);

    var c = _children;
    while (c != null) {
      c.detached();
      c = c._next;
    }
  }
}
