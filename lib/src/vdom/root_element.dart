part of liquid;

class VRootElement<T extends html.Element> extends vdom.ElementContainerBase<T> {
  VComponent<T> component;

  VRootElement(List<vdom.Node> children, {
      Map<String, String> attributes: null,
      List<String> classes: null,
      Map<String, String> styles: null})
      : super(0, children, attributes, classes, styles);

  void create(vdom.Context context) {
    throw new UnsupportedError('RootElement doesn\'t support creating, you'
        ' should mount it on top of the existing Element');
  }

  void mount(VComponent<T> component) {
    this.component = component;
    ref = component.element;
  }

  void update(VRootElement<T> other, Context context) {
    super.update(other, context);
    other.component = component;
  }

  void insertBefore(vdom.Node node, html.Node nextRef, Context context) {
    component.insertBefore(node, nextRef);
  }

  void move(vdom.Node node, html.Node nextRef, Context context) {
    component.move(node, nextRef);
  }

  void removeChild(vdom.Node node, Context context) {
    component.removeChild(node);
  }
}