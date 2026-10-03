// Copyright 2026 Google LLC
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';

import '../../items/selection/selection_complete_1.dart' as c1;
import '../../items/selection/selection_trace_1.dart' as t1;
import '../../items/selection/selection_trace_2.dart' as t2;
import '../support/capture.dart';

void main() {
  group('selection_trace_1', () {
    test(
      'key: chain prints one, ifs print both',
      () => expectOutput(t1.main, 'B\npass\nok'),
    );
  });

  group('selection_trace_2', () {
    test('key: end', () => expectOutput(t2.main, 'end'));
  });

  group('selection_complete_1', () {
    test('key a: else if chain', () => expectOutput(c1.optionA, 'SMMBB'));
    test(
      'a: independent if adds two letters',
      () => expectOutput(c1.optionB, 'SMMBMBM'),
    );
    test('c: inclusive bound', () => expectOutput(c1.optionC, 'MMMBB'));
  });
}
