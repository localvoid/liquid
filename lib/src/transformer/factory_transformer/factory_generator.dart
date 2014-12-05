// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of liquid.transformer.factory_transformer;

abstract class FactoryGenerator {
  void compile(TextEditTransaction transaction, TopLevelVariableDeclaration tld,
               SimpleIdentifier name, Expression arg);
}

class FactoryGenerators {
  final HashMap<Element, FactoryGenerator> _generators = new HashMap();

  FactoryGenerators(LiquidElements elements, ComponentMetaDataExtractor extractor) {
    _generators[elements.staticTreeFactory] = new StaticTreeFactoryGenerator();
    _generators[elements.dynamicTreeFactory] = new DynamicTreeFactoryGenerator();
    _generators[elements.componentFactory] = new ComponentFactoryGenerator(elements, extractor);
  }

  FactoryGenerator operator[](Element element) => _generators[element];
}
