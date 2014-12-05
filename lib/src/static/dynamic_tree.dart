// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid.static;

abstract class VDynamicTree extends VStaticTree {
  VDynamicTree(
      Object key,
      String id,
      Map<String, String> attributes,
      List<String> classes,
      Map<String, String> styles)
      : super(key, id, attributes, classes, styles);

  void update(VStaticTree other, vdom.Context context) {
    super.update(other, context);
    other.vRoot = other.build();
    vRoot.update(other.vRoot, context);
  }
}
