part of liquid;

abstract class VRootBase<T extends html.Element> extends vdom.ElementContainerBase<T> {
  Component<T> component;

  VRootBase(List<vdom.Node> children,
      Map<String, String> attributes,
      List<String> classes,
      Map<String, String> styles)
      : super(0, children, attributes, classes, styles);

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

class VRootDecorator<T extends html.Element> extends VRootBase<T> {
  VRootDecorator<T> parent = null;
  VRootBase<T> _next = null;
  html.Node container;
  vdom.Node innerContainer;

  VRootDecorator(List<vdom.Node> children, {
      this.innerContainer: null,
      Map<String, String> attributes: null,
      List<String> classes: null,
      Map<String, String> styles: null})
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

class VRootElement<T extends html.Element> extends VRootBase<T> {
  VRootElement(List<vdom.Node> children, {
      Map<String, String> attributes: null,
      List<String> classes: null,
      Map<String, String> styles: null})
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