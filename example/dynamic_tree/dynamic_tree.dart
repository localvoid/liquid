// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:html';
import 'package:liquid/liquid.dart';
import 'package:liquid/vdom.dart' as vdom;

final dynamicTree = vdom.dynamicTreeFactory(({elapsed}) =>
    vdom.div()(elapsed.toString()));

class App extends Component {
  @property() int elapsed;

  build() => vdom.root()(dynamicTree(elapsed: elapsed));
}

main() {
  final start = new DateTime.now().millisecondsSinceEpoch;

  final app = new App();
  injectComponent(app, document.body);

  new Timer.periodic(new Duration(milliseconds: 50), (t) {
    app.elapsed = new DateTime.now().millisecondsSinceEpoch - start;
    app.invalidate();
  });
}
