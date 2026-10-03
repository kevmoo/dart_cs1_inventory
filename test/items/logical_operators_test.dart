import 'package:test/test.dart';

import '../../items/logical_operators/logical_operators_complete_1.dart' as c1;
import '../../items/logical_operators/logical_operators_trace_1.dart' as t1;
import '../../items/logical_operators/logical_operators_trace_2.dart' as t2;
import '../support/capture.dart';

void main() {
  group('logical_operators_trace_1', () {
    test(
      'key: false / true / true',
      () => expectOutput(t1.main, 'false\ntrue\ntrue'),
    );
  });

  group('logical_operators_trace_2', () {
    test(
      'key: short-circuit avoids division',
      () => expectOutput(t2.main, 'no data\ndone'),
    );
  });

  group('logical_operators_complete_1', () {
    test('key a: && inclusive', () => expectOutput(c1.optionA, '10'));
    test('b: || counts everything', () => expectOutput(c1.optionB, '12'));
    test('c: strict bounds drop ends', () => expectOutput(c1.optionC, '8'));
  });
}
