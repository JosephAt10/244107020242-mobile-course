import '../../../../core/failure.dart';
import '../entities/announcement.dart';
import '../repositories/announcement_repository.dart';

class GetAnnouncements {
  const GetAnnouncements(this._repository);
  final AnnouncementRepository _repository;

  Future<OperationResult<List<Announcement>>> call() async {
    try {
      return await _repository.fetchAnnouncements();
    } catch (_) {
      return const OperationResult.failure(
        LocalFailure('Announcements could not be loaded. Please retry.'),
      );
    }
  }
}
