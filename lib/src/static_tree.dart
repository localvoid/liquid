// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid;

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

  v.NodePatch diff(VDomStaticTree other) {
    assert(other != null);

    other._staticTree = _staticTree;
    return null;
  }

  html.Node render() {
    _staticTree = _initFunction();
    return _staticTree.element;
  }

  String toString() {
    return (_staticTree == null)
        ? 'VDomStaticTree[stateless]'
        : 'VDomStaticTree[$_staticTree]';
  }
}