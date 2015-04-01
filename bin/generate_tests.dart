import 'dart:io';
import 'package:args/args.dart';

void main(List<String> arguments) {
  var options = parseArgs(arguments);

  Directory testDirectory = new Directory(options.testDirectory);
  List<File> testFiles = [];
  List<FileSystemEntity> allFiles = testDirectory.listSync(recursive: true, followLinks: false);
  allFiles.where((e) => !e.path.endsWith('generated_runner_test.dart')).forEach((FileSystemEntity entity) {
    if (entity is File) {
      if (entity.path.contains(new RegExp(r'_test\.dart$'))) {
        testFiles.add(entity);
      } else if (!entity.path.endsWith('generated_runner_test.dart') &&
      entity.path.contains(new RegExp(r'\.dart$'))) {
        print('[NOTICE] Found non-test dart file: ' + entity.path);
      }
    }
  });

  File generatedRunner = new File(options.testDirectory + '/generated_runner_test.dart');
  IOSink writer = generatedRunner.openWrite(mode: FileMode.WRITE);
  writer.writeln('/************ GENERATED FILE ************');
  writer.writeln();
  writer.writeln('This file was generated with test_runner_generator:');
  writer.writeln();
  writer.writeln('************* GENERATED FILE ************/');
  writer.writeln();

  testFiles.forEach((File file) {
    Match fileNameMatch = new RegExp(r'([^/]+).dart$').firstMatch(file.path);
    String fileName = fileNameMatch.group(1);
    writer.writeln("import '" + file.path.replaceFirst(options.testDirectory, './') + "' as " + fileName + ';');
  });

  writer.writeln("import 'package:unittest/unittest.dart';");

  writer.writeln('');
  writer.writeln('void main() {');

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

  Options(this.testDirectory);
}

Options parseArgs(List<String> arguments) {
  var parser = new ArgParser()
    ..addOption('directory', abbr: 'd', help: 'directory to search for tests', defaultsTo: 'test')
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

  return new Options(args['directory']);
}