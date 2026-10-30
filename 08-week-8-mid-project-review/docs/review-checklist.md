# Week 8 review checklist and issue/PR record

## Branch and commit hygiene

The codelab requires `main` to remain releasable and untouched directly; `develop` is the PR target; short-lived `feature/*` or `fix/*` branches start from `develop`. Use one logical change per commit, conventional commit subjects, and `git add -p` where files contain unrelated changes.

When this task was inspected, the repository had `main` at `2a7c09d` (`feat: completed jobsheet 7`) and no local or remote `develop` branch. The history audit should be re-run in the VS Code terminal before branch work:

```cmd
git log --oneline -15
git branch -a
git status
```

Codelab commit-message rewrite simulation (examples based on existing broad subjects; this table does not rewrite published history):

| Existing subject | Clearer conventional subject | Reason |
| --- | --- | --- |
| `feat: completed jobsheet 7` | `feat(week7): refactor Campus Notify into clean architecture` | Names the feature scope and result. |
| `feat: completed assignment` | `docs(week6): document authentication and FCM assignment` | Identifies what was completed. |
| `feat: jobsheet 6` | `feat(week6): add mock auth and FCM registration` | States the behavior introduced. |

Do not amend/rebase the published `main` history for this simulation. Preserve `main`; if `develop` is absent, create it once from `main`, push it, then make `feat/auth-email-validation` from `develop`.

## Issue draft — not filed yet

**Title:** `fix(auth): reject malformed campus email addresses`

**Problem:** The form and `SignIn` previously checked only whether an address contained `@`. Inputs such as `@` and `student@` passed that check and could reach the mock authentication repository.

**Acceptance criteria:**

- A basic address with a local part, `@`, domain, and dot suffix is accepted (for example `student@example.edu`).
- `@`, `student@`, and whitespace-only values are rejected before repository sign-in.
- The form and domain use the same pure validator.
- Tests cover accepted and rejected forms; `flutter analyze`, `dart format --set-exit-if-changed .`, and `flutter test` pass.

**Planned branch:** `feat/auth-email-validation` from `develop`.

## PR record — local draft only

- **Title:** `fix(auth): reject malformed campus email addresses`
- **Target:** `develop`
- **Issue:** Add the real issue reference after filing; use `Closes #<issue-number>` in the PR.
- **Reviewer / review URL / merge commit:** Pending; leave blank until a real peer review and merge happen.
- **Review disposition:** Pending. Never mark approved or merged based on this document.

Use `docs/pull-request-template.md` as the complete PR body. Reviewer should inspect the branch, run the app and tests, leave actionable correctness/architecture/test comments, and either request changes or approve. Address every requested change, request re-review, and merge only after approval and green checks.

## Review checklist

- [ ] Branch starts from `develop`; one small feature; fewer than 300 changed lines.
- [ ] Issue is filed and linked; PR targets `develop` and closes that issue.
- [ ] PR includes problem, solution, test steps, and real screenshots.
- [ ] At least two correctness findings, one architecture finding, one test-gap finding, and one readability suggestion are recorded by a real peer.
- [ ] Requested changes are fixed; reviewer re-reviews and approves; PR is merged and feature branch deleted.
- [ ] `flutter analyze`, `dart format --set-exit-if-changed .`, and `flutter test` all pass; CI is green.
- [ ] `docs/ai-review-vs-decision.md` records the AI prompt, raw first-pass response, two verified accepted findings, one rejected finding, and evidence.

## Screenshot checklist

Save actual evidence under this folder’s `screenshots/` directory:

1. `week8-login-invalid-email.png` — app running in the emulator with malformed email validation visible.
2. `week8-login-valid-email.png` — form accepts a valid email shape (password can remain blank if the screenshot shows field-level validation state).
3. `week8-issue.png` — real GitHub issue showing title and acceptance criteria.
4. `week8-pr-template.png` — real PR page showing problem, solution, test steps, and screenshot section.
5. `week8-peer-review.png` — reviewer comments and requested-changes/approval thread, with the addressed follow-up.
6. `week8-ci-green.png` — completed Actions run for the PR after the workflow is installed at repository root.
7. `week8-checks.png` — terminal showing the actual successful analyze, formatter, and test results.
8. `week8-merge.png` — merged PR into `develop`, with issue auto-closed and feature branch deleted.

Do not create or label placeholder/mock images as real evidence. The app screenshots can be captured after running the app; the GitHub and CI screenshots require the corresponding real external actions.