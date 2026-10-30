## Jobsheet: Matkul Mobile Programming Week 6

| *Informasi* | *Detail* |
| --- | --- |
| Mata Kuliah | Mobile Programming |
| Nama | Joseph Atem Deng Aruei |
| Absen | 17 |
| NIM | 244107020242 |

## Mid-semester status

Week 8 continues the Week 7 Clean Architecture Campus Notify project in this folder. The app retains mock sign-in, announcement list/detail navigation, secure token storage, Dio refresh handling, and Firebase Cloud Messaging. This review adds a focused auth fix: the email validator previously treated any string containing `@` as valid, so inputs such as `@` or `student@` could reach sign-in.

The login form and `SignIn` use the same pure domain validation function. This keeps malformed addresses from being submitted and keeps presentation and domain rules aligned. Password text is intentionally not trimmed because spaces can be part of a password.

## Main features and tech stack

- Campus Notify login using the existing mock authentication adapter.
- Feature-first Clean Architecture with presentation, domain, and data layers, Riverpod, and GoRouter.
- Announcements list/detail, Dio one-retry refresh logic, secure token storage, and Firebase Messaging topic/deep-link support from Week 7.
- This Week 8 change: shared campus-email shape validation with unit coverage.
- Flutter, Dart, Riverpod, GoRouter, Dio, `flutter_secure_storage`, Firebase Core/Messaging, and `flutter_local_notifications`.

## Layer and dependency direction

```text
presentation (widgets, Riverpod, routing)
       ↓ depends on
 domain (entities, contracts, use cases, validation)
       ↑ implemented by
 data (models, repositories, Dio, secure storage)
```

The UI calls the domain validator and sign-in use case. Domain remains independent of Flutter and infrastructure packages. Data implements domain repository contracts; Riverpod wires concrete implementations.

## Issue and PR map

| Item | Status | Details |
| --- | --- | --- |
| Issue draft | Prepared locally; not filed on GitHub | `docs/review-checklist.md` contains the title, problem, acceptance criteria, and branch/PR plan. Add the real issue URL/number after filing it. |
| Small change | Implemented in this Week 8 copy | Shared email-shape validation and tests in the auth domain, login form, and sign-in use case. |
| PR template | Prepared locally | `docs/pull-request-template.md`; includes problem, solution, test steps, and screenshot evidence. |
| Peer review / merge | **Pending** | No real peer reviewed or approved this change yet. Do not report the assignment’s peer-review requirement as complete until a reviewer comments, requested changes are addressed, approval is recorded, and the PR is merged into `develop`. |
| Branch flow | **Pending repository operation** | Required flow is `main` → `develop` → `feat/auth-email-validation` → PR to `develop`. The portfolio repo currently had only `main` when inspected. The `develop` and feature branches still need to be created/pushed in the Git worktree. |

The application code and assignment documents are located in `08-week-8-mid-project-review/`. A folder nested in the portfolio repository does not itself create a GitHub issue or PR.

## Run locally

Open this folder in VS Code, then run:

```powershell
flutter pub get
flutter analyze
dart format --set-exit-if-changed .
flutter test
flutter run
```

Android is the intended platform for validating Firebase Messaging. The mock sign-in works without a real account. Firebase push requires the Android Firebase configuration and a Play Services emulator/device.

## Green-machine verification

Verification performed for this Week 8 copy:

- `dart analyze`: **Passed — No issues found.**
- `dart format --output=none --set-exit-if-changed .`: **Passed — 29 files, 0 changed.**
- `flutter analyze`: **Not confirmed here.** The Flutter CLI did not return output in the Codex shell; run it in the VS Code terminal before claiming it passed.
- `flutter test`: **Not confirmed here.** The Flutter CLI test invocation did not return; run it in the VS Code terminal and record the result before requesting review.
- GitHub Actions CI: **Pending** until a workflow is installed at the portfolio repository root and a push/PR run completes.

A sample workflow is in `.github/workflows/ci.yml`. GitHub only discovers workflows in the repository-root `.github/workflows/`; because this coursework copy is nested, copy that file to the portfolio root before expecting GitHub Actions to run.

## Review documents

- [Peer-review checklist, issue draft, and commit hygiene](docs/review-checklist.md)
- [AI review prompt, initial output, and decisions](docs/ai-review-vs-decision.md)
- [Pull request template](docs/pull-request-template.md)

## Screenshot evidence

Existing Week 7 screenshots are retained in `screenshots/` as baseline evidence. Capture the Week 8 evidence listed in `docs/review-checklist.md` after running the app and completing the real GitHub review. Do not substitute the codelab screenshots for evidence of your own app or PR.