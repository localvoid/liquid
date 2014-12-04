// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid.forms;

/// Creates a new [VCheckbox] element.
VCheckbox vCheckbox({
  Object key,
  bool checked,
  String id,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VCheckbox(
      key: key,
      checked: checked,
      id: id,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

/// Virtual DOM Checkbox Element
class VCheckbox extends v.VElementBase<CheckboxInputElement> {
  final bool _checked;

  bool get checked => ref.checked;

  VCheckbox({
    Object key,
    bool checked,
    String id,
    Map<String, String> attributes,
    List<String> classes,
    Map<String, String> styles})
    : _checked = checked,
      super(key, id, attributes, classes, styles);

  void create(v.VContext context) { ref = new CheckboxInputElement(); }

  void render(v.VContext context) {
    super.render(context);
    if (_checked != null) {
      ref.checked = _checked;
    }
  }

  void update(VCheckbox other, v.VContext context) {
    super.update(other, context);
    if (other._checked != null && ref.checked != other._checked) {
      ref.checked = other._checked;
    }
  }
}
