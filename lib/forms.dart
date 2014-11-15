// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library liquid.forms;

import 'dart:html';
import 'package:vdom/vdom.dart' as v;

part 'package:liquid/src/forms/text_input.dart';
part 'package:liquid/src/forms/check_box.dart';

TextInput textInput(Object key,
                    {String value: null,
                     Map<String, String> attributes: null,
                     List<String> classes: null,
                     Map<String, String> styles: null}) {
  return new TextInput(key,
      value: value,
      attributes: attributes,
      classes: classes,
      styles: styles);
}

CheckBox checkBox(Object key,
                  {bool checked: null,
                   Map<String, String> attributes: null,
                   List<String> classes: null,
                   Map<String, String> styles: null}) {
  return new CheckBox(key,
      checked: checked,
      attributes: attributes,
      classes: classes,
      styles: styles);
}
