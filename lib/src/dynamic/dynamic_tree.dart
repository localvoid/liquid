// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid.dynamic;

class VDynamicTree extends VStaticTree {
  HashMap<Symbol, _Property> _propertyTypes;

  VDynamicTree(
      this._propertyTypes,
      Function buildFunction,
      Map<Symbol, dynamic> properties,
      Object key,
      String id,
      Map<String, String> attributes,
      List<String> classes,
      Map<String, String> styles)
      : super(buildFunction, properties, key, id, attributes, classes, styles);

  void update(VStaticTree other, VContext context) {
    super.update(other, context);
    other._vTree = other.build();
    var dirty = false;
    for (var k in _properties.keys) {
      if (other._properties.containsKey(k) &&
          !_propertyTypes[k].equal(_properties[k], other._properties[k])) {
        dirty = true;
        break;
      }
    }
    if (dirty) {
      _vTree.update(other._vTree, context);
    }
  }
}

class VDynamicTreeFactory extends Function {
  Function _buildFunction;
  ClosureMirror _closureMirror;
  HashMap<Symbol, _Property> _propertyTypes;

  VDynamicTreeFactory(this._buildFunction) {
     _closureMirror = reflect(_buildFunction);
     _propertyTypes = _lookupProperties(_closureMirror.function.parameters);
  }

  VDynamicTree _create([Map args]) {
    if (args == null) {
      return new VDynamicTree(_propertyTypes, _buildFunction, null, null, null, null, null, null);
    }
    final properties = new HashMap.from(args);
    final key = properties.remove(#key);
    final id = properties.remove(#id);
    final attributes = properties.remove(#attributes);
    final classes = properties.remove(#classes);
    final styles = properties.remove(#styles);
    return new VDynamicTree(_propertyTypes, _buildFunction, properties,
        key, id, attributes, classes, styles);
  }

  VDynamicTree call() => _create();

  VDynamicTree noSuchMethod(Invocation invocation) => _create(invocation.namedArguments);
}

Function vDynamicTreeFactory(Function buildFunction) => new VDynamicTreeFactory(buildFunction);
