# Week 10 AI log — streamed study chat

## System prompt used for the feature

> You are a friendly study assistant for a college student. Answer in clear English, in at most two short sentences. Do not claim access to campus schedules, accounts, or private records. If you do not know, say so and suggest checking an official source. Never ask the user to share passwords, API keys, or sensitive personal data.

The app sends that instruction as Gemini's `system_instruction`. It is accompanied only by the user's in-memory chat turns; saved notes are not included.

## Core implementation prompt

> Role: senior Flutter developer. Context: extend the existing Week 9 Offline Notes Flutter app. Its stack is Flutter/Dart, Riverpod 2, GoRouter, SQLite (`sqflite`), SharedPreferences, and the Week 9 title-search feature. Task: add one small, usable AI feature—a study-question chat with a chat UI, streamed reply, loading state, secure user-managed Gemini API key, and clear retry/offline fallback. Keep existing notes, routes, search, and persistence behavior. Keep provider wiring in Riverpod, API-key access behind secure storage, and HTTP/SSE handling out of widgets. Do not include saved notes or personal data in requests. Bound request length/history/output and add a daily request cap. Verify the Gemini method/model/API response format against official docs. Include tests for stream parsing, missing key, and request limits; report commands and manual emulator steps. Do not hardcode or log secrets.

## Pasted project context

- Week 9 project: `09-week-9-ai-assisted-development/`.
- Main screen: `lib/pages/notes_page.dart`; app routing and Riverpod scope: `lib/main.dart`.
- Existing features: SQLite notes, Riverpod, SharedPreferences settings, GoRouter, title-only search, offline/sync demo.
- Existing Dart SDK constraint was `>=3.3.0`; Week 10's selected `flutter_secure_storage` 11.2.0 requires Dart 3.8, so the Week 10 copy's minimum was raised to Dart 3.8.
- No API key or user credentials were included in the prompt/context.

## Initial AI output (first proposal)

The first implementation outline proposed a settings text field, a chat screen, and one `AiService.ask(question)` method calling a single-response Gemini endpoint. It followed the jobsheet's sample shape, which put the key in a URL query parameter and returned the entire answer at once. It also proposed passing only the current question, not the conversation history.

That outline did not satisfy the streamed-chat requirement, and a key in a URL can be retained by request diagnostics. I checked the current official Gemini REST API docs before implementing the endpoint and changed the request to the `streamGenerateContent` SSE endpoint with the key in the HTTPS `x-goog-api-key` header. The project model identifier is `gemini-3.5-flash-lite` as listed in the current model catalog.

## Proposal vs final decision

| Initial proposal | Decision | Final implementation and reason |
|---|---|---|
| One-shot `generateContent` response | Rejected | `streamGenerateContent` emits SSE chunks; the UI renders partial text and shows a loading indicator before the first chunk, meeting the chat requirement. |
| Put the API key in the URL query string | Rejected | API keys are secrets; use `x-goog-api-key` HTTPS header to avoid putting it in URL logs/history. Google warns that client-side keys remain extractable, so a backend proxy is required for production. |
| Put HTTP, JSON parsing, and widget state in a single `AiService`/screen | Simplified/refactored | UI calls a domain `ChatRepository` contract through a Riverpod provider; `GeminiChatRepository` owns HTTP/SSE and `SecureApiKeyStore` owns the key. This follows the existing feature-first direction and makes the transport fakeable in tests. |
| Send only the last question | Rejected | A chat reply needs bounded recent context. The app sends at most the latest 11 turns and does not attach the user's notes. |
| No request/cost bound | Rejected | UI limits message length, the repository bounds history/output, and a local per-install counter caps daily attempts. This deters accidental overuse but is not a server-enforced security limit. |
| Return raw network/provider errors | Rejected | Statuses, timeout, no-network, invalid key, empty response, and rate limiting map to short user-facing messages with retry and offline-notes guidance. Raw response bodies are not shown or logged. |

## Verification and manual fixes

- Confirmed the endpoint uses `POST /v1beta/models/{model}:streamGenerateContent?alt=sse`, the response is a stream of `GenerateContentResponse` events, and `system_instruction` plus multiple user/model turns are supported by the Generate Content API documentation.
- Confirmed `flutter_secure_storage` 11.2.0 uses platform secure storage and requires Dart 3.8; updated the Week 10 copy's SDK lower bound accordingly.
- Added the Android internet permission and a distinct Week 10 application ID, so installing this copy does not replace the earlier app.
- Set `android:allowBackup="false"` to avoid restoring encrypted storage data without its Android Keystore key.
- Kept chat messages transient in the screen; no note content is used as model context.
- Added user-facing handling for missing/invalid keys, provider rate limits, HTTP failures, timeouts, connectivity, malformed SSE/JSON, and empty results.
- Included an explicit request cap and tests around limit boundary behavior.

## Test evidence

Validation run in this Week 10 project copy:

- `flutter analyze`: passed with **No issues found**.
- `dart format --output=none --set-exit-if-changed .`: passed; **29 files, 0 changed**.
- `flutter test`: passed; **13 tests**.
- `flutter build apk --debug`: attempted but the Gradle process could not establish a loopback connection in this execution environment; APK packaging is therefore not claimed as verified.

Automated coverage includes:

- `test/features/ai/domain/daily_request_policy_test.dart`: allowed request below cap; blocked request at/above cap.
- `test/features/ai/data/gemini_chat_repository_test.dart`: SSE chunks, key header/no key query parameter, system instruction, daily count, and friendly missing-key failure.
- The copied Week 9 tests for notes, title filtering, and no-results UI.

## Reflection

1. **AI feature and reason:** a streamed study-question chat extends the notes app with help while leaving persisted notes untouched.
2. **Privacy:** send only what a user types, warn against sensitive content, hold conversation in memory, store the entered key in platform secure storage, and never log it. Production needs a backend proxy because an app-side API key can be extracted.
3. **Fallback:** explain whether setup, network, timeout, quota, key, or provider caused the failure; allow retry; keep local notes usable offline.
4. **Mobile UX lesson:** streamed partial answers plus a clear loading state make waiting visible. Limits and privacy notices should be close to the send action, and a generated answer should not be treated as authoritative campus data.

## References consulted

- Gemini API [Generate Content API](https://ai.google.dev/api/generate-content)
- Gemini API [API key security](https://ai.google.dev/gemini-api/docs/api-key)
- Gemini API [models](https://ai.google.dev/gemini-api/docs/models)
- [`flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage)
