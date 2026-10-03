import 'package:test/test.dart';

import '../../items/loops_definite/loops_definite_complete_1.dart' as c1;
import '../../items/loops_definite/loops_definite_trace_1.dart' as t1;
import '../../items/loops_definite/loops_definite_trace_2.dart' as t2;
import '../../items/loops_definite/loops_definite_trace_3.dart' as t3;
import '../../items/loops_definite/loops_definite_trace_4.dart' as t4;
import '../support/capture.dart';

void main() {
  group('loops_definite_trace_1', () {
    test('key: 30', () => expectOutput(t1.main, '30'));
  });

  group('loops_definite_trace_2', () {
    test('key: 6', () => expectOutput(t2.main, '6'));
  });

  group('loops_definite_trace_3', () {
    test('key: 3 2 1 0', () => expectOutput(t3.main, '3 2 1 0'));
  });

  group('loops_definite_trace_4', () {
    test('key: 12', () => expectOutput(t4.main, '12'));
  });

  group('loops_definite_complete_1', () {
    test('key b: i <= 5', () => expectOutput(c1.optionB, '1 2 3 4 5'));
    test('a: i < 5 stops early', () => expectOutput(c1.optionA, '1 2 3 4'));
    test(
      'c: i <= 6 goes too far',
      () => expectOutput(c1.optionC, '1 2 3 4 5 6'),
    );
    test('d: i == 5 never enters', () => expectOutput(c1.optionD, ''));
  });
}
