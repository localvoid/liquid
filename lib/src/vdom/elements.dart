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

/// Creates a new [Checkbox] element.
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

/// Creates a new [TextInput] element.
VTextInput textInput({
  Object key,
  String value,
  String placeholder,
  bool autofocus,
  String id,
  String type,
  Map<String, String> attributes,
  List<String> classes,
  Map<String, String> styles}) {

  return new VTextInput(
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