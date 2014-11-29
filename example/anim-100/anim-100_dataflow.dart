// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;
import 'dart:html';
import 'package:vdom/helpers.dart' as vdom;
import 'package:liquid/liquid.dart';

class Box extends Component<DivElement> {
  int count = 0;

  Box(Context context, this.count) : super(context);

  build() {
    final top = math.sin(count / 10) * 10;
    final left = math.cos(count / 10) * 10;
    final color = count % 255;
    final content = count % 100;

    return new VRootElement([
      vdom.div(0, [vdom.t(content.toString())],
        classes: ['box'],
        styles: {
          'top': '${top}px',
          'left': '${left}px',
          'background': 'rgb(0, 0, $color)'
      })],
      classes: ['box-view']);
  }

  void updateProperties(int newCount) {
    if (count != newCount) {
      count = newCount;
      update();
    }
  }
}

class VBox extends VComponentBase<Box, DivElement> {
  int count;

  VBox(Object key, this.count) : super(key);

  void create(Context context) {
    component = new Box(context, count);
    ref = component.element;
  }

  void update(VBox other, Context context) {
    super.update(other, context);
    component.updateProperties(other.count);
  }
}

class App extends Component<DivElement> {
  List<int> items;

  App(Context context, this.items) : super(context);

  build() {
    final result = [];
    for (var i = 0; i < items.length; i++) {
      result.add(new VBox(i, items[i]));
    }
    return new VRootElement(result, classes: ['grid']);
  }
}

main() {
  final start = new DateTime.now().millisecondsSinceEpoch;
  final items = new List<int>.filled(100, 0);
  final app = new App(null, items);
  injectComponent(app, document.body);

  /// I know that this is quite stupid :)
  new Timer.periodic(new Duration(), (t) {
    for (var i = 0; i < 100; i++) {
      items[i] += 1;
    }
    app.invalidate();
  });
}
