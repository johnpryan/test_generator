import 'dart:io';

var _header = '''
/************ GENERATED FILE ************

    This file was generated with test_runner_generator

 ************* GENERATED FILE ************/
''';

class TestGenerator {
  List<File> testFiles;
  Options options;

  TestGenerator(this.testFiles, this.options);

  write(StringSink sink) {
    _writeHeader(sink);
    _writeImports(sink);
    _writeMain(sink);
  }

  _writeHeader(StringSink sink) {
    sink.write(_header);
  }

  _writeImports(StringSink sink) {
    testFiles.forEach((File file) {
      Match fileNameMatch = new RegExp(r'([^/]+).dart$').firstMatch(file.path);
      String fileName = fileNameMatch.group(1);
      var fullFilePath = file.path.replaceFirst(options.testDirectory, './');
      sink.writeln("import '$fullFilePath' as $fileName;");
    });
    sink.writeln("import 'package:unittest/unittest.dart';");
  }

  _writeMain(StringSink sink) {
    sink.writeln('void main() {');
    testFiles.forEach((File file) {
      Match fileNameMatch = new RegExp(r'([^/]+).dart$').firstMatch(file.path);
      String fileName = fileNameMatch.group(1);
      sink.writeln('  $fileName.main();');
    });
    sink.writeln('}');
  }
}

class Options {
  final String testDirectory;

  Options(this.testDirectory);
}