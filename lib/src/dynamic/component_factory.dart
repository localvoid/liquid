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
    if (_properties != null) {
      _properties.forEach((k, v) {
        if (v != null) {
          _instanceMirror.setField(k, v);
        }
      });
    }
  }
}

typedef VDynamicComponent ComponentFactoryFunction(Object key,
                                                   Map<Symbol, dynamic> args,
                                                   {Map<String, String> attributes,
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
