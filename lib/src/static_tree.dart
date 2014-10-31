part of liquid;

abstract class StaticTree {
  final html.Element element;

  StaticTree(this.element);
}

class VDomStaticTree extends v.Node {
  Function _initFunction;
  StaticTree _staticTree = null;

  VDomStaticTree(Object key, this._initFunction) : super(key) {
    assert(_initFunction != null);
  }

  v.NodePatch diff(VDomStaticTree other) {
    assert(other != null);

    other._staticTree = _staticTree;
    return null;
  }

  html.Node render() {
    _staticTree = _initFunction();
    return _staticTree.element;
  }

  String toString() {
    return (_staticTree == null) ? 'VDomStaticTree[stateless]' : 'VDomStaticTree[$_staticTree]';
  }
}