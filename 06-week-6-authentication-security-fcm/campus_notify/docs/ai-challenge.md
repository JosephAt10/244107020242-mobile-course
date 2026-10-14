# Week 7 Clean Architecture AI Challenge

## Prompt used

> My Flutter project is `campus_notify` (auth + FCM + announcement list). Current state: `lib/{data, providers, pages, messaging}` folders, repositories mixed with implementations, widgets calling Dio directly.
> Tasks:
> 1. Propose a feature-first Clean Architecture structure (presentation/domain/data) for the auth + announcements features.
> 2. For each old file, state its new destination (move/split/delete).
> 3. Flag what would be over-engineered if applied to simple CRUD, and when a use case is truly needed versus repository straight to notifier.
> 4. Show Riverpod DI wiring (no extra DI package).
> Explain the trade-off of every decision.

## Initial AI proposal

The initial proposal was to split both features into `domain/`, `data/`, and `presentation/`; place entities, repository contracts, and operation-specific use cases in domain; place serialization models and concrete repositories in data; and construct the implementation and use cases in Riverpod providers. It also proposed moving route parsing to a pure utility and keeping FCM as an infrastructure service outside the announcement UI. Auth would keep secure token storage and the one-retry Dio interceptor in its data layer. Announcement data would remain a small local fixture because this repository has no announcements backend or database.

Proposed mapping:

| Existing file | Proposed destination | Decision |
| --- | --- | --- |
| `lib/data/auth_repository.dart` | Auth domain contract + `lib/features/auth/data/repositories/mock_auth_repository.dart` | Split interface from mock adapter; session model maps token data. |
| `lib/data/token_store.dart` | `lib/features/auth/data/datasources/token_store.dart` | Move secure-storage adapter to auth data. |
| `lib/data/api_client.dart` | `lib/features/auth/data/datasources/api_client.dart` | Move Dio/interceptor implementation to auth data. |
| `lib/providers/auth_provider.dart` | `lib/features/auth/presentation/providers/auth_provider.dart` | Keep Riverpod wiring/state at the presentation boundary. |
| `lib/pages/login_page.dart` | `lib/features/auth/presentation/pages/login_page.dart` | Move login UI. |
| Inline home announcements | Announcement entity, repository contract, local data adapter, use case, provider | Split hardcoded content out of widgets. |
| `lib/pages/announcement_page.dart` | `lib/features/announcements/presentation/pages/announcement_page.dart` | UI watches the detail provider. |
| `lib/routes.dart` | Keep route constants; move FCM route parsing to `lib/core/format.dart` | Make parsing independently testable. |
| `lib/messaging/push_service.dart` | Keep under `lib/messaging/` | FCM lifecycle is infrastructure; presentation only displays status. |
| `lib/data/api_errors.dart` | `lib/features/auth/data/api_errors.dart` | Keep Dio-specific error mapping next to auth/network infrastructure. |

This is the documented first proposal used for the challenge, not a transcript copied from an earlier assistant response.

## Proposal versus final decision

| Proposal | Final decision | Reason |
| --- | --- | --- |
| One use case per operation | Keep `GetAnnouncements`, `GetAnnouncement`, and `SignIn`; do not add use cases for token reads, logout, or topic subscribe | Listing/detail lookup is the selected announcement feature; sign-in validates and owns the authentication operation. Simple storage/topic calls do not gain useful policy from another wrapper. |
| Convert announcement fixtures to SQLite/API | Keep a local in-memory data adapter | No backend/database is part of this app, and the assignment is a refactor of working behavior, not a new feature. |
| Generic result with `Failure` | Keep `OperationResult<T>` and typed failures | It carries errors across the domain boundary without throwing raw Dio/Firebase/SQLite exceptions into widgets. |
| Use Firebase Auth | Keep mock authentication | This is the Week 6 demo; Firebase Auth credentials were not configured and changing auth would alter behavior. README labels it mock. |
| Widgets can read token store for user label | Rejected; expose `currentUserEmailProvider` | Secure storage access belongs behind presentation wiring, not inside a page. |
| Home page imports app bootstrap for FCM status/startup | Rejected; move status values to messaging module and start after router/auth setup | Breaks a page-to-root dependency and makes the widget less coupled to app composition. |
| Treat codelab screenshot files as new evidence | Rejected; preserve them as existing Week 6 evidence and request fresh after screenshots | Screenshots must show the actual refactored build and cannot be fabricated. |

## Final structure and dependency direction

```text
lib/features/announcements/presentation -> domain <- data
lib/features/auth/presentation         -> domain <- data
lib/core/format.dart                   pure route/date helpers
lib/messaging/                         Firebase lifecycle and notification events
```

Riverpod providers in each feature's `presentation/providers/` are the composition points. The announcement page watches `FutureProvider` state; the auth notifier calls `SignIn`; neither page constructs a repository. The domain folders import only project core/domain Dart files, not Flutter, Riverpod, Dio, Firebase, or storage packages.

## Technical rationale

An interface in domain lets business operations define the contract without depending on SQLite, Firebase, or HTTP. If the interface were in data, the domain use case would import an outer implementation package; replacing the storage adapter would force business code to change and tests would need infrastructure knowledge. Presentation depends inward on domain abstractions; the data adapter implements those abstractions; Riverpod performs the concrete wiring at the outside.

A use case is useful when an operation owns validation, coordination, policy, or a stable business action. A use case for every one-line CRUD method only adds files and indirection. A small team should call a repository from a notifier for a trivial pass-through; add the use case when rules need independent tests or the operation composes multiple dependencies. This refactor uses a sign-in use case for credential validation and a list/detail use case for the announcement feature. It intentionally does not add token-store or FCM topic use cases.

The entity has no `toMap`/JSON mapping. `AnnouncementModel` and `AuthSessionModel` own external representations; mapping happens at the data/domain boundary. Failures are simple domain values with UI-safe messages. Riverpod creates repository implementations, while widgets only read provider state.
### Initial proposal detail

The first pass proposed this concrete structure:

```text
lib/
  core/                 failures and pure format/route helpers
  features/
    auth/
      domain/{entities,repositories,usecases}/
      data/{models,repositories,datasources}/
      presentation/{providers,pages}/
    announcements/
      domain/{entities,repositories,usecases}/
      data/{models,repositories}/
      presentation/{providers,pages}/
  messaging/            FCM handlers, notification channel, token events
  main.dart             Firebase boot and GoRouter composition
```

It recommended Riverpod as the only dependency-injection mechanism:

```dart
final announcementRepositoryProvider = Provider<AnnouncementRepository>(
  (ref) => AnnouncementRepositoryImpl(),
);
final getAnnouncementsProvider = Provider<GetAnnouncements>(
  (ref) => GetAnnouncements(ref.watch(announcementRepositoryProvider)),
);
final announcementsProvider = FutureProvider((ref) async {
  final result = await ref.watch(getAnnouncementsProvider)();
  if (result.failure case final failure?) throw failure;
  return result.value!;
});
```

It recommended keeping `SignIn` because credential validation is domain policy; using a repository directly for trivial token reads, logout, topic subscribe/unsubscribe, or a one-line lookup would add indirection without a business rule. It recommended adding persistence only after a real API or database exists. These recommendations were then checked against the actual Week 6 files and adjusted in the final-decision table above.