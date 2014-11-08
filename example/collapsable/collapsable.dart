// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:html';
import 'package:vdom/vdom.dart' as v;
import 'package:vdom/helpers.dart' as vdom;
import 'package:liquid/liquid.dart';

class Collapsable extends VComponent {
  bool collapsed = false;
  List<v.Node> _collapsableChildren;

  Collapsable(ComponentBase parent, this._collapsableChildren)
      : super('div', parent) {
    Zone.ROOT.run(() {
      element.onClick.listen((_) {
        collapsed = true;
        invalidate();
      });
    });
  }

  build() {
    final classes = ['collapsable'];
    if (!collapsed) {
      classes.add('collapsable-open');
    } else {
      classes.add('collapsable-close');
    }
    return vdom.div(0, _collapsableChildren, classes: classes);
  }
}

class BasicComponent extends VComponent {
  int _elapsed;
  int get elapsed => _elapsed;

  String get elapsedSeconds => '${(_elapsed / 1000).toStringAsFixed(1)}';

  BasicComponent(ComponentBase parent, this._elapsed)
      : super('p', parent);

  void attached() {
    super.attached();
    final start = new DateTime.now().millisecondsSinceEpoch;
    new Timer.periodic(new Duration(milliseconds: 50), (t) {
      _elapsed = new DateTime.now().millisecondsSinceEpoch - start;
      invalidate();
    });
  }

  build() {
    return vdom.p(0, [vdom.t('Liquid has been successfully '
        'running for $elapsedSeconds seconds.')]);
  }

  void updateProperties(int newElapsed) {
    if (elapsed != newElapsed) {
      _elapsed = newElapsed;
      update();
    }
  }

  static VDomComponent virtual(Object key, int elapsed) {
    return new VDomComponent(key, (component, context) {
      if (component == null) {
        return new BasicComponent(context, elapsed);
      }
      component.updateProperties(elapsed);
    });
  }
}

main() {
  final root = new RootComponent.mount(document.body);
  final collapsable = new Collapsable(root, [BasicComponent.virtual(0, 0)]);
  root.append(collapsable);
}
