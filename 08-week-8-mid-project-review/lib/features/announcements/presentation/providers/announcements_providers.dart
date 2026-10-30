import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/failure.dart';
import '../../data/repositories/announcement_repository_impl.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../../domain/usecases/get_announcement.dart';
import '../../domain/usecases/get_announcements.dart';

final announcementRepositoryProvider = Provider<AnnouncementRepository>(
  (ref) => AnnouncementRepositoryImpl(),
);
final getAnnouncementsProvider = Provider<GetAnnouncements>(
  (ref) => GetAnnouncements(ref.watch(announcementRepositoryProvider)),
);
final getAnnouncementProvider = Provider<GetAnnouncement>(
  (ref) => GetAnnouncement(ref.watch(announcementRepositoryProvider)),
);

final announcementsProvider = FutureProvider<List<Announcement>>((ref) async {
  final result = await ref.watch(getAnnouncementsProvider)();
  if (result.failure case final failure?) throw failure;
  return result.value!;
});

final announcementByIdProvider = FutureProvider.family<Announcement?, String>((
  ref,
  id,
) async {
  final result = await ref.watch(getAnnouncementProvider)(id);
  if (result.failure case final failure?) throw failure;
  return result.value;
});

String failureMessage(Object error) =>
    error is Failure ? error.message : 'Something went wrong. Please retry.';
