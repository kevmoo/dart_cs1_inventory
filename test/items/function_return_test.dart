import 'package:test/test.dart';

import '../../items/function_return/function_return_complete_1.dart' as c1;
import '../../items/function_return/function_return_trace_1.dart' as t1;
import '../../items/function_return/function_return_trace_2.dart' as t2;
import '../../items/function_return/function_return_trace_3.dart' as t3;
import '../support/capture.dart';

void main() {
  group('function_return_trace_1', () {
    test('key: 12', () => expectOutput(t1.main, '12'));
  });

  group('function_return_trace_2', () {
    test('key: 7 / 16', () => expectOutput(t2.main, '7\n16'));
  });

  group('function_return_trace_3', () {
    test('key: 9 / 16', () => expectOutput(t3.main, '9\n16'));
  });

  group('function_return_complete_1', () {
    test('key d: return n * n', () => expectOutput(c1.optionD, '9'));
    test('c: prints then returns n', () => expectOutput(c1.optionC, '9\n3'));
    test('b: computes but returns n', () => expectOutput(c1.optionB, '3'));
  });
}
