part of liquid;

/// TODO: rename
typedef Component VDomInitFunction(Component component,
                                   vdom.Context context);

/// VDom Node for Components
class VDomComponent extends vdom.Node {
  VDomInitFunction _initFunction;
  Component component = null;

  VDomComponent(Object key, this._initFunction) : super(key) {
    assert(_initFunction != null);
  }

  void create(vdom.Context context) {
    assert(component == null);
    assert(ref == null);
    component = _initFunction(null, context);
    ref = component.element;
  }

  void render(vdom.Context context) {
    assert(component != null);
    assert(ref != null);
    component.render();
  }

  void update(VDomComponent other, vdom.Context context) {
    assert(other != null);

    // transfer component state
    other.ref = ref;
    other.component = component;
    other._initFunction(component, context);
  }

  void attached() {
    component.attached();
  }

  void detached() {
    component.detached();
  }

  String toString() {
    return (component == null)
        ? 'VDomComponent[stateless]'
        : 'VDomComponent[$component]';
  }
}
