import 'package:test/test.dart';

import '../../items/loops_indefinite/loops_indefinite_complete_1.dart' as c1;
import '../../items/loops_indefinite/loops_indefinite_trace_1.dart' as t1;
import '../../items/loops_indefinite/loops_indefinite_trace_2.dart' as t2;
import '../../items/loops_indefinite/loops_indefinite_trace_3.dart' as t3;
import '../support/capture.dart';

void main() {
  group('loops_indefinite_trace_1', () {
    test('key: 4 1', () => expectOutput(t1.main, '4 1'));
  });

  group('loops_indefinite_trace_2', () {
    test('key: tick 10 / done 11', () {
      expectOutput(t2.main, 'tick 10\ndone 11');
    });
  });

  group('loops_indefinite_trace_3', () {
    test('key: 2 11', () => expectOutput(t3.main, '2 11'));
  });

  group('loops_indefinite_complete_1', () {
    test('key a: n = n * 2', () => expectOutput(c1.optionA, '1 2 4 8 16'));
    test('b: n++ counts 1..19', () {
      final oneToNineteen = List.generate(19, (i) => i + 1).join(' ');
      expectOutput(c1.optionB, oneToNineteen);
    });
    test('c: n = n + 2 gives odds', () {
      expectOutput(c1.optionC, '1 3 5 7 9 11 13 15 17 19');
    });
    test('d: n = n * 2 + 1', () => expectOutput(c1.optionD, '1 3 7 15'));
  });
}
