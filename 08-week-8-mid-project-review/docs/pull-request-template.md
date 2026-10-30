# Pull request record — Week 8 auth validation

| Field | Value |
| --- | --- |
| Title | `fix(auth): reject malformed campus email addresses` |
| Issue | [#12](https://github.com/JosephAt10/244107020242-mobile-course/issues/12) |
| Pull request | [#2](https://github.com/JosephAt10/244107020242-mobile-course/pull/2) |
| Base branch | `develop` |
| Result | Merged; GitHub Actions checks passed |

## Problem

Malformed email values such as `@` and `student@` passed the previous check.

## Solution

Use one auth-domain email validator in both the login form and `SignIn`. Keep password text unchanged.

## Test steps and results

1. `flutter analyze` — passed, no issues found.
2. `dart format --set-exit-if-changed .` — passed, 29 files, 0 changed.
3. `flutter test` — passed, all tests passed.
4. On the Android emulator, `@` and `student@` were rejected and a valid email shape was accepted by the form.

## Screenshots

The PR contains actual emulator and terminal screenshots. Repository copies are embedded in [README.md](../README.md): `screenshots/3.png`, `4.png`, `5.png`, `1.png`, `2.png`, and `7.png`.

## Review note

The work was completed solo because a peer reviewer was unavailable. A self-review and AI review were recorded; no human peer approval is claimed.
