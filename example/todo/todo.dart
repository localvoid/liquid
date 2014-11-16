// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'package:vdom/helpers.dart' as vdom;
import 'package:liquid/liquid.dart';
import 'package:liquid/forms.dart';

class Item {
  static int __nextId = 0;
  final int id;
  String text;

  Item([this.text = '']) : id = __nextId++;
}

class TodoItem extends VComponent {
  Item item;

  TodoItem(Context context, this.item) : super('li', context);

  void updateProperties(Item newItem) {
    if (item.text != newItem.text) {
      item = newItem;
      update();
    }
  }

  build() => vdom.li(0, [vdom.t(item.text)]);

  static VDomComponent virtual(Object key, Item item) {
    return new VDomComponent(key, (component, context) {
      if (component == null) {
        return new TodoItem(context, item);
      }
      component.updateProperties(item);
    });
  }
}

class TodoList extends VComponent {
  List<Item> items;

  TodoList(Context context, this.items) : super('ul', context);

  build() => vdom.ul(0, items.map((i) => TodoItem.virtual(i.id, i)).toList());

  static VDomComponent virtual(Object key, List<Item> items) {
    return new VDomComponent(key, (component, context) {
      if (component == null) {
        return new TodoList(context, items);
      }
      component.update();
    });
  }
}

class TodoApp extends VComponent {
  final List<Item> items;
  String inputText = '';

  TodoApp(Context context, this.items) : super('div', context) {
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
    return vdom.div(0, [
      vdom.h3(0, [vdom.t('TODO')]),
      TodoList.virtual(1, this.items),
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
