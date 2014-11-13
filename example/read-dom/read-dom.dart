// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:html';
import 'package:vdom/helpers.dart' as vdom;
import 'package:liquid/liquid.dart';

class OuterBox extends VComponent {
  OuterBox(Object key, Context context) : super(key, 'div', context);

  build() {
    return vdom.div(0, [Box.virtual(0, this)], classes: ['outer-box']);
  }

  static VDomComponent virtual(Object key) {
    return new VDomComponent(key, (component, key, context) {
      assert(component == null);
      return new OuterBox(key, context);
    });
  }
}

class Box extends VComponent {
  final OuterBox parent;
  int _state = 0;
  int _outerWidth = 0;
  int _innerWidth = 0;
  VDomComponent _child;
  StreamSubscription _resizeSub;

  Box(Object key, Context context, this.parent) : super(key, 'div', context);

  build() {
    _child = InnerBox.virtual(0);
    if (_state == 0) {
      return vdom.div(0, [_child], classes: ['box']);
    } else {
      return vdom.div(0, [vdom.div(10, [vdom.t('Outer: $_outerWidth')]),
                          vdom.div(11, [vdom.t('Inner: $_innerWidth')]),
                          _child], classes: ['box']);
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
      _innerWidth = (_child.ref as Element).clientWidth;
      _state = 1;
      writeDOM().then((_) {
        updateSubtree();
        updateFinish();
      });
    });
  }

  static VDomComponent virtual(Object key, OuterBox parent) {
    return new VDomComponent(key, (component, key, context) {
      assert(component == null);
      return new Box(key, context, parent);
    });
  }
}

class InnerBox extends VComponent {
  InnerBox(Object key, Context context) : super(key, 'div', context);

  build() {
    return vdom.div(0, [vdom.t('x')], classes: ['inner-box']);
  }

  static VDomComponent virtual(Object key) {
    return new VDomComponent(key, (component, key, context) {
      if (component == null) {
        return new InnerBox(key, context);
      }
    });
  }
}

class App extends VComponent {
  App(Object key, Context context) : super(key, 'div', context);

  build() {
    return vdom.div(0, [OuterBox.virtual(0),
                        OuterBox.virtual(1),
                        OuterBox.virtual(2)]);
  }
}

main() {
  injectComponent(new App(0, null), document.body);
}
