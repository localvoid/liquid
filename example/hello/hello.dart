// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'package:vdom/helpers.dart' as vdom;
import 'package:liquid/liquid.dart';

class HelloComponent extends VComponent {
  String name;

  HelloComponent(ComponentBase parent, [this.name = 'Hello'])
      : super(parent, new DivElement());

  build() {
    return vdom.div(0, [vdom.t('Hello $name')]);
  }

  static VDomComponent virtual(Object key, ComponentBase parent,
                               [String name = 'Hello']) {
    return new VDomComponent(key, (component) {
      if (component == null) {
        return new HelloComponent(parent, name);
      }
    });
  }
}

main() {
  final root = new RootComponent.mount(document.body);
  final hello = new HelloComponent(root, 'World');
  root.append(hello);
}