// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library liquid.main;

import 'dart:html' as html;
import 'package:dom_scheduler/dom_scheduler.dart';
import 'package:liquid/src/component.dart';

/// DOM Scheduler
final DOMScheduler domScheduler = new DOMScheduler();

/// Inject Component into the DOM
void injectComponent(Component component, html.Element parent,
                     [bool attached = true]) {
  domScheduler.zone.run(() {
    domScheduler.nextFrame.write(0).then((_) {
      component.create();
      component.init();
      parent.append(component.element);
      if (attached) {
        component.attach();
      }
      component.internalUpdate();
    });
  });
}
