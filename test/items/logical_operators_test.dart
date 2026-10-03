import 'package:test/test.dart';

import '../../items/logical_operators/logical_operators_complete_1.dart' as c1;
import '../../items/logical_operators/logical_operators_trace_1.dart' as t1;
import '../../items/logical_operators/logical_operators_trace_2.dart' as t2;
import '../../items/logical_operators/logical_operators_trace_3.dart' as t3;
import '../../items/logical_operators/logical_operators_trace_4.dart' as t4;
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

  group('logical_operators_trace_3', () {
    test(
      'key c: stored bool is not recomputed',
      () => expectOutput(t3.main, 'false\nfalse\ntrue'),
    );
  });

  group('logical_operators_trace_4', () {
    test(
      'key a: == is case-sensitive and binds after +',
      () => expectOutput(t4.main, 'true\nfalse\nfalse\ntrue'),
    );
  });

  group('logical_operators_complete_1', () {
    test('key a: && inclusive', () => expectOutput(c1.optionA, '5 in\n10 in'));
    test(
      'b: || accepts everything',
      () => expectOutput(c1.optionB, '0 in\n5 in\n10 in'),
    );
    test('c: strict bounds drop 10', () => expectOutput(c1.optionC, '5 in'));
  });
}
