part of liquid.example.a;

final box = componentFactory(Box);
class Box extends Component<DivElement> {
  @property OuterBox parent = null;

  int _outerWidth = 0;
  int _innerWidth = 0;
  VNode _child;
  StreamSubscription _resizeSub;

  build() {
    _child = innerBox();

    return root(classes: ['box'])([
      div()('Outer: $_outerWidth'),
      div()('Inner: $_innerWidth'),
      _child
    ]);
  }

  void attached() {
    _resizeSub = window.onResize.listen((_) {
      invalidate();
    });
  }

  void detached() {
    _resizeSub.cancel();
  }

  Future update() {
    return readDOM().then((_) {
      _outerWidth = parent.element.clientWidth;
      _innerWidth = _child.ref.clientWidth;
      return writeDOM().then((_) {
        updateVRoot(build());
      });
    });
  }
}
