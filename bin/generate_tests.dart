import 'dart:io';
import 'package:args/args.dart';
import 'package:test_generator/test_generator.dart';

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
  var generator = new TestGenerator(testFiles, options);
  generator.write(writer);
  writer.close();

  print('${testFiles.length.toString()} test files found');
}

Options parseArgs(List<String> arguments) {
  var parser = new ArgParser()
    ..addOption('directory', abbr: 'd', help: 'directory to search for tests', defaultsTo: 'test/')
    ..addFlag('help', abbr: 'h', negatable: false, help: 'show this help');

  var args = parser.parse(arguments);

  printUsage() {
    print('Usage: dart test_runner_generator.dart\n');
    print(parser.usage);
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
