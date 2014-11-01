part of liquid.components;

class TextInputComponent extends Component {
  final bool _controlled;
  String _value;
  String get value => _value;
  set value(String newValue) {
    if (_value != newValue) {
      _value = newValue;
      (element as InputElement).value = value;
    }
  }

  bool get isEmpty => _value.isEmpty;
  bool get isNotEmpty => _value.isNotEmpty;

  TextInputComponent(Object key, ComponentBase parent,
      {Symbol className, String value: null,
       Map<String, String> attributes: null})
      : _controlled = value == null ? false : true,
        _value = value,
        super(parent, new InputElement(type: 'text'),
              key: key,
              className: className,
              flags: ComponentBase.cleanFlag) {
    if (_value != null) {
      (element as InputElement).value = value;
    }
    if (attributes != null) {
      attributes.forEach((k, v) {
        element.setAttribute(k, v);
      });
    }
  }

  static VDomComponent virtual(Object key, ComponentBase parent,
                              {Symbol className,
                               String value: null,
                               Map<String, String> attributes: null,
                               VRef<TextInputComponent> ref: null}) {
    return new VDomComponent(key, (component) {
      if (component == null) {
        component = new TextInputComponent(key, parent,
            className: className,
            value: value,
            attributes: attributes);
        if (ref != null) {
          ref.set(component);
        }
        return component;
      }
      component.value = value;
    });
  }
}
