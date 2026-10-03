import 'package:test/test.dart';

import '../../items/arrays/arrays_complete_1.dart' as c1;
import '../../items/arrays/arrays_trace_1.dart' as t1;
import '../../items/arrays/arrays_trace_2.dart' as t2;
import '../../items/arrays/arrays_trace_3.dart' as t3;
import '../support/capture.dart';

void main() {
  group('arrays_trace_1', () {
    test('key: 20 / 4 / 40', () => expectOutput(t1.main, '20\n4\n40'));
  });

  group('arrays_trace_2', () {
    test('key: [6, 2, 8]', () => expectOutput(t2.main, '[6, 2, 8]'));
  });

  group('arrays_trace_3', () {
    test('key: both [9, 2, 5]', () {
      expectOutput(t3.main, '[9, 2, 5]\n[9, 2, 5]');
    });
  });

  group('arrays_complete_1', () {
    test('key b: a.length - 1', () => expectOutput(c1.optionB, '42'));
    test('a: a.length throws RangeError', () {
      expect(() => captureOutput(c1.optionA), throwsRangeError);
    });
    test('c: a.length - 2 is second-to-last', () {
      expectOutput(c1.optionC, '23');
    });
  });
}
