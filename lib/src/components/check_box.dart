// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid.components;

class CheckBoxComponent extends Component {
  final bool _controlled;
  bool _checked;
  bool get checked => _checked;
  set checked(bool newChecked) {
    if (_checked != newChecked) {
      _checked = newChecked;
      (element as InputElement).checked = _checked;
    }
  }

  CheckBoxComponent(Object key, ComponentBase parent,
      {Symbol type, bool checked: null,
       Map<String, String> attributes: null})
      : _controlled = checked == null ? false : true,
        _checked = checked,
        super(new InputElement(type: 'checkbox'),
              parent,
              key: key,
              type: type) {
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
                              {Symbol type, bool checked: null,
                               Map<String, String> attributes: null,
                               VRef<CheckBoxComponent> ref: null}) {
    return new VDomComponent(key, (component) {
      if (component == null) {
        component = new CheckBoxComponent(key, parent,
            type: type,
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
