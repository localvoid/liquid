// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid.dynamic;

class VDynamicTree extends VStaticTree {
  HashMap<Symbol, Property> _propertyTypes;

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

  void update(VStaticTree other, vdom.Context context) {
    super.update(other, context);
    other._vTree = other.build();
    _vTree.update(other._vTree, context);
  }
}

class VDynamicTreeFactory extends Function {
  Function _buildFunction;
  ClosureMirror _closureMirror;
  HashMap<Symbol, Property> _propertyTypes;

  VDynamicTreeFactory(this._buildFunction) {
     _closureMirror = reflect(_buildFunction);
     _propertyTypes = _lookupProperties(_closureMirror.function.parameters);
  }

  VDynamicTree _create([Map args]) {
    if (args == null) {
      return new VDynamicTree(_propertyTypes, _buildFunction, null, null, null, null, null, null);
    }
    final HashMap<Symbol, dynamic> properties = new HashMap.from(args);
    final Object key = properties.remove(#key);
    final String id = properties.remove(#id);
    final Map<String, String> attributes = properties.remove(#attributes);
    final List<String> classes = properties.remove(#classes);
    final Map<String, String> styles = properties.remove(#styles);
    return new VDynamicTree(_propertyTypes, _buildFunction, properties,
        key, id, attributes, classes, styles);
  }

  VDynamicTree call() => _create();

  VDynamicTree noSuchMethod(Invocation invocation) => _create(invocation.namedArguments);
}

Function dynamicTreeFactory(Function buildFunction) => new VDynamicTreeFactory(buildFunction);
