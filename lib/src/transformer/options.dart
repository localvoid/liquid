// Copyright (c) 2014, the Liquid project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library liquid.transformer.options;

/// Transformer Options
class TransformerOptions {
  final bool enablePerformanceHints;
  final bool releaseMode;
  final bool injectLogs;

  bool get applyCodeTransformations => releaseMode;

  TransformerOptions(
      this.enablePerformanceHints,
      this.releaseMode,
      this.injectLogs);

  factory TransformerOptions.from(Map configuration, bool isReleaseMode) {
    config(key, defaultValue) {
      var value = configuration[key];
      return value != null ? value : defaultValue;
    }

    return new TransformerOptions(
        config('perf_hints', false),
        config('release_mode', isReleaseMode),
        config('inject_logs', !isReleaseMode)
        );
  }
}
