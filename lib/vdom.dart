// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library liquid.vdom;

import 'dart:html' as html;
import 'package:vdom/vdom.dart';
import 'package:liquid/liquid.dart' as liquid;

export 'package:vdom/vdom.dart';
export 'package:liquid/dynamic.dart' show staticTreeFactory,
  dynamicTreeFactory, componentFactory, componentContainerFactory;

part 'package:liquid/src/vdom/basic.dart';
part 'package:liquid/src/vdom/component.dart';
part 'package:liquid/src/vdom/root.dart';

part 'package:liquid/src/vdom/forms/check_box.dart';
part 'package:liquid/src/vdom/forms/text_input.dart';