// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html' as html;
import 'package:liquid/liquid.dart';
import 'package:liquid/vdom.dart' as v;

class FormApp extends Component<html.DivElement> {
  String username = '';
  String email = '';
  String password = '';

  init() {
    element.onInput
      ..matches('.UserNameInput').listen((e) {
        username = e.matchingTarget.value;
        invalidate();
        e.stopPropagation();
      })
      ..matches('.EmailInput').listen((e) {
        email = e.matchingTarget.value;
        invalidate();
        e.stopPropagation();
      })
      ..matches('.PasswordInput').listen((e) {
        password = e.matchingTarget.value;
        invalidate();
        e.stopPropagation();
      });
  }

  build() =>
      v.root()([
        v.section(type: 'DisplaySection')([
          v.div()('Username: $username'),
          v.div()('Email: $email'),
          v.div()('Password: $password')
        ]),
        v.section(type: 'FormSection')([
          v.textInput(type: 'UserNameInput', placeholder: 'Username'),
          v.emailInput(type: 'EmailInput', placeholder: 'Email'),
          v.passwordInput(type: 'PasswordInput', placeholder: 'Password')
        ])
      ]);
}

main() {
  injectComponent(new FormApp(), html.querySelector('body'));
}
