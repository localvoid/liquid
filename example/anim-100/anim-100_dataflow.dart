// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;
import 'dart:html';
import 'package:vdom/vdom.dart' as v;
import 'package:liquid/liquid.dart';

class Box extends VComponent {
  int count = 0;

  Box(ComponentBase parent, this.count)
      : super(parent, new DivElement()) {
    element.classes.add('box-view');
  }

  build() {
    final top = math.sin(count / 10) * 10;
    final left = math.cos(count / 10) * 10;
    final color = count % 255;
    final content = count % 100;

    return [new v.Element(0, 'div', [new v.Text(0, content.toString())], null, ['box'], {
      'top': '${top}px',
      'left': '${left}px',
      'background': 'rgb(0, 0, $color)'
    })];
  }

  void updateProperties(int newCount) {
    if (count != newCount) {
      count = newCount;
      update();
    }
  }

  static VDomComponent virtual(Object key, ComponentBase parent,
                               int count) {
    return new VDomComponent(key, (component) {
      if (component == null) {
        return new Box(parent, count);
      }
      component.updateProperties(count);
    });
  }
}

class App extends VComponent {
  List<int> items;

  App(ComponentBase parent, this.items)
      : super(parent, new DivElement()) {
    element.classes.add('grid');
  }

  build() {
    final result = [];
    for (var i = 0; i < items.length; i++) {
      result.add(Box.virtual(i, this, items[i]));
    }
    return result;
  }
}

main() {
  final root = new RootComponent.mount(document.body);
  final start = new DateTime.now().millisecondsSinceEpoch;
  final items = new List<int>.filled(100, 0);
  final app = new App(root, items);
  root.append(app);

  new Timer.periodic(new Duration(), (t) {
    for (var i = 0; i < 100; i++) {
      items[i] += 1;
    }
    app.invalidate();
  });
}