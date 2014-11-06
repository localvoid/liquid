// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid;

/// TODO: Bad Example. Get rid of this.
abstract class StaticTree {
  final html.Element element;

  StaticTree(this.element);
}

class VDomStaticTree extends v.Node {
  Function _initFunction;
  StaticTree _staticTree = null;

  VDomStaticTree(Object key, this._initFunction) : super(key) {
    assert(_initFunction != null);
  }

  void sync(VDomStaticTree other, [bool isAttached = false]) {
    assert(other != null);
    other.ref = ref;
    other._staticTree = _staticTree;
  }

  html.Node render() {
    _staticTree = _initFunction();
    ref = _staticTree.element;
    return _staticTree.element;
  }

  String toString() {
    return (_staticTree == null)
        ? 'VDomStaticTree[stateless]'
        : 'VDomStaticTree[$_staticTree]';
  }
}