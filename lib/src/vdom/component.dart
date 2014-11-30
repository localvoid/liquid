part of liquid;

abstract class VComponentBase<C extends Component<T>, T extends html.Element>
  extends vdom.Node<T> {
  C component = null;

  VComponentBase(Object key) : super(key);

  void create(Context context);

  void render(Context context) {
    component.render();
  }

  void update(VComponentBase<C, T> other, Context context) {
    other.ref = ref;
    other.component = component;
  }

  void attached() {
    component.attached();
  }

  void detached() {
    component.detached();
  }

  String toString() => (component == null) ?
      'VComponentBase[stateless]' : 'VComponentBase[$component]';
}

abstract class VComponent<C extends Component<T>, T extends html.Element>
    extends VComponentBase<C, T> {
  Map<String, String> attributes;
  List<String> classes;
  Map<String, String> styles;

  VComponent(Object key, this.attributes, this.classes, this.styles)
       : super(key);

  void render(Context context) {
    super.render(context);
    if (attributes != null) {
      attributes.forEach((key, value) {
        ref.setAttribute(key, value);
      });
    }
    if (styles != null) {
      styles.forEach((key, value) {
        ref.style.setProperty(key, value);
      });
    }
    if (classes != null) {
      ref.classes.addAll(classes);
    }
  }

  void update(VComponent<C, T> other, Context context) {
    super.update(other, context);
    if (attributes != null || other.attributes != null) {
      vdom.updateMap(attributes, other.attributes, ref.attributes);
    }
    if (styles != null || other.styles != null) {
      vdom.updateStyle(styles, other.styles, ref.style);
    }
    if (classes != null || other.classes != null) {
      vdom.updateSet(classes, other.classes, ref.classes);
    }
  }

  String toString() => (component == null) ?
      'VComponent[stateless]' : 'VComponent[$component]';
}

abstract class VComponentContainer<C extends Component<T>, T extends html.Element>
    extends VComponent<C, T> with vdom.Container {
  List<vdom.Node> children;

  html.Node get container => component.container;

  VComponentContainer(Object key,
      this.children,
      Map<String, String> attributes,
      List<String> classes,
      Map<String, String> styles)
      : super(key, attributes, classes, styles);

  VComponentContainer<C, T> call(children) {
    if (children is List) {
      this.children = children;
    } else if (children is String) {
      this.children = [new vdom.Text(null, children)];
    } else {
      this.children = [children];
    }
    return this;
  }

  void render(Context context) {
    super.render(context);
    renderChildren(children, context);
  }

  void update(VComponentContainer<C, T> other, Context context) {
    super.update(other, context);
    updateChildren(children, other.children, context);
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

  String toString() => (component == null) ?
      'VComponentContainer[stateless]' : 'VComponentContainer[$component]';
}
