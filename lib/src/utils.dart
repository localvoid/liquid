// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library liquid.utils;

bool invariant(condition, [message]) {
  if (condition is Function){
    condition = condition();
  }
  if (!condition) {
    if (message is Function) {
      message = message();
    }
    throw message;
  }
  return true;
}
