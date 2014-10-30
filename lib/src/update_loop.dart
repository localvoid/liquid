part of liquid;

class UpdateLoop {
  List<ComponentBase> _queue = [];
  int _ref = -1;

  void add(ComponentBase c) {
    if (_queue.isEmpty) {
      _ref = html.window.requestAnimationFrame(_handleAnimationFrame);
    }
    _queue.add(c);
  }

  void _handleAnimationFrame(num t) {
    _ref = -1;
    while (_queue.isNotEmpty) {
      _queue.removeLast().update();
    }
  }

  void forceUpdate() {
    if (_ref != -1) {
      html.window.cancelAnimationFrame(_ref);
      _ref = -1;
      while (_queue.isNotEmpty) {
        _queue.removeLast().update();
      }
    }
  }
}