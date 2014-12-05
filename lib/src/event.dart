// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library liquid.event;

import 'package:liquid/src/component.dart';

/// Base class for Component events.
abstract class ComponentEvent {
  /// Reference to the [Component] from which this event is originates.
  final Component component;

  ComponentEvent(this.component);
}
