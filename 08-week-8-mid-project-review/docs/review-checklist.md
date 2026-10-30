# Week 8 review checklist and issue/PR record

## Git Flow and change record

- `main` remains the release branch; `develop` is the integration branch.
- Feature branch: `feat/auth-email-validation`.
- Pull request: [#2](https://github.com/JosephAt10/244107020242-mobile-course/pull/2), from the feature branch into `develop`; merged.
- Issue: [#12](https://github.com/JosephAt10/244107020242-mobile-course/issues/12), malformed campus email validation.
- The merged PR comparison contains 172 files because the Week 8 folder includes the app snapshot as well as the auth validation change. This is larger than the codelab's suggested small PR scope; the validation behavior itself is limited to one feature.

## Issue acceptance criteria

Issue #12 tracks the following behavior:

- Accept a basic address shape with a local part, `@`, domain, and dot suffix (for example `student@example.edu`).
- Reject `@`, `student@`, and whitespace-only values before repository sign-in.
- Reuse one pure validator in the login form and `SignIn` use case.
- Cover valid and invalid inputs with tests.

## Pull request and review record

- **Title:** `fix(auth): reject malformed campus email addresses`
- **Target:** `develop`
- **Problem / solution / test steps / screenshots:** included in PR #2.
- **Checks:** GitHub Actions `Week 8 Flutter CI` succeeded; analyze, format, and tests passed locally.
- **Outcome:** PR #2 merged to `develop`.
- **Review approach:** completed solo because a peer reviewer was unavailable. The PR contains a self-review note and the AI review/final decisions are documented in `docs/ai-review-vs-decision.md`. No human peer approval is claimed.

## Verification record

The captured terminal output is in `screenshots/`:

- `1.png`: `flutter analyze` passed with no issues.
- `2.png`: `flutter test` passed; all tests passed.
- `7.png`: `dart format --set-exit-if-changed .` passed; 29 files, 0 changed.
- `9.png`: PR #2 details, screenshots, and passing checks.
- `10.png`: merged PR and the solo-review note.

## App evidence

- `3.png`: `@` rejected in the login form.
- `4.png`: `student@` rejected in the login form.
- `5.png`: valid campus email entered.

The corresponding screenshots are embedded in the project [README](../README.md). The issue is linked above; the available screenshot set does not contain a separate issue-page capture.
