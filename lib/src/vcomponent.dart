// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid;

abstract class VComponent extends Component {
  List<v.Node> _vTree;

  VComponent(ComponentBase parent, html.Element element) : super(parent, element);

  /// Returns virtual tree for the current state
  List<v.Node> build();

  /// MainLoop state: DomWrite
  void render() {
    assert(element != null);
    assert(_isAttached == false);

    _vTree = build();
    // NOTE: tried doc fragment, it just makes it slower
    for (var i = 0; i < _vTree.length; i++) {
      final node = _vTree[i];
      element.append(node.render());
      if (_isAttached) {
        node.attached();
      }
    }
  }

  /// MainLoop state: DomWrite
  void update() {
    assert(element != null);
    assert(_isAttached == true);

    if (_isDirty) {
      final newVTree = build();
      assert(newVTree != null);
      final patch = v.diffChildren(_vTree, newVTree);
      _vTree = newVTree;
      if (patch != null) {
        v.applyChildrenPatch(patch, element, _isAttached);
      }
    }

    super.update();
  }
}

class VDomComponent extends v.Node {
  final Function _initFunction;
  Component _component = null;

  VDomComponent(Object key, this._initFunction) : super(key) {
    assert(_initFunction != null);
  }

  v.NodePatch diff(VDomComponent other) {
    assert(other != null);

    // transfer component state
    other._component = _component;
    other._initFunction(_component);
    return null;
  }

  html.Node render() {
    _component = _initFunction(null);
    _component.render();
    return _component.element;
  }

  void attached() {
    _component.attached();
  }

  void detached() {
    _component.detached();
    _component.dispose();
  }

  String toString() {
    return (_component == null) ? 'VDomComponent[stateless]' : 'VDomComponent[$_component]';
  }
}
