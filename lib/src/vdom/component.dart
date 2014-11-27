part of liquid;

abstract class VComponent<C extends Component<T>, T extends html.Element>
    extends vdom.ElementBase<T> {
  C component = null;

  VComponent(Object key,
      Map<String, String> attributes,
      List<String> classes,
      Map<String, String> styles)
      : super(key, attributes, classes, styles);

  void create(Context context);

  void render(Context context) {
    component.render();
  }

  void update(VComponent<C, T> other, Context context) {
    other.ref = ref;
    other.component = component;
  }

  void attached() {
    component.attached();
  }

  void detached() {
    component.detached();
  }

  String toString() => (component == null) ?
      'VComponent[stateless]' : 'VComponent[$component]';
}

abstract class VComponentContainer<C extends Component<T>, T extends html.Element>
    extends VComponent<C, T> {
  List<vdom.Node> children;

  VComponentContainer(Object key,
      this.children,
      Map<String, String> attributes,
      List<String> classes,
      Map<String, String> styles)
      : super(key, attributes, classes, styles);
}


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
