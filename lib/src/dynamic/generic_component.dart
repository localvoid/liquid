// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid.dynamic;

class VGenericComponent extends VComponent {
  ClassMirror _classMirror;
  InstanceMirror _instanceMirror;
  Map<Symbol, _Property> _propertyTypes;
  Map<Symbol, dynamic> _properties;

  VGenericComponent(
      this._classMirror,
      this._propertyTypes,
      this._properties,
      Object key,
      String id,
      Map<String, String> attributes,
      List<String> classes,
      Map<String, String> styles)
    : super(key, attributes, classes, styles);

  void create(VContext context) {
    _instanceMirror = _classMirror.newInstance(const Symbol(''), const []);
    component = _instanceMirror.reflectee
      ..context = context;
    if (_properties != null) {
      _properties.forEach((k, v) {
        if (_propertyTypes.containsKey(k)) {
          _instanceMirror.setField(k, v);
        }
      });
    }
    component.create();
    ref = component.element;
  }

  void update(VGenericComponent other, VContext context) {
    super.update(other, context);
    other._instanceMirror = _instanceMirror;

    if (other._properties != null) {
      var dirty = false;
      other._properties.forEach((k, v) {
        if (_properties.containsKey(k) &&
            !_propertyTypes[k].equal(_properties[k], v)) {
          _instanceMirror.setField(k, v);
          dirty = true;
        }
      });
      if (dirty) {
        _instanceMirror.invoke(#internalUpdate, const []);
      }
    }
  }
}

class VGenericComponentFactory extends Function {
  Type _componentType;
  ClassMirror _classMirror;
  Map<Symbol, _Property> _propertyTypes;

  VGenericComponentFactory(this._componentType) {
    _classMirror = reflectClass(_componentType);
    final publicVariables = _classMirror.declarations.values.where((d) {
      return !d.isPrivate && d is VariableMirror;
    });
    _propertyTypes = _lookupProperties(publicVariables);
  }

  VGenericComponent _create([Map args]) {
    if (args == null) {
      return new VGenericComponent(_classMirror, _propertyTypes, null, null,
          null, null, null, null);
    }
    final properties = new HashMap.from(args);
    final String key = properties.remove(#key);
    final Object id = properties.remove(#id);
    final Map<String, String> attributes = properties.remove(#attributes);
    final List<String> classes = properties.remove(#classes);
    final Map<String, String> styles = properties.remove(#styles);
    return new VGenericComponent(
        _classMirror,
        _propertyTypes,
        properties,
        key,
        id,
        attributes,
        classes,
        styles);
  }

  VGenericComponent call() => _create();

  VGenericComponent noSuchMethod(Invocation invocation) {
    final arguments = invocation.namedArguments;
    return _create(arguments);
  }
}

Function vComponentFactory(Type componentType) => new VGenericComponentFactory(componentType);
