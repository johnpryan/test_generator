import "package:unittest/unittest.dart";

main() {
  group('bar', () {
    test('can bar', () {
      var x = 1;
      expect(x, closeTo(0, 1));
    });
  });
}