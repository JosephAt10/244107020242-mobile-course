# fix(auth): reject malformed campus email addresses

## Problem

The existing login form and `SignIn` use case accepted any non-empty address containing `@`, including malformed values such as `@` and `student@`.

## Solution

Add one pure auth-domain email-shape validator and use it from both the login form and `SignIn`. Keep password text unchanged. Add unit coverage for a normal address, whitespace around an address, `@`, and a missing domain.

## Test steps

1. `flutter pub get`
2. `flutter analyze`
3. `dart format --set-exit-if-changed .`
4. `flutter test`
5. Run on the Android emulator; try `@` and `student@` and confirm the form blocks sign-in, then try a valid shape such as `student@example.edu` with a password of at least six characters.

## Screenshots

- Attach `week8-login-invalid-email.png` and `week8-login-valid-email.png` from the actual emulator run.
- Attach the terminal output for analyze, formatting, and tests.

Closes #<real issue number>