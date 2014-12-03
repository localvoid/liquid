part of liquid.dynamic;

class VStaticTree extends vdom.ElementBase {
  vdom.Node _vTree;
  Function _buildFunction;
  Map<Symbol, dynamic> _properties;

  VStaticTree(
      this._buildFunction,
      this._properties,
      Object key,
      String id,
      Map<String, String> attributes,
      List<String> classes,
      Map<String, String> styles)
      : super(key, id, attributes, classes, styles);

  void create(Context context) {
    _vTree = build();
    _vTree.create(context);
    ref = _vTree.ref;
  }

  void render(Context context) {
    super.render(context);
    _vTree.render(context);
  }

  vdom.Node build() => Function.apply(_buildFunction, const [], _properties);

  void attached() { _vTree.attached(); }
  void detached() { _vTree.detached(); }
  void attach() { _vTree.attach(); }
  void detach() { _vTree.detach(); }
}

class VStaticTreeFactory extends Function {
  Function _buildFunction;

  VStaticTreeFactory(this._buildFunction);

  VStaticTree _create([Map args]) {
    if (args == null) {
      return new VStaticTree(_buildFunction, null, null, null, null, null, null);
    }
    final properties = new HashMap.from(args);
    final key = properties.remove(#key);
    final id = properties.remove(#id);
    final attributes = properties.remove(#attributes);
    final classes = properties.remove(#classes);
    final styles = properties.remove(#styles);
    return new VStaticTree(_buildFunction, properties, key, id, attributes, classes, styles);
  }

  VStaticTree call() => _create();

  VStaticTree noSuchMethod(Invocation invocation) => _create(invocation.namedArguments);
}

Function vStaticTreeFactory(Function buildFunction) => new VStaticTreeFactory(buildFunction);
