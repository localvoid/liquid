// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// TODO: move VRef and VDomComponent outside of this file, because
/// they can work with raw Components, and VComponent is just Component
/// that builds its subtree with virtual dom.
part of liquid;

/// Lazy [Component] reference initialized when the Component is created
/// by [VDomComponent] node in the virtual tree.
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

/// Component that builds and updates its subtree using Virtual DOM.
abstract class VComponent extends Component {
  v.Element _vElement;

  VComponent(ComponentBase parent,
      html.Element element,
      {Object key: null,
       Symbol type: null,
       int flags: 0})
      : super(parent, element, key: key, type: type, flags: flags);

  /// Returns virtual tree for the current state
  v.Element build();

  void update() {
    assert(element != null);

    final newVElement = build();
    assert(newVElement != null);

    if (isRendered) {
      _vElement.sync(newVElement, isAttached);
    } else {
      newVElement.mount(element);
      if (isAttached) {
        newVElement.attached();
      }
      isRendered = true;
    }
    _vElement = newVElement;
    super.update();
  }
}

/// VDom Node for Components
class VDomComponent extends v.Node {
  Function _initFunction;
  Component _component = null;

  VDomComponent(Object key, this._initFunction) : super(key) {
    assert(_initFunction != null);
  }

  void sync(VDomComponent other, [bool isAttached = false]) {
    assert(other != null);
    // transfer component state
    other.ref = ref;
    other._component = _component;
    other._initFunction(_component);
  }

  html.Node render() {
    _component = _initFunction(null);
    ref = _component.element;
    return ref;
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
