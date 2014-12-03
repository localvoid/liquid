part of liquid.dynamic;

class _Property {
  const _Property();

  bool equal(a, b) => false;
}

class _ImmutableProperty extends _Property {
  const _ImmutableProperty();

  bool equal(a, b) => a == b;
}

const _Property property = const _Property();
const _ImmutableProperty immutable = const _ImmutableProperty();

class VDynamicComponent extends VComponent {
  ClassMirror _typeMirror;
  InstanceMirror _instanceMirror;
  Map<Symbol, dynamic> _properties;

  VDynamicComponent(this._typeMirror,
      this._properties,
      Object key,
      String id,
      Map<String, String> attributes,
      List<String> classes,
      Map<String, String> styles)
    : super(key, attributes, classes, styles);

  void create(Context context) {
    _instanceMirror = _typeMirror.newInstance(const Symbol(''), const []);
    component = _instanceMirror.reflectee
      ..context = context;
    _setProperties(_properties);
    component.create();
    ref = component.element;
  }

  void update(VDynamicComponent other, Context context) {
    super.update(other, context);
    other._instanceMirror = _instanceMirror;
    _setProperties(other._properties);
    _instanceMirror.invoke(#update, const []);
  }

  void _setProperties(Map<Symbol, dynamic> properties) {
    if (properties != null) {
      properties.forEach((k, v) {
        if (v != null) {
          _instanceMirror.setField(k, v);
        }
      });
    }
  }
}

class VDynamicComponentContainer extends VDynamicComponent with vdom.Container {
  List<vdom.Node> children;

  html.Node get container => component.container;

  VDynamicComponentContainer(
      ClassMirror typeMirror,
      Object key,
      Map<Symbol, dynamic> properties,
      this.children,
      String id,
      Map<String, String> attributes,
      List<String> classes,
      Map<String, String> styles)
      : super(typeMirror, properties, key, id, attributes, classes, styles);

  VDynamicComponentContainer call(children) {
    if (children is List) {
      this.children = children;
    } else if (children is String) {
      this.children = [new vdom.Text(children)];
    } else {
      this.children = [children];
    }
    return this;
  }

  void render(Context context) {
    super.render(context);
    renderChildren(children, context);
  }

  void update(VDynamicComponentContainer other, Context context) {
    super.update(other, context);
    updateChildren(children, other.children, context);
  }

  void insertBefore(vdom.Node node, html.Node nextRef, Context context) {
    component.insertBefore(node, nextRef);
  }

  void move(vdom.Node node, html.Node nextRef, Context context) {
    component.move(node, nextRef);
  }

  void removeChild(vdom.Node node, Context context) {
    component.removeChild(node);
  }
}

class VDynamicComponentFactory extends Function {
  Type _componentType;
  ClassMirror _classMirror;

  VDynamicComponentFactory(this._componentType) {
    _classMirror = reflectClass(_componentType);
  }

  _create([Map args]) {
    if (args == null) {
      return new VDynamicComponent(_classMirror, null, null, null, null, null, null);
    }
    final properties = new Map.from(args);
    final key = properties.remove(#key);
    final id = properties.remove(#id);
    final attributes = properties.remove(#attributes);
    final classes = properties.remove(#classes);
    final styles = properties.remove(#styles);
    return new VDynamicComponent(_classMirror, properties, key, id, attributes, classes, styles);
  }

  call() => _create();

  noSuchMethod(Invocation invocation) {
    final arguments = invocation.namedArguments;
    return _create(arguments);
  }
}

Function vComponentFactory(Type componentType) => new VDynamicComponentFactory(componentType);

Function vComponentContainerFactory(Type componentType) {
  ClassMirror c = reflectClass(componentType);

  return (Object key, Map<Symbol, dynamic> properties,
      {List<vdom.Node> children,
       Map<String, String> attributes,
       List<String> classes,
       Map<String, String> styles}) {
    return new VDynamicComponentContainer(c, key, properties, children, null, attributes, classes, styles);
  };
}
