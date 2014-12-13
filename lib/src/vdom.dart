// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Virtual DOM
library liquid.vdom;

import 'dart:html' as html;
import 'package:vdom/vdom.dart';

import 'package:liquid/src/utils.dart';
import 'package:liquid/src/component.dart';

part 'package:liquid/src/vdom/basic.dart';
part 'package:liquid/src/vdom/component.dart';
part 'package:liquid/src/vdom/root.dart';
part 'package:liquid/src/vdom/root_decorator.dart';

part 'package:liquid/src/vdom/elements/abbr.dart';
part 'package:liquid/src/vdom/elements/map.dart';
part 'package:liquid/src/vdom/elements/area.dart';
part 'package:liquid/src/vdom/elements/check_box.dart';
part 'package:liquid/src/vdom/elements/label.dart';
part 'package:liquid/src/vdom/elements/text_input.dart';
part 'package:liquid/src/vdom/elements/text_area.dart';
part 'package:liquid/src/vdom/elements/link.dart';
part 'package:liquid/src/vdom/elements/img.dart';
