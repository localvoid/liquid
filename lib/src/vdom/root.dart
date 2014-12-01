part of liquid;

abstract class VRootBase<T extends html.Element> extends vdom.ElementContainerBase<T> {
  Component<T> component;

  // TODO: add id property
  VRootBase(List<vdom.Node> children,
      Map<String, String> attributes,
      List<String> classes,
      Map<String, String> styles)
      : super(null, children, null, attributes, classes, styles);

  void create(vdom.Context context) {
    throw new UnsupportedError('VRootBase doesn\'t support creating, you'
        ' should mount it on top of the existing Element');
  }

  void link(VRootDecorator<T> parent) {}

  void mount(Component<T> component) {
    this.component = component;
    ref = component.element;
  }

  void update(VRootBase<T> other, Context context) {
    super.update(other, context);
    other.component = component;
  }
}

// TODO: doesn't work properly, use double-linked lists
class VRootDecorator<T extends html.Element> extends VRootBase<T> {
  VRootDecorator<T> parent;
  VRootBase<T> _next;
  html.Node container;
  vdom.Node innerContainer;

  VRootDecorator({List<vdom.Node> children,
      this.innerContainer,
      Map<String, String> attributes,
      List<String> classes,
      Map<String, String> styles})
      : super(children, attributes, classes, styles);

  void decorate(VRootBase<T> root) {
    _next = root;
    root.link(this);
  }

  void link(VRootDecorator<T> parent) {
    this.parent = parent;
  }

  void mount(Component<T> component) {
    super.mount(component);
    if (_next != null) {
      _next.mount(component);
    }
  }

  void render(Context context) {
    if (parent == null) {
      container = ref;
    } else {
      if (parent.innerContainer == null) {
        container = parent.container;
      } else {
        container = parent.innerContainer.ref;
      }
    }
    super.render(context);
    if (_next != null) {
      _next.render(context);
    }
  }

  void update(VRootDecorator<T> other, Context context) {
    if (parent == null) {
      container = ref;
    } else {
      if (parent.innerContainer == null) {
        container = parent.container;
      } else {
        container = parent.innerContainer.ref;
      }
    }
    super.update(other, context);
    if (_next != null) {
      _next.update(other._next, context);
    }
  }
}

class VRoot<T extends html.Element> extends VRootBase<T> {
  VRoot({List<vdom.Node> children,
      Map<String, String> attributes,
      List<String> classes,
      Map<String, String> styles})
      : super(children, attributes, classes, styles);

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

VRootDecorator vRootDecorator({
  List<vdom.Node> children,
  vdom.Node innerContainer,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VRootDecorator(
      children: children,
      innerContainer: innerContainer,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

VRoot vRoot({
  List<vdom.Node> children,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VRoot(
      children: children,
      attributes: attributes,
      classes: classes,
      styles: styles);
}
