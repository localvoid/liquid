// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid;

bool toggleClassName(html.Element element,
                     bool oldValue, bool newValue,
                     String a, [String b = null]) {
  if (oldValue != newValue) {
    if (oldValue == false) {
      if (b != null) {
        element.classes.remove(b);
      }
      element.classes.add(a);
    } else {
      element.classes.remove(a);
      if (b != null) {
        element.classes.add(b);
      }
    }
  }
  return newValue;
}
