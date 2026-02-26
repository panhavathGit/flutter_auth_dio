# Authentication Implementation Guide

## 1. Overview
This project uses a **Triple-Model Architecture** to communicate with the Express.js backend. This ensures a clean separation between sensitive credentials, security tokens, and public profile data.



## 2. The Model Trio

### AuthRequest (`auth_request.dart`)
- **Direction:** Frontend => Backend
- **Contains:** `username`, `password`.
- **Logic:** Used only during Login/Register. We do not keep this in state.

### AuthResponse (`auth_response.dart`)
- **Direction:** Backend => Frontend
- **Contains:** `userId`, `accessToken`, `refreshToken`.
- **Logic:** This is the "Token Package." The tokens should be extracted and saved to **Secure Storage**.

### UserModel (`user_model.dart`)
- **Direction:** Backend => Frontend
- **Contains:** `id`, `fullname`, `phone`, `address`, `firebaseToken`.
- **Logic:** This is the global user state. It is used to populate the UI (Profile screen, headers, etc.).

---

## 3. Data Flow Pattern

1. **Login:** UI gathers data into `AuthRequest`.
2. **Exchange:** API returns `AuthResponse`.
3. **Secure:** `accessToken` & `refreshToken` are saved to Secure Storage.
4. **Hydrate:** The `userId` from `AuthResponse` is used to call the `/profile` endpoint.
5. **State:** The resulting `UserModel` is stored in the Global State (Bloc/Provider).



---

## 4. Maintenance & Generation

This feature uses `json_serializable`. If you modify any fields in the `.dart` models, you **must** run the generator:

```bash
dart run build_runner build --delete-conflicting-outputs