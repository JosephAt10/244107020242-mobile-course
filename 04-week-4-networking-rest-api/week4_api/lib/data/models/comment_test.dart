import 'package:flutter_test/flutter_test.dart';

import '../../data/models/comment.dart';

void main() {
  group('Comment.fromJson', () {
    test('uses defaults when fields are missing', () {
      final comment = Comment.fromJson({});

      expect(comment.postId, 0);
      expect(comment.id, 0);
      expect(comment.name, '');
      expect(comment.email, '');
      expect(comment.body, '');
    });

    test('uses defaults when fields have unexpected types', () {
      final comment = Comment.fromJson({
        'postId': 'not a number',
        'id': null,
        'name': 123,
        'email': false,
        'body': <String>[],
      });

      expect(comment.postId, 0);
      expect(comment.id, 0);
      expect(comment.name, '');
      expect(comment.email, '');
      expect(comment.body, '');
    });
  });
}