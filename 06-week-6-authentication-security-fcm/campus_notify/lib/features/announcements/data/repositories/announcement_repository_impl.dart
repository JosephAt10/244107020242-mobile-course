import '../../../../core/failure.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../models/announcement_model.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  static final List<AnnouncementModel> _seed = [
    AnnouncementModel.fromMap({
      'id': '3', 'title': 'Schedule changed',
      'body': 'Mobile class moved to Room A2 at 1:00 PM.',
      'category': 'schedule', 'updatedAt': '2026-10-08T13:00:00.000Z',
    }),
    AnnouncementModel.fromMap({
      'id': '2', 'title': 'Library hours',
      'body': 'The library is open until 8:00 PM this week.',
      'category': 'library', 'updatedAt': '2026-10-08T12:00:00.000Z',
    }),
    AnnouncementModel.fromMap({
      'id': '1', 'title': 'Welcome to campus',
      'body': 'Your weekly campus digest is ready.',
      'category': 'general', 'updatedAt': '2026-10-08T11:00:00.000Z',
    }),
  ];

  @override
  Future<OperationResult<List<Announcement>>> fetchAnnouncements() async {
    try {
      return OperationResult.success(
        _seed.map((model) => model.toEntity()).toList(growable: false),
      );
    } catch (_) {
      return const OperationResult.failure(
        LocalFailure('Announcements could not be loaded. Please retry.'),
      );
    }
  }

  @override
  Future<OperationResult<Announcement?>> findById(String id) async {
    try {
      AnnouncementModel? model;
      for (final item in _seed) {
        if (item.id == id) {
          model = item;
          break;
        }
      }
      return OperationResult.success(model?.toEntity());
    } catch (_) {
      return const OperationResult.failure(
        LocalFailure('Announcement could not be loaded. Please retry.'),
      );
    }
  }
}