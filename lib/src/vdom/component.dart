part of liquid;

typedef Component VDomInitFunction(Component component,
                                   Object key,
                                   v.Context context);

/// VDom Node for Components
class VDomComponent extends v.Node {
  VDomInitFunction _initFunction;
  Component component = null;

  VDomComponent(Object key, this._initFunction) : super(key) {
    assert(_initFunction != null);
  }

  void create(v.Context context) {
    assert(component == null);
    assert(ref == null);
    component = _initFunction(null, key, context);
    ref = component.element;
  }

  void render(v.Context context) {
    assert(component != null);
    assert(ref != null);
    component.render();
  }

  void update(VDomComponent other, v.Context context) {
    assert(other != null);

    // transfer component state
    other.ref = ref;
    other.component = component;
    other._initFunction(component, key, context);
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

VDomComponent component(Object key, VDomInitFunction initFunction) {
  return new VDomComponent(key, initFunction);
}
