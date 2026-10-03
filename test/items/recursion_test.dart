// Copyright 2026 Google LLC
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';

import '../../items/recursion/recursion_complete_1.dart' as c1;
import '../../items/recursion/recursion_trace_1.dart' as t1;
import '../../items/recursion/recursion_trace_2.dart' as t2;
import '../../items/recursion/recursion_trace_3.dart' as t3;
import '../support/capture.dart';

void main() {
  group('recursion_trace_1', () {
    test('key: 24', () => expectOutput(t1.main, '24'));
  });

  group('recursion_trace_2', () {
    test(
      'key: down 2, down 1, up 1, up 2',
      () => expectOutput(t2.main, 'down 2\ndown 1\nup 1\nup 2'),
    );
  });

  group('recursion_trace_3', () {
    test('key: 11', () => expectOutput(t3.main, '11'));
  });

  group('recursion_complete_1', () {
    test('key b: n == 0', () => expectOutput(c1.optionB, '6'));
    test('a: n == 1 stops early', () => expectOutput(c1.optionA, '5'));
    test('c: n > 0 returns at once', () => expectOutput(c1.optionC, '0'));
  });
}
