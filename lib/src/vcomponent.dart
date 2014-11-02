// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid;

/// Lazy component reference
class VRef<T extends Component> {
  final Function _onAttached;
  T _component;
  T get get => _component;

  VRef([this._onAttached = null]);

  void set(T c) {
    _component = c;
    if (_onAttached != null) {
      _onAttached(c);
    }
  }
}

abstract class VComponent extends Component {
  List<v.Node> _vTree;

  VComponent(ComponentBase parent,
      html.Element element,
      {Object key: null,
       Symbol type: null,
       int flags: 0})
      : super(parent, element, key: key, type: type, flags: flags);

  /// Returns virtual tree for the current state
  List<v.Node> build();

  void update() {
    assert(element != null);

    final newVTree = build();
    assert(newVTree != null);

    if (isRendered) {
      final patch = v.diffChildren(_vTree, newVTree);
      if (patch != null) {
        v.applyChildrenPatch(patch, element, isAttached);
      }
    } else {
      for (var i = 0; i < newVTree.length; i++) {
        final node = newVTree[i];
        element.append(node.render());
        if (isAttached) {
          node.attached();
        }
      }
      isRendered = true;
    }
    _vTree = newVTree;
    super.update();
  }
}

class VDomComponent extends v.Node {
  Function _initFunction;
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
    return _component.element;
  }

  void attached() {
    _component.attached();
  }

  void detached() {
    _component.detached();
  }

  String toString() {
    return (_component == null)
        ? 'VDomComponent[stateless]'
        : 'VDomComponent[$_component]';
  }
}
