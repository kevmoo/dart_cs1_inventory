import 'package:test/test.dart';

import '../../items/selection/selection_complete_1.dart' as c1;
import '../../items/selection/selection_trace_1.dart' as t1;
import '../../items/selection/selection_trace_2.dart' as t2;
import '../../items/selection/selection_trace_3.dart' as t3;
import '../support/capture.dart';

void main() {
  group('selection_trace_1', () {
    test(
      'key: chain prints one, ifs print both',
      () => expectOutput(t1.main, 'B\npass\nok'),
    );
  });

  group('selection_trace_2', () {
    test('key: end', () => expectOutput(t2.main, 'end'));
  });

  group('selection_trace_3', () {
    test(
      'key d: outer true, inner false, end always',
      () => expectOutput(t3.main, 'start\nhot\nend'),
    );
  });

  group('selection_complete_1', () {
    test('key a: else if chain', () => expectOutput(c1.optionA, 'S\nB'));
    test(
      'b: independent if prints two letters for 4',
      () => expectOutput(c1.optionB, 'S\nB\nM'),
    );
    test('c: inclusive bound', () => expectOutput(c1.optionC, 'M\nB'));
  });
}
