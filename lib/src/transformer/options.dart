// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library liquid.transformer.options;

/// Transformer Options
class TransformerOptions {
  final bool releaseMode;
  final bool applyCodeTransformations;
  final bool enablePerformanceHints;

  TransformerOptions(
      this.releaseMode,
      this.applyCodeTransformations,
      this.enablePerformanceHints);

  factory TransformerOptions.from(Map configuration, bool isReleaseMode) {
    config(key, defaultValue) {
      var value = configuration[key];
      return value != null ? value : defaultValue;
    }

    return new TransformerOptions(
        config('release_mode', isReleaseMode),
        config('apply_code_transformations', isReleaseMode),
        config('perf_hints', false)
        );
  }
}
