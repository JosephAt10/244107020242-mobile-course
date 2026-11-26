import 'package:flutter_test/flutter_test.dart';
import 'package:week13_cicd_automation/features/notes/domain/validators/note_title_validator.dart';

void main() {
  group('validateNoteTitle', () {
    test('accepts a title containing non-whitespace text', () {
      expect(validateNoteTitle('Read the material'), isNull);
    });

    test('rejects an empty title', () {
      expect(validateNoteTitle(''), 'Enter a title');
    });

    test('rejects a whitespace-only title', () {
      expect(validateNoteTitle('   \t '), 'Enter a title');
    });

    test('rejects a missing value', () {
      expect(validateNoteTitle(null), 'Enter a title');
    });
  });
}
