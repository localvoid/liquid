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
    return vdom.div(0, [Box.virtual(0)], classes: ['outer-box']);
  }

  static VDomComponent virtual(Object key) {
    return new VDomComponent(key, (component, context) {
      if (component == null) {
        return new OuterBox(context);
      }
    });
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
      return vdom.div(0, [InnerBox.virtual(0, _childRef)], classes: ['box']);
    } else {
      return vdom.div(0, [vdom.div(10, [vdom.t('Outer: $_outerWidth')]),
                          vdom.div(11, [vdom.t('Inner: $_innerWidth')]),
                          InnerBox.virtual(0, _childRef)], classes: ['box']);
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

  static VDomComponent virtual(Object key) {
    return new VDomComponent(key, (component, context) {
      if (component == null) {
        return new Box(context);
      }
    });
  }
}

class InnerBox extends VComponent {
  InnerBox(ComponentBase parent) : super('div', parent);

  build() {
    return vdom.div(0, [vdom.t('x')], classes: ['inner-box']);
  }

  static VDomComponent virtual(Object key, VRef<InnerBox> ref) {
    return new VDomComponent(key, (component, context) {
      if (component == null) {
        final c = new InnerBox(context);
        ref.set(c);
        return c;
      }
    });
  }
}

class App extends VComponent {
  App(ComponentBase parent) : super('div', parent);

  build() {
    return vdom.div(0, [OuterBox.virtual(0),
                        OuterBox.virtual(1),
                        OuterBox.virtual(2)]);
  }
}

main() {
  final root = new RootComponent.mount(document.body);
  final app = new App(root);
  root.append(app);
}
