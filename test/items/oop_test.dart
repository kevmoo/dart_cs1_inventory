import 'package:test/test.dart';

import '../../items/oop/oop_complete_1.dart' as c1;
import '../../items/oop/oop_trace_1.dart' as t1;
import '../../items/oop/oop_trace_2.dart' as t2;
import '../../items/oop/oop_trace_3.dart' as t3;
import '../../items/oop/oop_trace_4.dart' as t4;
import '../support/capture.dart';

void main() {
  group('oop_trace_1', () {
    test('key: 2 11', () => expectOutput(t1.main, '2 11'));
  });

  group('oop_trace_2', () {
    test('key: 6 6 5', () => expectOutput(t2.main, '6 6 5'));
  });

  group('oop_trace_3', () {
    test('key: 5 2 / 1 7', () => expectOutput(t3.main, '5 2\n1 7'));
  });

  group('oop_trace_4', () {
    test('key: 10 / 10 / 8 16', () => expectOutput(t4.main, '10\n10\n8 16'));
  });

  group('oop_complete_1', () {
    test('key a: this.count += 1', () => expectOutput(c1.optionA, '5'));
    test('b: local shadows field', () => expectOutput(c1.optionB, '3'));
    test('c: prints instead', () => expectOutput(c1.optionC, '4\n4\n3'));
  });
}
