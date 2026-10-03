import 'dart:io';
import 'dart:isolate';

import 'package:cli_util/cli_util.dart';
import 'package:path/path.dart' as p;

/// Root directory of this package (the directory containing `pubspec.yaml`,
/// `data/` and `items/`), independent of the current working directory.
///
/// Works under `dart run`, `dart run <pkg>:tutor` from any cwd inside a
/// dependent package, and `dart pub global activate --source git`.
Future<String> packageRoot() async {
  final lib = await Isolate.resolvePackageUri(
    Uri.parse('package:dart_cs1_inventory/'),
  );
  if (lib == null) {
    throw StateError(
      'Cannot resolve package:dart_cs1_inventory; '
      'run with `dart run`, not as a compiled executable.',
    );
  }
  return p.normalize(p.join(lib.toFilePath(), '..'));
}

/// Environment variable that overrides the default state directory.
const stateDirEnv = 'DART_CS1_STATE';

/// Directory holding per-student state.
///
/// Precedence: [override] (a `--state-dir` flag), then [stateDirEnv], then the
/// platform state directory from `package:cli_util`
/// (`~/.local/state/dart_cs1_inventory` on Linux, `~/Library/Application
/// Support/dart_cs1_inventory` on macOS, `%LOCALAPPDATA%` on Windows). Never a
/// dot-directory in `$HOME`.
String resolveStateDir({String? override, Map<String, String>? environment}) {
  final env = environment ?? Platform.environment;
  final fromFlag = override?.trim();
  if (fromFlag != null && fromFlag.isNotEmpty) return p.absolute(fromFlag);
  final fromEnv = env[stateDirEnv]?.trim();
  if (fromEnv != null && fromEnv.isNotEmpty) return p.absolute(fromEnv);
  return BaseDirectories('dart_cs1_inventory', environment: env).stateHome;
}
