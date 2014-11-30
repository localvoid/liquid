// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:html';
import 'package:liquid/liquid.dart';

class Collapsable extends Component<DivElement> {
  @property
  bool collapsed = false;

  Collapsable(Context context) : super(context);

  void create() {
    super.create();
    element.classes.add('collapsable');
    element.onClick.listen((_) {
      collapsed = true;
      invalidate();
    });
  }

  build() => vRootDecorator(
      classes: collapsed ? const ['collapsable-close'] : const ['collapsable-open']);
}

class BasicComponent extends Component<ParagraphElement> {
  @property
  int elapsed = 0;

  String get elapsedSeconds => '${(elapsed / 1000).toStringAsFixed(1)}';

  BasicComponent(Context context) : super(context);

  void create() {
    element = new ParagraphElement();
  }

  void attached() {
    super.attached();
    final start = new DateTime.now().millisecondsSinceEpoch;
    new Timer.periodic(new Duration(milliseconds: 50), (t) {
      elapsed = new DateTime.now().millisecondsSinceEpoch - start;
      invalidate();
    });
  }

  build() =>
      vRoot()('Liquid has been successfully running for $elapsedSeconds seconds.');
}

final vCollapsable = vComponentContainerFactory(Collapsable);
final vBasicComponent = vComponentFactory(BasicComponent);

class App extends Component<DivElement> {
  App(Context context) : super(context);

  build() {
    return vRoot()(
        vCollapsable(null, null)(
            vBasicComponent(null, {#elapsed: 0})
        )
    );
  }
}

main() {
  injectComponent(new App(null), document.body);
}
