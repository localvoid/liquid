// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid;

class RootComponent extends ComponentBase {
  RootComponent();

  void _addInvalidatedChild(ComponentBase c) {
    if (_invalidatedChildren == null) {
      addInvalidatedRoot(this);
    }
    super._addInvalidatedChild(c);
  }

  void injectComponent(Component c, html.Element parentElement) {
    parentElement.append(c.element);
    c.attached();
  }
}