import 'dart:async';

import 'package:test/test.dart';

/// Runs [body] and returns everything it `print`ed, one line per `print`,
/// joined with `\n` and without a trailing newline.
String captureOutput(void Function() body) {
  final lines = <String>[];
  runZoned(
    body,
    zoneSpecification: ZoneSpecification(
      print: (_, _, _, line) => lines.add(line),
    ),
  );
  return lines.join('\n');
}

/// Asserts that running [body] prints exactly [expected].
void expectOutput(void Function() body, String expected, {String? reason}) {
  expect(captureOutput(body), expected, reason: reason);
}
