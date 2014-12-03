// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid;

/// DOM Scheduler
final DOMScheduler domScheduler = new DOMScheduler();

/// Inject Component into the DOM
void injectComponent(Component component, html.Element parent) {
  domScheduler.zone.run(() {
    domScheduler.nextFrame.write(0).then((_) {
      component.create();
      parent.append(component.element);
      component.attach();
      component.update();
    });
  });
}