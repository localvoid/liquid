part of liquid;

abstract class ComponentEvent {
  bool _stopPropagation = false;
  final ComponentBase target;

  ComponentEvent(this.target);

  void stopPropagation() {
    _stopPropagation = true;
  }
}