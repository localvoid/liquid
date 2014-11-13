// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid;

/// Inject Component into the DOM
void injectComponent(Component component, html.Element parent) {
  Scheduler.zone.run(() {
    Scheduler.nextFrame.write(0).then((_) {
      parent.append(component.element);
      component.attached();
      component.render();
    });
  });
}