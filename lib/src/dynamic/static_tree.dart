part of liquid.dynamic;

class VStaticTree extends vdom.ElementBase {
  vdom.Node _vTree;
  Function _buildFunction;
  Map<Symbol, dynamic> _namedArgs;

  VStaticTree(Object key,
      this._buildFunction,
      this._namedArgs,
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

  vdom.Node build() => Function.apply(_buildFunction, const [], _namedArgs);

  void update(VStaticTree other, Context context) {
    super.update(other, context);
    other._vTree = other.build();
    _vTree.update(other._vTree, context);
  }

  void attached() { _vTree.attached(); }
  void detached() { _vTree.detached(); }
  void attach() { _vTree.attach(); }
  void detach() { _vTree.detach(); }
}

class VStaticTreeFactory extends Function {
  Function _buildFunction;

  VStaticTreeFactory(this._buildFunction);

  _create([Map args]) {
    if (args == null) {
      return new VStaticTree(null, _buildFunction, null, null, null, null, null);
    }
    final properties = new Map.from(args);
    final key = properties.remove(#key);
    final id = properties.remove(#id);
    final attributes = properties.remove(#attributes);
    final classes = properties.remove(#classes);
    final styles = properties.remove(#styles);
    return new VStaticTree(key, _buildFunction, properties, id, attributes, classes, styles);
  }

  call() => _create();

  noSuchMethod(Invocation invocation) => _create(invocation.namedArguments);
}

Function vStaticTreeFactory(Function buildFunction) => new VStaticTreeFactory(buildFunction);
