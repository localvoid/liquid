// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Mirror-based implementation.
library liquid.dynamic;

import 'dart:collection';
import 'dart:mirrors';
import 'package:liquid/src/utils.dart';
import 'package:liquid/src/annotations.dart';
import 'package:liquid/vdom.dart' as vdom;

part 'package:liquid/src/dynamic/property.dart';
part 'package:liquid/src/dynamic/generic_component.dart';
