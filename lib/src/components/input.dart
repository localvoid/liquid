// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid.components;

class TextInputComponent extends Component {
  final bool _controlled;
  String get value => (element as InputElement).value;
  set value(String newValue) {
    InputElement e = element;
    if (e.value != newValue) {
      e.value = newValue;
    }
  }

  bool get isEmpty => value.isEmpty;
  bool get isNotEmpty => value.isNotEmpty;

  TextInputComponent(Object key, ComponentBase parent,
      {Symbol type, String value: null,
       Map<String, String> attributes: null})
      : _controlled = value == null ? false : true,
        super(new InputElement(type: 'text'),
              parent,
              key: key,
              type: type) {
    if (value != null) {
      this.value = value;
    }
    if (attributes != null) {
      attributes.forEach((k, v) {
        element.setAttribute(k, v);
      });
    }
  }

  static VDomComponent virtual(Object key, ComponentBase parent,
                              {Symbol type,
                               String value: null,
                               Map<String, String> attributes: null,
                               VRef<TextInputComponent> ref: null}) {
    return new VDomComponent(key, (component) {
      if (component == null) {
        component = new TextInputComponent(key, parent,
            type: type,
            value: value,
            attributes: attributes);
        if (ref != null) {
          ref.set(component);
        }
        return component;
      }
      if (component._controlled) {
        component.value = value;
      }
    });
  }
}
