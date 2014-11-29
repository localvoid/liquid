// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'package:vdom/helpers.dart' as vdom;
import 'package:liquid/liquid.dart';
import 'package:liquid/forms.dart';
import 'package:liquid/dynamic.dart';

class Item {
  static int __nextId = 0;
  final int id;
  String text;

  Item([this.text = '']) : id = __nextId++;
}

class TodoItem extends Component<LIElement> {
  @property
  Item item;

  TodoItem(Context context) : super(context);

  void create() {
    element = new LIElement();
  }

  build() => new VRoot([vdom.t(item.text)]);
}

class TodoList extends Component<UListElement> {
  @property
  List<Item> items;

  TodoList(Context context) : super(context);

  void create() {
    element = new UListElement();
  }

  build() => new VRoot(items.map((i) => vTodoItem(i.id, {#item: i})).toList());
}

final vTodoItem = vComponentFactory(TodoItem);
final vTodoList = vComponentFactory(TodoList);

class TodoApp extends Component<DivElement> {
  final List<Item> items;
  String inputText = '';

  TodoApp(Context context, this.items) : super(context);

  void create() {
    super.create();
    _initEventListeners();
  }

  void _initEventListeners() {
    element.onClick.matches('.add-button').listen((e) {
      if (inputText.isNotEmpty) {
        _addItem(inputText);
        inputText = '';
        invalidate();
      }
      e.preventDefault();
      e.stopPropagation();
    });

    element.onChange.matches('input').listen((e) {
      InputElement element = e.matchingTarget;
      inputText = element.value;
      e.stopPropagation();
    });
  }

  void _addItem(String text) {
    items.add(new Item(text));
  }

  build() {
    return new VRoot([
      vdom.h3(0, [vdom.t('TODO')]),
      vTodoList(1, {#items: items}),
      vdom.form(2, [
        new TextInput(0, value: inputText),
        vdom.button(1, [vdom.t('Add item')], classes: ['add-button'])
        ])
      ]);
  }
}

main() {
  injectComponent(new TodoApp(null, []), document.body);
}
