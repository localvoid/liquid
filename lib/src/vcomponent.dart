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

  VDomInitFunction capture(VDomInitFunction f) {
    return (Component component, Component context) {
      if (component != null) {
        return f(component, context);
      }
      final c = f(component, context);
      set(c);
      return c;
    };
  }
}

/// Component that builds and updates its subtree using Virtual DOM.
abstract class VComponent extends Component {
  v.Element _vElement;

  VComponent(String tagName,
      ComponentBase parent,
      {Object key: null,
       Symbol type: null,
       int flags: 0})
      : super(html.document.createElement(tagName),
          parent,
          key: key,
          type: type,
          flags: flags);

  /// Returns virtual tree for the current state
  v.Element build();

  void updateSubtree() {
    final newVElement = build();
    if (isRendered) {
      _vElement.sync(newVElement, this);
    } else {
      newVElement.mount(element, this);
      isRendered = true;
    }
    _vElement = newVElement;
  }

  void update() {
    assert(element != null);
    updateSubtree();
    super.update();
  }
}

typedef Component VDomInitFunction(Component component, v.Context context);

/// VDom Node for Components
class VDomComponent extends v.Node {
  VDomInitFunction _initFunction;
  Component _component = null;

  VDomComponent(Object key, this._initFunction) : super(key) {
    assert(_initFunction != null);
  }

  void sync(VDomComponent other, v.Context context) {
    assert(other != null);

    // transfer component state
    other.ref = ref;
    other._component = _component;
    other._initFunction(_component, context);
  }

  html.Node render(v.Context context) {
    _component = _initFunction(null, context);
    ref = _component.element;
    return ref;
  }

  void inject(html.Element container, v.Context context) {
    container.append(render(context));
    if (context.isAttached) {
      attached();
    }
    _component.update();
  }

  void injectBefore(html.Element container, html.Node nextRef,
                    v.Context context) {
    container.insertBefore(render(context), nextRef);
    if (context.isAttached) {
      attached();
    }
    _component.update();
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

VDomComponent component(Object key, VDomInitFunction initFunction) {
  return new VDomComponent(key, initFunction);
}
