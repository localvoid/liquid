// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:html';
import 'package:vdom/helpers.dart' as vdom;
import 'package:liquid/liquid.dart';

class OuterBox extends VComponent {
  OuterBox(ComponentBase parent) : super('div', parent);

  build() {
    return vdom.div(0, [component(0, Box.init)], classes: ['outer-box']);
  }

  static Component init(component, context) {
    assert(component == null);
    return new OuterBox(context);
  }
}

class Box extends VComponent {
  int _state = 0;
  int _outerWidth = 0;
  int _innerWidth = 0;
  VRef<InnerBox> _childRef = new VRef<InnerBox>();
  StreamSubscription _resizeSub;


  Box(ComponentBase parent) : super('div', parent);

  build() {
    if (_state == 0) {
      return vdom.div(0, [component(0, _childRef.capture(InnerBox.init))], classes: ['box']);
    } else {
      return vdom.div(0, [vdom.div(10, [vdom.t('Outer: $_outerWidth')]),
                          vdom.div(11, [vdom.t('Inner: $_innerWidth')]),
                          component(0, InnerBox.init)], classes: ['box']);
    }
  }

  void attached() {
    Zone.ROOT.run(() {
      _resizeSub = window.onResize.listen((_) {
        invalidate();
      });
    });
    super.attached();
  }

  void detached() {
    _resizeSub.cancel();
    super.detached();
  }

  void update() {
    updateSubtree();
    readDOM().then((_) {
      _outerWidth = parent.element.clientWidth;
      _innerWidth = _childRef.get.element.clientWidth;
      _state = 1;
      writeDOM().then((_) {
        updateSubtree();
        updateFinish();
      });
    });
  }

  static Component init(component, context) {
    assert(component == null);
    return new Box(context);
  }
}

class InnerBox extends VComponent {
  InnerBox(ComponentBase parent) : super('div', parent);

  build() {
    return vdom.div(0, [vdom.t('x')], classes: ['inner-box']);
  }

  static Component init(component, context) {
    if (component == null) {
      return new InnerBox(context);
    }
    return null;
  }
}

class App extends VComponent {
  App(ComponentBase parent) : super('div', parent);

  build() {
    return vdom.div(0, [component(0, OuterBox.init),
                        component(1, OuterBox.init),
                        component(2, OuterBox.init)]);
  }
}

main() {
  final root = new RootComponent.mount(document.body);
  final app = new App(root);
  root.append(app);
}
