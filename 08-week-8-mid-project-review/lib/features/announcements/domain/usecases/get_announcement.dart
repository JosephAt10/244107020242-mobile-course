import '../../../../core/failure.dart';
import '../entities/announcement.dart';
import '../repositories/announcement_repository.dart';

class GetAnnouncement {
  const GetAnnouncement(this._repository);
  final AnnouncementRepository _repository;

  Future<OperationResult<Announcement?>> call(String id) async {
    try {
      return await _repository.findById(id);
    } catch (_) {
      return const OperationResult.failure(
        LocalFailure('Announcement could not be loaded. Please retry.'),
      );
    }
  }
}
