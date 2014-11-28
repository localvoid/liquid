// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:html';
import 'package:vdom/vdom.dart' as v;
import 'package:vdom/helpers.dart' as vdom;
import 'package:liquid/liquid.dart';

class Collapsable extends Component<DivElement> {
  bool collapsed = false;

  Collapsable(Context context) : super(new DivElement(), context) {
    element.onClick.listen((_) {
      collapsed = true;
      invalidate();
    });
  }

  build() {
    final classes = ['collapsable'];
    if (!collapsed) {
      classes.add('collapsable-open');
    } else {
      classes.add('collapsable-close');
    }
    return new VRootDecorator(const [], classes: classes);
  }
}

class VCollapsable extends VComponentContainer<Collapsable, DivElement> {
  VCollapsable(Object key,
      List<v.Node> children,
      {Map<String, String> attributes: null,
       List<String> classes: null,
       Map<String, String> styles: null})
       : super(key, children, attributes, classes, styles);

  void create(Context context) {
    component = new Collapsable(context);
    ref = component.element;
  }
}

class BasicComponent extends Component<ParagraphElement> {
  int _elapsed;
  int get elapsed => _elapsed;

  String get elapsedSeconds => '${(_elapsed / 1000).toStringAsFixed(1)}';

  BasicComponent(Context context, this._elapsed)
      : super(new ParagraphElement(), context);

  void attached() {
    super.attached();
    final start = new DateTime.now().millisecondsSinceEpoch;
    new Timer.periodic(new Duration(milliseconds: 50), (t) {
      _elapsed = new DateTime.now().millisecondsSinceEpoch - start;
      invalidate();
    });
  }

  build() {
    return new VRootElement([vdom.t('Liquid has been successfully '
        'running for $elapsedSeconds seconds.')]);
  }

  void updateProperties(int newElapsed) {
    if (elapsed != newElapsed) {
      _elapsed = newElapsed;
      update();
    }
  }
}

class VBasicComponent extends VComponentBase<BasicComponent, ParagraphElement> {
  int elapsed;

  VBasicComponent(Object key, this.elapsed) : super(key);

  void create(Context context) {
    component = new BasicComponent(context, elapsed);
    ref = component.element;
  }

  void update(VBasicComponent other, Context context) {
    super.update(other, context);
    component.updateProperties(other.elapsed);
  }
}

class App extends Component<DivElement> {
  App(Context context) : super(new DivElement(), context);

  build() {
    return new VRootElement([new VCollapsable(#collapsable, [new VBasicComponent(0, 0)])]);
  }
}

main() {
  injectComponent(new App(null), document.body);
}
