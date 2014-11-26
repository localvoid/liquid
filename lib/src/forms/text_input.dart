// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid.forms;

/// Virtual DOM Text Input Element
class TextInput extends v.ElementBase<InputElement> {
  final String _value;

  String get value => ref.value;

  TextInput(Object key,
      {String value: null,
       Map<String, String> attributes: null,
       List<String> classes: null,
       Map<String, String> styles: null})
       : _value = value,
         super(key, attributes, classes, styles);

  void create(v.Context context) {
    ref = new InputElement(type: 'text');
  }

  void render(v.Context context) {
    super.render(context);
    if (_value != null) {
      ref.value = _value;
    }
  }

  void update(TextInput other, v.Context context) {
    super.update(other, context);
    if (other._value != null && ref.value != other._value) {
      ref.value = other._value;
    }
  }
}
