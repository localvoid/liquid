// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid.components;

class CheckBox extends v.ElementBase {
  final bool _checked;

  bool get checked => (ref as CheckboxInputElement).checked;

  CheckBox(Object key,
      {bool checked: null,
       Map<String, String> attributes: null,
       List<String> classes: null,
       Map<String, String> styles: null})
       : _checked = checked,
         super(key, attributes: attributes, classes: classes, styles: styles);

  void create(v.Context context) {
    ref = new CheckboxInputElement();
  }

  void render(v.Context context) {
    super.render(context);
    if (_checked != null) {
      (ref as CheckboxInputElement).checked = _checked;
    }
  }

  void update(CheckBox other, v.Context context) {
    super.update(other, context);
    final CheckboxInputElement e = ref;
    if (e.checked != other._checked) {
      e.checked = other._checked;
    }
  }
}
