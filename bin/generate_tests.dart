import 'dart:io';
import 'package:args/args.dart';

void main(List<String> arguments) {
  var options = parseArgs(arguments);

  Directory testDirectory = new Directory(options.testDirectory);
  List<File> testFiles = [];
  List<FileSystemEntity> allFiles = testDirectory.listSync(recursive: true, followLinks: false);
  allFiles.forEach((FileSystemEntity entity) {
    if (entity is File) {
      if (entity.path.contains(new RegExp(r'_test\.dart$'))) {
        testFiles.add(entity);
      } else if (!entity.path.endsWith('generated_runner.dart') &&
      entity.path.contains(new RegExp(r'\.dart$'))) {
        print('[NOTICE] Found non-test dart file: ' + entity.path);
      }
    }
  });

  File generatedRunner = new File(options.testDirectory + '/generated_runner.dart');
  IOSink writer = generatedRunner.openWrite(mode: FileMode.WRITE);
  writer.writeln('/************ GENERATED FILE ************');
  writer.writeln();
  writer.writeln('This file was generated with the command:');
  writer.writeln('dart bin/test_runner_generator.dart -d ' + options.testDirectory + ' ' + (options.includeReact ? '--react' : '--no-react'));
  writer.writeln();
  writer.writeln('************* GENERATED FILE ************/');
  writer.writeln();

  testFiles.forEach((File file) {
    Match fileNameMatch = new RegExp(r'([^/]+).dart$').firstMatch(file.path);
    String fileName = fileNameMatch.group(1);
    writer.writeln("import '" + file.path.replaceFirst(options.testDirectory, '.') + "' as " + fileName + ';');
  });

  writer.writeln("import 'package:unittest/unittest.dart';");
  writer.writeln("import 'package:w-table/xunitconfig.dart';");
  if (options.includeReact) {
    writer.writeln("import 'package:react/react_client.dart' as rc;");
  }
  writer.writeln('');
  writer.writeln('void main() {');
  writer.writeln('  unittestConfiguration = new XUnitConfiguration();');
  if (options.includeReact) {
    writer.writeln('  rc.setClientConfiguration();');
  }

  testFiles.forEach((File file) {
    Match fileNameMatch = new RegExp(r'([^/]+).dart$').firstMatch(file.path);
    String fileName = fileNameMatch.group(1);
    writer.writeln('  ' + fileName + '.main();');
  });

  writer.writeln('}');
  writer.close();

  print(testFiles.length.toString() + ' test files found');
}

class Options {
  final String testDirectory;
  final bool includeReact;

  Options(this.testDirectory, this.includeReact);
}

Options parseArgs(List<String> arguments) {
  var parser = new ArgParser()
    ..addOption('directory', abbr: 'd', help: 'directory to search for tests')
    ..addFlag('react', defaultsTo: true, help: 'import and initialize React')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'show this help');

  var args = parser.parse(arguments);

  printUsage() {
    print('Usage: dart test_runner_generator.dart\n');
    print(parser.getUsage());
  }

  fail(message) {
    print('Error: $message\n');
    printUsage();
    exit(1);
  }

  if (args['directory'] == null) {
    fail('Directory is required');
  }

  if (args['help']) {
    printUsage();
    exit(0);
  }

  return new Options(args['directory'], args['react']);
}