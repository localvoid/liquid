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
      : super(parent, new DivElement());

  build() => vdom.div(0, _collapsableChildren);

  void update() {
    if (!isRendered) {
      element.classes.add('collapsable');
      element.onClick.listen((_) {
        toggleCollapse();
      });
    }
    super.update();
  }

  void toggleCollapse() {
    if (collapsed) {
      element.classes.remove('collapsable-close');
      element.classes.add('collapsable-open');
    } else {
      element.classes.remove('collapsable-open');
      element.classes.add('collapsable-close');
    }
  }
}

class BasicComponent extends VComponent {
  int _elapsed;
  int get elapsed => _elapsed;

  String get elapsedSeconds => '${(_elapsed / 1000).toStringAsFixed(1)}';

  BasicComponent(ComponentBase parent, this._elapsed)
      : super(parent, new ParagraphElement());

  void attached() {
    super.attached();
    final start = new DateTime.now().millisecondsSinceEpoch;
    new Timer.periodic(new Duration(milliseconds: 50), (t) {
      _elapsed = new DateTime.now().millisecondsSinceEpoch - start;
      invalidate();
    });
  }

  build() {
    return vdom.p(0, [vdom.t(0, 'Liquid has been successfully '
        'running for $elapsedSeconds seconds.')]);
  }

  void updateProperties(int newElapsed) {
    if (elapsed != newElapsed) {
      _elapsed = newElapsed;
      isDirty = true;
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
  final collapsable = new Collapsable(root, [BasicComponent.virtual(0, root, 0)]);
  root.append(collapsable);
}