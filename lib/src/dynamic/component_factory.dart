part of liquid.dynamic;

class _Property {
  const _Property();
}

const _Property property = const _Property();

class VDynamicComponent extends VComponent {
  ClassMirror _typeMirror;
  InstanceMirror _instanceMirror;
  Map<Symbol, dynamic> _properties;

  VDynamicComponent(this._typeMirror,
      Object key,
      this._properties,
      Map<String, String> attributes,
      List<String> classes,
      Map<String, String> styles)
    : super(key, attributes, classes, styles);

  void create(Context context) {
    _instanceMirror = _typeMirror.newInstance(const Symbol(''), [context]);
    _setProperties(_properties);
    _instanceMirror.invoke(#create, const []);
    component = _instanceMirror.reflectee;
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
      Map<String, String> attributes,
      List<String> classes,
      Map<String, String> styles)
      : super(typeMirror, key, properties, attributes, classes, styles);

  VDynamicComponentContainer call(children) {
    if (children is List) {
      this.children = children;
    } else if (children is String) {
      this.children = [new vdom.Text(null, children)];
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

typedef VDynamicComponent
ComponentFactoryFunction(Object key,
                         Map<Symbol, dynamic> properties,
                         {Map<String, String> attributes,
                          List<String> classes,
                          Map<String, String> styles});

typedef VDynamicComponentContainer
ComponentContainerFactoryFunction(Object key,
                                  Map<Symbol, dynamic> properties,
                                  {List<vdom.Node> children,
                                   Map<String, String> attributes,
                                   List<String> classes,
                                   Map<String, String> styles});

Function vComponentFactory(Type componentType) {
  ClassMirror c = reflectClass(componentType);

  return (Object key, Map<Symbol, dynamic> properties,
      {Map<String, String> attributes,
       List<String> classes,
       Map<String, String> styles}) {
    return new VDynamicComponent(c, key, properties, attributes, classes, styles);
  };
}

Function vComponentContainerFactory(Type componentType) {
  ClassMirror c = reflectClass(componentType);

  return (Object key, Map<Symbol, dynamic> properties,
      {List<vdom.Node> children,
       Map<String, String> attributes,
       List<String> classes,
       Map<String, String> styles}) {
    return new VDynamicComponentContainer(c, key, properties, children, attributes, classes, styles);
  };
}
