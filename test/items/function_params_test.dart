import 'package:test/test.dart';

import '../../items/function_params/function_params_complete_1.dart' as c1;
import '../../items/function_params/function_params_trace_1.dart' as t1;
import '../../items/function_params/function_params_trace_2.dart' as t2;
import '../support/capture.dart';

void main() {
  group('function_params_trace_1', () {
    test('key: 3 100 / 100', () => expectOutput(t1.main, '3 100\n100'));
  });

  group('function_params_trace_2', () {
    test('key: 5 / [6, 2]', () => expectOutput(t2.main, '5\n[6, 2]'));
  });

  group('function_params_complete_1', () {
    test('key b: between(low, high)', () => expectOutput(c1.optionB, '2 3 4'));
    test('a: swapped args never loop', () => expectOutput(c1.optionA, ''));
    test('d: high + 1 goes too far', () => expectOutput(c1.optionD, '2 3 4 5'));
  });
}
