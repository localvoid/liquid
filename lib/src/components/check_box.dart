part of liquid.components;

class CheckBox extends Component {
  final bool _controlled;
  bool _checked;
  bool get checked => _checked;
  set checked(bool newChecked) {
    if (_checked != newChecked) {
      _checked = newChecked;
      (element as InputElement).checked = _checked;
    }
  }

  CheckBox(Object key, ComponentBase parent,
      {Symbol className, bool checked: null,
       Map<String, String> attributes: null})
      : _controlled = checked == null ? false : true,
        _checked = checked,
        super(parent, new InputElement(type: 'checkbox'),
              key: key,
              className: className,
              flags: ComponentBase.cleanFlag) {
    if (checked != null) {
      (element as InputElement).checked = checked;
    }
    if (attributes != null) {
      attributes.forEach((k, v) {
        element.setAttribute(k, v);
      });
    }
  }

  static VDomComponent virtual(Object key, ComponentBase parent,
                              {Symbol className, bool checked: null,
                               Map<String, String> attributes: null,
                               VRef<CheckBox> ref: null}) {
    return new VDomComponent(key, (component) {
      if (component == null) {
        component = new CheckBox(key, parent,
            className: className,
            checked: checked,
            attributes: attributes);
        if (ref != null) {
          ref.set(component);
        }
        return component;
      }
      if (component._controlled) {
        component.checked = checked;
      }
      return null;
    });
  }
}
