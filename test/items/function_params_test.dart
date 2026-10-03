import 'package:test/test.dart';

import '../../items/function_params/function_params_complete_1.dart' as c1;
import '../../items/function_params/function_params_complete_2.dart' as c2;
import '../../items/function_params/function_params_trace_1.dart' as t1;
import '../../items/function_params/function_params_trace_2.dart' as t2;
import '../../items/function_params/function_params_trace_3.dart' as t3;
import '../support/capture.dart';

void main() {
  group('function_params_trace_1', () {
    test('key: 3 100 / 100', () => expectOutput(t1.main, '3 100\n100'));
  });

  group('function_params_trace_2', () {
    test('key: 5 / [6, 2]', () => expectOutput(t2.main, '5\n[6, 2]'));
  });

  group('function_params_trace_3', () {
    test('key: 1 5 / 4 1', () => expectOutput(t3.main, '1 5\n4 1'));
  });

  group('function_params_complete_1', () {
    test('key c: between(low, high)', () => expectOutput(c1.optionC, '2 3 4'));
    test('a: swapped args never loop', () => expectOutput(c1.optionA, ''));
    test('d: high + 1 goes too far', () => expectOutput(c1.optionD, '2 3 4 5'));
  });

  group('function_params_complete_2', () {
    test('key b: showRange(start, size)', () {
      expectOutput(c2.optionB, '7\n9');
    });
    test('a: declaration order gives 2 9', () {
      expectOutput(c2.optionA, '2\n9');
    });
    test('d: passing the answer gives 7 16', () {
      expectOutput(c2.optionD, '7\n16');
    });
  });
}
