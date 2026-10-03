import 'package:test/test.dart';

import '../../items/oop/oop_complete_1.dart' as c1;
import '../../items/oop/oop_trace_1.dart' as t1;
import '../../items/oop/oop_trace_2.dart' as t2;
import '../support/capture.dart';

void main() {
  group('oop_trace_1', () {
    test('key: 2 11', () => expectOutput(t1.main, '2 11'));
  });

  group('oop_trace_2', () {
    test('key: 6 6 5', () => expectOutput(t2.main, '6 6 5'));
  });

  group('oop_complete_1', () {
    test('key a: this.count += 1', () => expectOutput(c1.optionA, '5'));
    test('b: local shadows field', () => expectOutput(c1.optionB, '3'));
    test('c: prints instead', () => expectOutput(c1.optionC, '4\n4\n3'));
  });
}
