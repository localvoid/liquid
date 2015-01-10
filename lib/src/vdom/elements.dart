// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid.vdom;

/// Creates a new [VAbbr] element.
VAbbr abbr({
  Object key,
  String title,
  List<VNode> children,
  String id,
  String type,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VAbbr(
      key: key,
      title: title,
      children: children,
      id: id,
      type: type,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

/// Creates a new [VArea] element.
VArea area({
  Object key,
  String shape,
  String coords,
  String href,
  String alt,
  List<VNode> children,
  String id,
  String type,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VArea(
      key: key,
      shape: shape,
      coords: coords,
      href: href,
      alt: alt,
      children: children,
      id: id,
      type: type,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

/// Creates a new [VImg] element.
VImg img({
  Object key,
  String src,
  String alt,
  String title,
  bool checked,
  List<VNode> children,
  String id,
  String type,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VImg(
      key: key,
      src: src,
      alt: alt,
      title: title,
      children: children,
      id: id,
      type: type,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

/// Creates a new [VLabel] element.
VLabel label({
  Object key,
  String htmlFor,
  List<VNode> children,
  String id,
  String type,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VLabel(
      key: key,
      htmlFor: htmlFor,
      children: children,
      id: id,
      type: type,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

/// Creates a new [VLink] element.
VLink link({
  Object key,
  String href,
  String title,
  List<VNode> children,
  String id,
  String type,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VLink(
      key: key,
      href: href,
      title: title,
      children: children,
      id: id,
      type: type,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

/// Creates a new [VMap] element.
VMap map({
  Object key,
  String name,
  List<VNode> children,
  String id,
  String type,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VMap(
      key: key,
      name: name,
      children: children,
      id: id,
      type: type,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

/// Creates a new [VTextArea] element.
///
/// deprecated in favour of [textArea]
@deprecated
VTextArea textarea({
  Object key,
  String value,
  String placeholder,
  bool autofocus,
  String id,
  String type,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VTextArea(
      key: key,
      value: value,
      placeholder: placeholder,
      autofocus: autofocus,
      id: id,
      type: type,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

/// Creates a new [VTextArea] element.
VTextArea textArea({
  Object key,
  String value,
  String placeholder,
  bool autofocus,
  String id,
  String type,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VTextArea(
      key: key,
      value: value,
      placeholder: placeholder,
      autofocus: autofocus,
      id: id,
      type: type,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

/// Creates a new [VTextInput] element.
VTextInput textInput({
  Object key,
  String value,
  bool disabled,
  String placeholder,
  int maxLength,
  bool autofocus,
  String id,
  String type,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VTextInput(
      key: key,
      value: value,
      disabled: disabled,
      placeholder: placeholder,
      maxLength: maxLength,
      autofocus: autofocus,
      id: id,
      type: type,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

/// Creates a new [VPasswordInput] element.
VPasswordInput passwordInput({
  Object key,
  String value,
  bool disabled,
  String placeholder,
  int maxLength,
  bool autofocus,
  String id,
  String type,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VPasswordInput(
      key: key,
      value: value,
      disabled: disabled,
      placeholder: placeholder,
      maxLength: maxLength,
      autofocus: autofocus,
      id: id,
      type: type,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

/// Creates a new [VEmailInput] element.
VEmailInput emailInput({
  Object key,
  String value,
  bool disabled,
  String placeholder,
  int maxLength,
  bool autofocus,
  String id,
  String type,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VEmailInput(
      key: key,
      value: value,
      disabled: disabled,
      placeholder: placeholder,
      maxLength: maxLength,
      autofocus: autofocus,
      id: id,
      type: type,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

/// Creates a new [VUrlInput] element.
VUrlInput urlInput({
  Object key,
  String value,
  bool disabled,
  String placeholder,
  int maxLength,
  bool autofocus,
  String id,
  String type,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VUrlInput(
      key: key,
      value: value,
      disabled: disabled,
      placeholder: placeholder,
      maxLength: maxLength,
      autofocus: autofocus,
      id: id,
      type: type,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

/// Creates a new [VTelInput] element.
VTelInput telInput({
  Object key,
  String value,
  bool disabled,
  String placeholder,
  int maxLength,
  bool autofocus,
  String id,
  String type,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VTelInput(
      key: key,
      value: value,
      disabled: disabled,
      placeholder: placeholder,
      maxLength: maxLength,
      autofocus: autofocus,
      id: id,
      type: type,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

/// Creates a new [VNumberInput] element.
VNumberInput numberInput({
  Object key,
  String value,
  bool disabled,
  String placeholder,
  int maxLength,
  bool autofocus,
  String id,
  String type,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VNumberInput(
      key: key,
      value: value,
      disabled: disabled,
      placeholder: placeholder,
      maxLength: maxLength,
      autofocus: autofocus,
      id: id,
      type: type,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

/// Creates a new [VSearchInput] element.
VSearchInput searchInput({
  Object key,
  String value,
  bool disabled,
  String placeholder,
  int maxLength,
  bool autofocus,
  String id,
  String type,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VSearchInput(
      key: key,
      value: value,
      disabled: disabled,
      placeholder: placeholder,
      maxLength: maxLength,
      autofocus: autofocus,
      id: id,
      type: type,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

/// Creates a new [VTimeInput] element.
VTimeInput timeInput({
  Object key,
  String value,
  bool disabled,
  bool autofocus,
  String id,
  String type,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VTimeInput(
      key: key,
      value: value,
      disabled: disabled,
      autofocus: autofocus,
      id: id,
      type: type,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

/// Creates a new [VWeekInput] element.
VWeekInput weekInput({
  Object key,
  String value,
  bool disabled,
  bool autofocus,
  String id,
  String type,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VWeekInput(
      key: key,
      value: value,
      disabled: disabled,
      autofocus: autofocus,
      id: id,
      type: type,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

/// Creates a new [VMonthInput] element.
VMonthInput monthInput({
  Object key,
  String value,
  bool disabled,
  bool autofocus,
  String id,
  String type,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VMonthInput(
      key: key,
      value: value,
      disabled: disabled,
      autofocus: autofocus,
      id: id,
      type: type,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

/// Creates a new [VDateInput] element.
VDateInput dateInput({
  Object key,
  String value,
  bool disabled,
  bool autofocus,
  String id,
  String type,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VDateInput(
      key: key,
      value: value,
      disabled: disabled,
      autofocus: autofocus,
      id: id,
      type: type,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

/// Creates a new [VDateTimeInput] element.
VDateTimeInput dateTimeInput({
  Object key,
  String value,
  bool disabled,
  bool autofocus,
  String id,
  String type,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VDateTimeInput(
      key: key,
      value: value,
      disabled: disabled,
      autofocus: autofocus,
      id: id,
      type: type,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

/// Creates a new [VLocalDateTimeInput] element.
VLocalDateTimeInput localDateTimeInput({
  Object key,
  String value,
  bool disabled,
  bool autofocus,
  String id,
  String type,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VLocalDateTimeInput(
      key: key,
      value: value,
      disabled: disabled,
      autofocus: autofocus,
      id: id,
      type: type,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

/// Creates a new [VColorInput] element.
VColorInput colorInput({
  Object key,
  String value,
  bool disabled,
  bool autofocus,
  String id,
  String type,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VColorInput(
      key: key,
      value: value,
      disabled: disabled,
      autofocus: autofocus,
      id: id,
      type: type,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

/// Creates a new [VFileInput] element.
VFileInput fileInput({
  Object key,
  String value,
  String accept,
  bool multiple,
  bool disabled,
  bool autofocus,
  String id,
  String type,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VFileInput(
      key: key,
      value: value,
      accept: accept,
      multiple: multiple,
      disabled: disabled,
      autofocus: autofocus,
      id: id,
      type: type,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

/// Creates a new [VCheckBox] element.
///
/// Deprecated in favour of [checkBox]
@deprecated
VCheckBox checkbox({
  Object key,
  bool checked,
  String id,
  String type,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VCheckBox(
      key: key,
      checked: checked,
      id: id,
      type: type,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

/// Creates a new [VCheckBox] element.
VCheckBox checkBox({
  Object key,
  bool checked,
  String id,
  String type,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VCheckBox(
      key: key,
      checked: checked,
      id: id,
      type: type,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

/// Creates a new [VRadioButton] element.
VRadioButton radioButton({
  Object key,
  bool checked,
  String id,
  String type,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VRadioButton(
      key: key,
      checked: checked,
      id: id,
      type: type,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

/// Creates a new [VSlider] element.
VSlider slider({
  Object key,
  String value,
  int max,
  int min,
  int step,
  String id,
  String type,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VSlider(
      key: key,
      value: value,
      max: max,
      min: min,
      step: step,
      id: id,
      type: type,
      attributes: attributes,
      classes: classes,
      styles: styles);
}
