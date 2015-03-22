import "package:unittest/unittest.dart";

main() {
  group('foo', () {
    test('can foo', () {
      var x = 1;
      expect(x, greaterThan(0));
      expect(x, lessThan(2));
    });
  });
}