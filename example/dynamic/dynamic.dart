// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'package:vdom/vdom.dart' as vdom;
import 'package:vdom/helpers.dart' as vdom;
import 'package:liquid/liquid.dart';
import 'package:liquid/dynamic.dart';

class HelloComponent extends Component<DivElement> {
  String name;

  HelloComponent(Context context, this.name) : super(context);

  void updateProperties(String newName) {
    if (name != newName) {
      name = newName;
      update();
    }
  }

  build() {
    return new VRootElement([vdom.t('Hello $name')]);
  }
}

final vHelloFactory = vComponentFactory(HelloComponent);

class App extends Component<DivElement> {
  App(Context context) : super(context);

  build() {
    return new VRootElement([vHelloFactory(0, ['world'])]);
  }
}

main() {
  injectComponent(new App(null), document.body);
}
