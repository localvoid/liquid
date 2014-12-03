part of liquid.dynamic;

class VGenericComponentContainer extends VGenericComponent with vdom.Container {
  List<vdom.Node> children;

  html.Node get container => component.container;

  VGenericComponentContainer(
      this.children,
      ClassMirror typeMirror,
      Map<Symbol, _Property> propertyTypes,
      Map<Symbol, dynamic> properties,
      Object key,
      String id,
      Map<String, String> attributes,
      List<String> classes,
      Map<String, String> styles)
      : super(typeMirror, propertyTypes, properties, key, id, attributes, classes, styles);

  VGenericComponentContainer call(children) {
    if (children is List) {
      this.children = children;
    } else if (children is String) {
      this.children = [new vdom.Text(children)];
    } else {
      this.children = [children];
    }
    return this;
  }

  void render(Context context) {
    super.render(context);
    renderChildren(children, context);
  }

  void update(VGenericComponentContainer other, Context context) {
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
}

class VGenericComponentContainerFactory extends VGenericComponentFactory {
  VGenericComponentContainerFactory(Type componentType) : super(componentType);

  VGenericComponent _create([Map args]) {
    if (args == null) {
      return new VGenericComponentContainer(null, _classMirror, _propertyTypes,
          null, null, null, null, null, null);
    }
    final properties = new HashMap.from(args);
    final List children = properties.remove(#children);
    final String key = properties.remove(#key);
    final Object id = properties.remove(#id);
    final Map<String, String> attributes = properties.remove(#attributes);
    final List<String> classes = properties.remove(#classes);
    final Map<String, String> styles = properties.remove(#styles);
    return new VGenericComponentContainer(
        children,
        _classMirror,
        _propertyTypes,
        properties,
        key,
        id,
        attributes,
        classes,
        styles);
  }
}

Function vComponentContainerFactory(Type componentType) => new VGenericComponentContainerFactory(componentType);
