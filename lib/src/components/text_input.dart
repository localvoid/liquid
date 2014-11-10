// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid.components;

class TextInput extends v.ElementBase {
  final String _value;

  TextInput(Object key,
      {String value: null,
       Map<String, String> attributes: null,
       List<String> classes: null,
       Map<String, String> styles: null})
       : _value = value,
         super(key, attributes: attributes, classes: classes, styles: styles);

  void create(v.Context context) {
    ref = new InputElement(type: 'text');
  }

  void render(v.Context context) {
    if (_value != null) {
      (ref as InputElement).value = _value;
    }
  }

  void update(TextInput other, v.Context context) {
    super.update(other, context);
    final InputElement e = ref;
    if (e.value != other._value) {
      e.value = other._value;
    }
  }
}
