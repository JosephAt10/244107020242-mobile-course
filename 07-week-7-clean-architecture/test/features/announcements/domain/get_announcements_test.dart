import 'package:campus_notify/core/failure.dart';
import 'package:campus_notify/features/announcements/domain/entities/announcement.dart';
import 'package:campus_notify/features/announcements/domain/repositories/announcement_repository.dart';
import 'package:campus_notify/features/announcements/domain/usecases/get_announcements.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAnnouncementRepository implements AnnouncementRepository {
  FakeAnnouncementRepository(this.result);
  final OperationResult<List<Announcement>> result;

  @override
  Future<OperationResult<List<Announcement>>> fetchAnnouncements() async => result;

  @override
  Future<OperationResult<Announcement?>> findById(String id) async =>
      const OperationResult.success(null);
}

void main() {
  test('GetAnnouncements returns items from a fake repository', () async {
    final items = [Announcement(
      id: '3', title: 'Schedule changed', body: 'Room A2',
      category: 'schedule', updatedAt: DateTime.utc(2026, 10, 8),
    )];
    final result = await GetAnnouncements(FakeAnnouncementRepository(
      OperationResult.success(items),
    ))();
    expect(result.failure, isNull);
    expect(result.value, hasLength(1));
    expect(result.value!.single.id, '3');
  });

  test('GetAnnouncements forwards failure without throwing', () async {
    const failure = LocalFailure('simulated repository failure');
    final result = await GetAnnouncements(FakeAnnouncementRepository(
      const OperationResult.failure(failure),
    ))();
    expect(result.value, isNull);
    expect(result.failure, same(failure));
    expect(result.failure!.message, contains('simulated'));
  });
}