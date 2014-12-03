part of liquid.dynamic;

class VDynamicTree extends VStaticTree {
  HashMap<Symbol, _Property> _propertyTypes;

  VDynamicTree(
      this._propertyTypes,
      Function buildFunction,
      Map<Symbol, dynamic> namedArgs,
      Object key,
      String id,
      Map<String, String> attributes,
      List<String> classes,
      Map<String, String> styles)
      : super(buildFunction, namedArgs, key, id, attributes, classes, styles);

  void update(VStaticTree other, Context context) {
    super.update(other, context);
    other._vTree = other.build();
    var dirty = false;
    for (var k in _namedArgs.keys) {
      if (other._namedArgs.containsKey(k) &&
          !_propertyTypes[k].equal(_namedArgs[k], other._namedArgs[k])) {
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
  HashMap<Symbol, _Property> _propertyTypes = new HashMap<Symbol, _Property>();

  VDynamicTreeFactory(this._buildFunction) {
     _closureMirror = reflect(_buildFunction);
     for (var p in _closureMirror.function.parameters) {
       _Property type;
       for (var m in p.metadata) {
         if (m.reflectee is _Property) {
           type = m.reflectee;
           break;
         }
       }
       if (type == null) {
         type = const _Property();
       }
       _propertyTypes[p.simpleName] = type;
     }
  }

  VDynamicTree _create([Map args]) {
    if (args == null) {
      return new VDynamicTree(_propertyTypes, _buildFunction, null, null, null, null, null, null);
    }
    final properties = new Map.from(args);
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
