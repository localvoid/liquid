// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'package:vdom/vdom.dart' as v;
import 'package:liquid/liquid.dart';

class HelloComponent extends VComponent {
  String name;

  HelloComponent(ComponentBase parent, [this.name = 'Hello'])
      : super(parent, new DivElement());

  List<v.Node> build() {
    return [new v.Element(0, 'div', [new v.Text(0, 'Hello $name')])];
  }

  void updateProperties(String newName) {
    if (name != newName) {
      name = newName;
      update();
    }
  }

  static VDomComponent virtual(Object key, ComponentBase parent,
                               [String name = 'Hello']) {
    return new VDomComponent(key, (component) {
      if (component == null) {
        return new HelloComponent(parent, name);
      }
      component.updateProperties(name);
    });
  }
}

main() {
  final root = new RootComponent.mount(document.body);
  final hello = new HelloComponent(root, 'World');
  root.append(hello);
}