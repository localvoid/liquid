// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Transformer that replaces the default mirror-based implementation of Liquid,
/// so that during deploy Liquid doesn't include any dependencies on
/// dart:mirrors.
library liquid.transformer;

import 'dart:async';
import 'package:barback/barback.dart';
import 'package:code_transformers/resolver.dart';

import 'package:liquid/src/transformer/options.dart';
import 'package:liquid/src/transformer/factory_transformer.dart';
import 'package:liquid/src/transformer/factory_call_transformer.dart';

class LiquidTransformerGroup extends TransformerGroup {
  LiquidTransformerGroup(Iterable<Iterable> phases) : super(phases);

  factory LiquidTransformerGroup.asPlugin(BarbackSettings settings) {
    final options = new TransformerOptions(settings.configuration);

    final resolvers = new Resolvers(dartSdkDirectory);

    return new LiquidTransformerGroup(
        [
         [new FactoryTransformer(options, resolvers)],
         [new FactoryCallTransformer(options, resolvers)]
        ]);
  }
}

class _SerialTransformer extends Transformer {
  final Iterable<Transformer> _transformers;

  _SerialTransformer(this._transformers);

  Future<bool> isPrimary(AssetId id) =>
      Future.wait(_transformers.map((t) => t.isPrimary(id)))
          .then((l) => l.any((result) => result));

  Future apply(Transform transform) {
    return Future.forEach(_transformers, (t) {
      return new Future.value(t.isPrimary(transform.primaryInput.id))
        .then((isPrimary) {
          if (isPrimary) return t.apply(transform);
        });
    });
  }
}
