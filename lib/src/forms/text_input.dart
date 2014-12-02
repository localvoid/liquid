// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid.forms;

/// Creates a new [VTextInput] element.
VTextInput vTextInput({
  Object key,
  String value,
  String id,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VTextInput(
      key: key,
      value: value,
      id: id,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

/// Virtual DOM Text Input Element
class VTextInput extends v.ElementBase<InputElement> {
  final String _value;

  String get value => ref.value;

  VTextInput({
    Object key,
    String value,
    String id,
    Map<String, String> attributes,
    List<String> classes,
    Map<String, String> styles})
    : _value = value,
      super(key, id, attributes, classes, styles);

  void create(v.Context context) { ref = new InputElement(type: 'text'); }

  void render(v.Context context) {
    super.render(context);
    if (_value != null) {
      ref.value = _value;
    }
  }

  void update(VTextInput other, v.Context context) {
    super.update(other, context);
    if (other._value != null && ref.value != other._value) {
      ref.value = other._value;
    }
  }
}
