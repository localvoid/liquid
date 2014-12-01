// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;
import 'dart:html';
import 'package:vdom/helpers.dart' as vdom;
import 'package:liquid/liquid.dart';

class Box extends Component<DivElement> {
  @property int count = 0;

  Box(Context context) : super(context);

  void create() {
    super.create();
    element.classes.add('box-view');
  }

  build() {
    final top = math.sin(count / 10) * 10;
    final left = math.cos(count / 10) * 10;
    final color = count % 255;
    final content = count % 100;

    return vRoot()(
      vdom.div(classes: ['box'],
               styles: {
                 'top': '${top}px',
                 'left': '${left}px',
                 'background': 'rgb(0, 0, $color)'})(content.toString())
    );
  }
}

final vBox = vComponentFactory(Box);

class App extends Component<DivElement> {
  @property List<int> items;

  App(Context context) : super(context);

  build() {
    var i = 0;

    return vRoot(classes: ['grid'])(
        items.map((item) => vBox(key: i++, count: item)).toList()
    );
  }
}

main() {
  final start = new DateTime.now().millisecondsSinceEpoch;
  final items = new List<int>.filled(100, 0);
  final app = new App(null)..items = items;
  injectComponent(app, document.body);

  /// I know that this is quite stupid :)
  new Timer.periodic(new Duration(), (t) {
    for (var i = 0; i < 100; i++) {
      items[i] += 1;
    }
    app.invalidate();
  });
}
