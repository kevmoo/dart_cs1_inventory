import 'package:test/test.dart';

import '../../items/fundamentals/fundamentals_complete_1.dart' as c1;
import '../../items/fundamentals/fundamentals_complete_2.dart' as c2;
import '../../items/fundamentals/fundamentals_complete_3.dart' as c3;
import '../../items/fundamentals/fundamentals_trace_1.dart' as t1;
import '../../items/fundamentals/fundamentals_trace_2.dart' as t2;
import '../../items/fundamentals/fundamentals_trace_3.dart' as t3;
import '../../items/fundamentals/fundamentals_trace_4.dart' as t4;
import '../../items/fundamentals/fundamentals_trace_5.dart' as t5;
import '../../items/fundamentals/fundamentals_trace_6.dart' as t6;
import '../../items/fundamentals/fundamentals_trace_7.dart' as t7;
import '../../items/fundamentals/fundamentals_trace_8.dart' as t8;
import '../../items/fundamentals/fundamentals_trace_9.dart' as t9;
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

  group('fundamentals_trace_4', () {
    test('key: 34 / 7 / 7.0', () => expectOutput(t4.main, '34\n7\n7.0'));
  });

  group('fundamentals_trace_5', () {
    test('key: true / 1.0 / 6.0', () {
      expectOutput(t5.main, 'true\n1.0\n6.0');
    });
  });

  group('fundamentals_trace_6', () {
    test('key: interpolation vs plain text', () {
      expectOutput(t6.main, '4 + 5 = 9\n4 + 5 = 4 + 5');
    });
  });

  group('fundamentals_trace_7', () {
    test('key: 14 / 20 / 3 / 2', () {
      expectOutput(t7.main, '14\n20\n3\n2');
    });
  });

  group('fundamentals_trace_8', () {
    test('key: 11 / 21', () => expectOutput(t8.main, '11\n21'));
  });

  group('fundamentals_trace_9', () {
    test('key: 2 2 1 / 2 1 1', () {
      expectOutput(t9.main, '2 2 1\n2 1 1');
    });
  });

  group('fundamentals_complete_1', () {
    test('key b: x = x * 3;', () => expectOutput(c1.optionB, '15'));
    test('a: x * 3; does not store', () => expectOutput(c1.optionA, '5'));
    test('c: x += 15; adds', () => expectOutput(c1.optionC, '20'));
  });

  group('fundamentals_complete_2', () {
    test(r'key a: ${price * count}', () {
      expectOutput(c2.optionA, 'Total: 12');
    });
    test(r'b: $price * count substitutes one name', () {
      expectOutput(c2.optionB, 'Total: 4 * count');
    });
    test('c: bare names are text', () {
      expectOutput(c2.optionC, 'Total: price * count');
    });
  });

  group('fundamentals_complete_3', () {
    test('key c: (a + b) ~/ 2', () => expectOutput(c3.optionC, '8'));
    test('a: a + b ~/ 2 divides first', () => expectOutput(c3.optionA, '12'));
    test('b: (a + b) / 2 is a double', () => expectOutput(c3.optionB, '8.5'));
    test('d: (a + b) % 2 is the remainder', () {
      expectOutput(c3.optionD, '1');
    });
  });
}
