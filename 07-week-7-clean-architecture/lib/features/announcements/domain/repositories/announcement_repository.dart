import '../../../../core/failure.dart';
import '../entities/announcement.dart';

abstract interface class AnnouncementRepository {
  Future<OperationResult<List<Announcement>>> fetchAnnouncements();
  Future<OperationResult<Announcement?>> findById(String id);
}