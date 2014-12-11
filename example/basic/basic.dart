// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:html';
import 'package:liquid/liquid.dart';
import 'package:liquid/vdom.dart' as vdom;

class BasicComponent extends Component {
  @property() int elapsed = 0;

  String get elapsedSeconds => '${(elapsed / 1000).toStringAsFixed(1)}';

  void create() { element = new ParagraphElement(); }

  build() => vdom.root()('Liquid has been successfully running for $elapsedSeconds seconds.');
}

main() {
  final start = new DateTime.now().millisecondsSinceEpoch;
  final basic = new BasicComponent();
  injectComponent(basic, document.body);

  new Timer.periodic(new Duration(milliseconds: 50), (t) {
    basic.elapsed = new DateTime.now().millisecondsSinceEpoch - start;
    basic.invalidate();
  });
}
