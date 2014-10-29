// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid;

abstract class Component extends ComponentBase {
  final html.Element element;

  bool _isDirty = false;
  bool get isDirty => _isDirty;

  /// update/patch phase
  Component(ComponentBase parent, this.element) : super(parent) {
    assert(parent != null);
    assert(element != null);

    parent._addChild(this);
  }

  void invalidate() {
    if (!_isDirty) {
      _isDirty = true;

      // propagate info that one of the childrens is dirty
      var p = parent;
      var c = this;
      while (p != null) {
        p._addInvalidatedChild(c);
        // if component is already have invalidated children, it means that parents
        // already know that there is a dirty component below
        if (p._invalidatedChildren != null) {
          break;
        }
        c = p;
        p = p.parent;
      }
    }
  }

  void render();
  void update();

  /// update/patch phase
  void detached() {
    assert(_isAttached == true);

    if (_isDirty) {
      parent._removeInvalidatedChild(this);
    }
    parent._removeChild(this);

    var c = _children;
    while (c != null) {
      c.detached();
      c = c._next;
    }
  }
}
