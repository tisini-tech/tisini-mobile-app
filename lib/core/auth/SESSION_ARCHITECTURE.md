# Auth session architecture (Remember me)

This app does **not** store passwords. “Remember me” keeps a **refresh token** in the
device secure vault so the user can return without signing in again.

## What is stored where

| Data | Storage | Encrypted | When |
|------|---------|-----------|------|
| Access token (JWT) | `SecureSessionStore` + in-memory cache | Yes (Keychain / Keystore) | Every successful login |
| Refresh token | `SecureSessionStore` | Yes | Login with **Remember me** checked |
| Remember-me flag | `UserSessionPrefs` (GetStorage) | No | User toggles checkbox |
| Remembered login id (email/phone) | `UserSessionPrefs` | No | Remember me ON only |
| User profile (name, email, roles, …) | `UserSessionPrefs` | No | Every login |
| Password | **Never stored** | — | — |

## Layer map

```
Presentation          AuthController, LoginScreen
       │
       ▼
Application           SessionService          ← orchestrates login / restore / logout
       │
       ├── UserSessionPrefs                  ← non-sensitive prefs (remember me, profile)
       ├── AuthTokenStorage                  ← token cache + facade for HTTP layer
       │        └── SecureSessionStore       ← flutter_secure_storage
       └── TokenRefreshService               ← POST /auth/refresh-token
                ▲
                └── HttpService interceptor   ← retries 401 using same refresh logic
```

## Flows

### 1. Sign in (Remember me ON)

1. User submits email/phone + password (password is only sent to API).
2. `AuthController.signIn` → `UserLogin` use case → API `/auth/login`.
3. `SessionService.persistLogin(rememberMe: true)`:
   - Saves access + refresh tokens to **secure storage**.
   - Sets `remember_me = true` and stores login id for prefilling next time.
   - Saves user profile to prefs.
4. Navigate to `/dashboard`.

### 2. Sign in (Remember me OFF)

Same as above, except:

- `remember_me = false`, remembered login id cleared.
- Tokens are still saved for the **current app session** (API calls).
- On the **next cold start**, `SessionService.tryRestoreSession` clears tokens and
  shows login (user must sign in again).

### 3. Cold start / open login screen

1. `main()` → `AuthTokenStorage.initialize()` loads token cache.
2. `LoginScreen` → `SessionService.tryRestoreSession()`:
   - If `remember_me` is false → clear tokens → show login form.
   - If `remember_me` is true → `TokenRefreshService.refresh()`:
     - Success → `Get.offAllNamed('/dashboard')`.
     - Failure → clear session → show login (login id prefilled if saved).

### 4. API 401 (access token expired)

`HttpService` interceptor calls `TokenRefreshService.refresh()`.

- Success → retry original request with new access token.
- Failure → `AuthTokenStorage.clear()` → redirect to `/login`.

### 5. Logout / session expired

Call `SessionService.clearSession()`:

- Deletes tokens from secure storage and legacy prefs.
- Optionally keeps remembered login id when only the session expired (not user logout).

## Files to know

| File | Role |
|------|------|
| `lib/core/auth/session_service.dart` | **Start here** — login persistence, restore, clear |
| `lib/core/auth/secure_session_store.dart` | Low-level secure read/write |
| `lib/core/auth/user_session_prefs.dart` | Remember me + profile fields |
| `lib/core/auth/token_refresh_service.dart` | Shared refresh HTTP call |
| `lib/core/services/auth_token_storage.dart` | Token cache used by `HttpService` |
| `lib/features/auth/presentation/controllers/auth_controller.dart` | UI actions |
| `lib/features/auth/presentation/screens/login_screen.dart` | Restore on open |

## Security notes

- Never log tokens or passwords.
- Do not move tokens back to plain `GetStorage` for new code — use `AuthTokenStorage`.
- Legacy `GetStorage` token keys are still synced temporarily for older controllers;
  migrate them to `AuthTokenStorage.accessToken` over time.
- Optional next step: `local_auth` biometric gate before `tryRestoreSession`.

## Adding logout in UI

```dart
await Get.find<SessionService>().clearSession(clearRememberMe: true);
Get.offAllNamed('/login');
```
