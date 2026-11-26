## Jobsheet: Matkul Mobile Programming Week 13

| *Informasi* | *Detail* |
| --- | --- |
| Mata Kuliah | Mobile Programming |
| Nama | Joseph Atem Deng Aruei |
| Absen | 17 |
| NIM | 244107020242 |

# CI/CD and Automation

This Week 13 project applies an automated Flutter verification and Android build pipeline to the Offline Notes app. The workflow definition is [`../.github/workflows/week13-ci.yml`](../.github/workflows/week13-ci.yml). GitHub Actions discovers workflows from the repository-root `.github/workflows` directory; the job sets its working directory to this Week 13 project.

## Pipeline

The workflow runs for pushes to `main`, pull requests targeting `main`, and manual dispatch. It checks out the repository, installs the stable Flutter SDK, downloads dependencies, then runs these checks in order:

1. `dart format --output=none --set-exit-if-changed .`
2. `flutter analyze --fatal-infos`
3. `flutter test --coverage`
4. `flutter build apk --release`
5. `flutter build appbundle --release`
6. Uploads the APK and AAB together as the `android-builds` artifact for seven days.

The job has only `contents: read` permission. It does not use repository secrets, sign with a production key, publish to an app store, or make secrets available to pull-request code. The release builds use the project's debug signing configuration and are suitable for pipeline artifact review and internal testing, not production distribution.

## Versioning and security

The app version in `pubspec.yaml` is `1.0.0+1` (version `1.0.0`, build number `1`). The next patch candidate is `1.0.1+2`; increase the build number for each new upload and use a tag such as `v1.0.1` to connect a release to its checked source commit.

Private tokens, passwords, and signing material belong in restricted GitHub Actions secrets, never in source code or logs. Values passed with `--dart-define` are compiled into a client app and are not secret. A production signing workflow should be separately restricted and should not expose signing credentials to pull-request runs. Before distribution, review signing, app configuration, permissions, and target-device behavior.

## Local verification

| Check | Result |
| --- | --- |
| Formatting | `dart format --output=none --set-exit-if-changed .` reports 30 files and zero changes. |
| Static analysis | `dart analyze --fatal-infos` reports no issues. |
| Flutter tests | The Windows runner stops while compiling the `objective_c` native asset hook (`-1073741816`) before test cases run. |
| Android APK | The local release build reached Gradle's `assembleRelease` task but did not finish in this environment. |
| Android App Bundle | The CI workflow is configured to build and upload it; no remote run has been triggered from this workspace. |

GitHub Actions runs the same formatter, Flutter analyzer, test, APK, and AAB commands on Ubuntu. The workflow run summary records its commit and each step; the `android-builds` artifact contains the APK and AAB for seven days.

## Reflection

- **Problem detected automatically before merge:** formatting drift, analyzer findings, a failing regression test, or a release build error makes the workflow fail before the change is accepted.
- **Useful information for investigating a failed build:** the failing step and its full log, workflow run URL, source commit and branch, Flutter/Java versions, and the exact command and error output.
- **Review still needed before a release:** production signing and key custody, app permissions and configuration, dependency/security review, testing on supported devices, release notes/version, and approval to publish. A passing CI build does not perform a store release.

## Run locally

From this directory:

```powershell
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test --coverage
flutter build apk --release
flutter build appbundle --release
```
