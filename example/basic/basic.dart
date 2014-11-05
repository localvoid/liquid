// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:html';
import 'package:vdom/helpers.dart' as vdom;
import 'package:liquid/liquid.dart';

class BasicComponent extends VComponent {
  int _elapsed;
  int get elapsed => _elapsed;
  set elapsed(int v) {
    _elapsed = v;
    invalidate();
  }

  String get elapsedSeconds => '${(_elapsed / 1000).toStringAsFixed(1)}';

  BasicComponent(ComponentBase parent, this._elapsed)
      : super(parent, new ParagraphElement());

  build() {
    return vdom.p(0, [vdom.t('Liquid has been successfully '
        'running for $elapsedSeconds seconds.')]);
  }

  void updateProperties(int newElapsed) {
    if (elapsed != newElapsed) {
      elapsed = newElapsed;
      update();
    }
  }

  static VDomComponent virtual(Object key, ComponentBase parent,
                               int elapsed) {
    return new VDomComponent(key, (component) {
      if (component == null) {
        return new BasicComponent(parent, elapsed);
      }
      component.updateProperties(elapsed);
    });
  }
}

main() {
  final root = new RootComponent.mount(document.body);
  final start = new DateTime.now().millisecondsSinceEpoch;
  final basic = new BasicComponent(root, 0);
  root.append(basic);

  new Timer.periodic(new Duration(milliseconds: 50), (t) {
    basic.elapsed = new DateTime.now().millisecondsSinceEpoch - start;
  });
}