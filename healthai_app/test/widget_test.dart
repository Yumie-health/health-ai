import 'package:flutter_test/flutter_test.dart';
import 'package:healthai_app/utils/validation.dart';

void main() {
  test('ValidationUtils.isValidEmail rejects empty input', () {
    expect(ValidationUtils.isValidEmail(''), isFalse);
  });

  test('ValidationUtils.isValidEmail accepts well-formed address', () {
    expect(ValidationUtils.isValidEmail('user@example.com'), isTrue);
  });

  test('ValidationUtils.isValidAge enforces 16-120 range', () {
    expect(ValidationUtils.isValidAge(15), isFalse);
    expect(ValidationUtils.isValidAge(25), isTrue);
    expect(ValidationUtils.isValidAge(121), isFalse);
  });
}
