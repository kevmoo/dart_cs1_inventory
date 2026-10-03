// Copyright 2026 Google LLC
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';

import '../../items/fundamentals/fundamentals_complete_1.dart' as c1;
import '../../items/fundamentals/fundamentals_trace_1.dart' as t1;
import '../../items/fundamentals/fundamentals_trace_2.dart' as t2;
import '../../items/fundamentals/fundamentals_trace_3.dart' as t3;
import '../support/capture.dart';

void main() {
  group('fundamentals_trace_1', () {
    test('key: 3.5 / 3 / 1', () => expectOutput(t1.main, '3.5\n3\n1'));
  });

  group('fundamentals_trace_2', () {
    test('key: 5 x 2 = 6', () => expectOutput(t2.main, '5 x 2 = 6'));
  });

  group('fundamentals_trace_3', () {
    test('key: 2 2', () => expectOutput(t3.main, '2 2'));
  });

  group('fundamentals_complete_1', () {
    test('key b: x = x * 3;', () => expectOutput(c1.optionB, '15'));
    test('a: x * 3; does not store', () => expectOutput(c1.optionA, '5'));
    test('c: x += 15; adds', () => expectOutput(c1.optionC, '20'));
  });
}
