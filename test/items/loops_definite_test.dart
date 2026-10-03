import 'package:test/test.dart';

import '../../items/loops_definite/loops_definite_complete_1.dart' as c1;
import '../../items/loops_definite/loops_definite_complete_2.dart' as c2;
import '../../items/loops_definite/loops_definite_trace_1.dart' as t1;
import '../../items/loops_definite/loops_definite_trace_2.dart' as t2;
import '../../items/loops_definite/loops_definite_trace_3.dart' as t3;
import '../../items/loops_definite/loops_definite_trace_4.dart' as t4;
import '../../items/loops_definite/loops_definite_trace_5.dart' as t5;
import '../../items/loops_definite/loops_definite_trace_6.dart' as t6;
import '../../items/loops_definite/loops_definite_trace_7.dart' as t7;
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

  group('loops_definite_trace_5', () {
    test('key c: 12 (continue skips 3 and 6)', () {
      expectOutput(t5.main, '12');
    });
  });

  group('loops_definite_trace_6', () {
    test('key d: i is 4 after the loop, count is 8', () {
      expectOutput(t6.main, '4\n8');
    });
  });

  group('loops_definite_trace_7', () {
    test('key c: 10 (1 + 2 + 3 + 4)', () => expectOutput(t7.main, '10'));
  });

  group('loops_definite_complete_1', () {
    test('key a: i <= 5', () => expectOutput(c1.optionA, '1 2 3 4 5'));
    test('b: i < 5 stops early', () => expectOutput(c1.optionB, '1 2 3 4'));
    test(
      'c: i <= 6 goes too far',
      () => expectOutput(c1.optionC, '1 2 3 4 5 6'),
    );
    test('d: i == 5 never enters', () => expectOutput(c1.optionD, ''));
  });

  group('loops_definite_complete_2', () {
    test('key a: j <= i', () => expectOutput(c2.optionA, '*\n**\n***'));
    test('b: j < i one star short', () {
      expectOutput(c2.optionB, '\n*\n**');
    });
    test('c: j <= 3 fixed width', () {
      expectOutput(c2.optionC, '***\n***\n***');
    });
    test('d: j <= i + 1 one star wide', () {
      expectOutput(c2.optionD, '**\n***\n****');
    });
  });
}
