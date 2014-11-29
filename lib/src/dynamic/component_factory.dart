part of liquid.dynamic;

class VDynamicComponentElement extends VComponentBase {
  ClassMirror _typeMirror;
  InstanceMirror _instanceMirror;
  List _args;
  Map<Symbol, dynamic> _kwargs;

  VDynamicComponentElement(this._typeMirror,
      Object key,
      [this._args = const [],
       this._kwargs])
    : super(key);

  void create(Context context) {
    final args = [context];
    args.addAll(_args);
    _instanceMirror = _typeMirror.newInstance(const Symbol(''), args, _kwargs);
    component = _instanceMirror.reflectee;
    ref = component.element;
  }

  void update(VDynamicComponentElement other, Context context) {
    super.update(other, context);
    if (other._args.isNotEmpty || other._kwargs != null) {
      _instanceMirror.invoke(#updateProperties, other._args, other._kwargs);
    }
  }
}

Function vComponentFactory(Type componentType) {
  ClassMirror c = reflectClass(componentType);

  return (Object key, [List args = const [], Map<Symbol, dynamic> kwargs]) {
    return new VDynamicComponentElement(c, key, args, kwargs);
  };
}
