import 'package:flutter_test/flutter_test.dart';
import 'package:vitrina_app/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('email', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('sin-arroba'), isNotNull);
      expect(Validators.email('a@b.com'), isNull);
    });

    test('password exige mínimo 6 caracteres', () {
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password('123456'), isNull);
    });

    test('teléfono es opcional pero si existe debe ser válido', () {
      expect(Validators.phone(''), isNull);
      expect(Validators.phone('12'), isNotNull);
      expect(Validators.phone('+593 99 999 9999'), isNull);
    });
  });
}
