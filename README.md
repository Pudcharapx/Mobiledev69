# Muscle Heatmap Workout Tracker

A mobile workout tracking application that visualizes weekly resistance training volume as an interactive **Muscle Heatmap** — a front and back body diagram that color-codes muscle groups based on weekly training intensity (red = under-trained, green = target met), combined with an automated **Muscle Imbalance Alert** system.

> **Citation & Source Attribution**:
> Muscle mappings and exercise contribution weightings are based on publicly available general fitness references from [ExRx.net](https://exrx.net) per SRS.md sections 4.1, 6, and 10.

---

## 1. Project Name & Description

**Muscle Heatmap Workout Tracker** is a single-user mobile application built for people who perform regular resistance/weight training. Existing fitness applications typically represent training progress as plain tabular numbers or bar charts, making it difficult to assess overall balance. This application solves that problem by:
- Visualizing weekly training volume directly onto an interactive front and back human body SVG map.
- Normalizing volume against weekly goals using a red $\to$ amber $\to$ green completion gradient.
- Detecting opposing muscle imbalances (e.g. chest vs. back, quads vs. hamstrings, biceps vs. triceps) and surfacing alerts when volume disparity exceeds 40%.
- Delivering a fast, 3-tap logging UX with steppers and smart defaults that pre-fill weights from the previous workout.

---

## 2. Features

All features listed below are fully implemented and verified with zero errors:

1. **OIDC Authentication & Route Guarding** (SRS 3.2, 7.1):
   - Authorization Code Flow with PKCE against a self-hosted Django OIDC server (`django-oidc-provider`, RS256).
   - Secure token storage using `flutter_secure_storage`.
   - Persistent session across application restarts and complete session clearance on sign out.
   - Declarative route guarding via `go_router` blocking unauthorized access.

2. **Workout Logging CRUD with MVVM Architecture** (SRS 3.1, 5, 7):
   - Full Create, Read, Update, and Delete actions scoped strictly to the authenticated user.
   - Dropdown selection of 18 pre-seeded baseline exercises covering all major muscle groups.
   - Stepper (+/-) input for sets and reps (no typing required).
   - Numeric keypad for weight pre-filled with the last logged value for that exercise (Smart Defaults).
   - Date-grouped log list with floating action button and friendly SnackBar error handling.

3. **Interactive Muscle Heatmap** (SRS 8.1):
   - Front and back human body views rendered via `flutter_svg`, divided into 9 muscle zones: `chest`, `back`, `shoulders`, `biceps`, `triceps`, `legs`, `hamstrings`, `glutes`, and `core`.
   - Calculates weekly volume per muscle group using the exact formula:
     $$\text{volume}(X) = \sum (\text{sets} \times \text{reps} \times \text{contribution\_weight}[X])$$
   - Color mapping along a Red ($<50\%$) $\to$ Amber ($50\text{--}79\%$) $\to$ Green ($80\text{--}120\%$) gradient.
   - Tap-to-inspect popup dialog showing all contributing logs for any selected muscle zone.

4. **Muscle Imbalance Alert** (SRS 8.2):
   - Evaluates exactly the 3 opposing pairs from SRS section 6:
     - `chest` vs `back`
     - `legs (quads)` vs `hamstrings`
     - `biceps` vs `triceps`
   - Numeric comparison triggering an alert when volume disparity exceeds $40\%$:
     $$\text{diff} = \frac{\max(V_A, V_B) - \min(V_A, V_B)}{\max(V_A, V_B)} > 0.40$$
   - Formatted alert messages in SRS 8.2 style:
     `"Your {undertrained} is undertrained compared to your {overtrained} — consider adding more {undertrained} work"`.

5. **Card-Based Visual Aesthetic** (SRS 9.2):
   - **Dark Feature Card**: Highlights active imbalance alerts with volume comparison bars and action buttons.
   - **Circular Progress Ring**: Displays overall weekly balance percentage in the center.
   - **Pill / Segmented Tab Switcher**: Capsule tab bar switching between `Heatmap`, `Log List`, and `Settings`.
   - **Consistent Top Navigation**: Circular back button on the left, calendar icon and round profile photo on the right.
   - Large rounded cards ($20\text{px}$ radius) with generous padding throughout.

6. **Dark Mode with Saved Preference** (SRS 8.3, 9.3 item 6):
   - Toggle between Light, Dark, and System modes in the Settings screen.
   - Selected theme preference is saved to secure storage and restored on cold app startup.

---

## 3. Tech Stack

### Frontend (Flutter)
- **Framework**: Flutter 3.32+ / Dart 3.8+
- **Architecture**: MVVM (Model-View-ViewModel) + Repository Pattern + Result Pattern
- **State Management & DI**: `provider` (^6.1.2)
- **Navigation & Route Guard**: `go_router` (^14.8.1)
- **HTTP Client**: `dio` (^5.8.0)
- **OIDC & PKCE**: `openid_client` (^0.4.10)
- **Secure Token Storage**: `flutter_secure_storage` (^9.2.4)
- **Vector Graphics**: `flutter_svg` (^2.0.17)
- **Localization & Formatting**: `intl` (^0.20.2)

### Backend (Django)
- **Runtime**: Python 3.12+
- **Dependency Management**: `uv`
- **Framework**: Django 5.x
- **REST API**: Django REST Framework (DRF)
- **Authentication**: `django-oidc-provider` (OAuth 2.0 / OIDC Authorization Code Flow + PKCE, RS256)
- **Database**: SQLite (pre-configured, auto-seeded on migrate)

---

## 4. Prerequisites

Install the following tools before running the application:

1. **Git**: [https://git-scm.com/downloads](https://git-scm.com/downloads)
2. **Flutter SDK** (v3.24 or newer): [https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)
3. **Python** (v3.12 or newer): [https://www.python.org/downloads/](https://www.python.org/downloads/)
4. **uv** (Fast Python package manager): [https://docs.astral.sh/uv/getting-started/installation/](https://docs.astral.sh/uv/getting-started/installation/)
   - Windows PowerShell install: `irm https://astral.sh/uv/install.ps1 | iex`
   - macOS / Linux install: `curl -LsSf https://astral.sh/uv/install.sh | sh`
5. **Google Chrome**: [https://www.google.com/chrome/](https://www.google.com/chrome/)

---

## 5. How to Run

Follow these line-by-line terminal commands from a fresh terminal.

### 5.1 Clone & Checkout Branch
```bash
git clone https://github.com/Pudcharapx/Mobiledev69.git
cd Mobiledev69/project
git checkout project
```

### 5.2 Start Backend Server (Terminal 1)
```bash
cd backend
uv sync
uv run python manage.py migrate
uv run python manage.py bootstrap_oidc
uv run python manage.py runserver 8000
```
> The Django backend will start at `http://127.0.0.1:8000/`.
> The `bootstrap_oidc` command automatically creates the OIDC Client, RS256 key, and the pre-configured demo account.

### 5.3 Start Flutter Application (Terminal 2)
In a new terminal window from the `project/` directory:
```bash
flutter pub get
flutter run -d chrome --web-port=50000
```
> The application will open in Google Chrome at `http://localhost:50000`.
> `--web-port=50000` matches the pre-registered OIDC redirect URI (`http://localhost:50000/callback`).

### 5.4 Run Automated Tests (Optional)
```bash
# Run Django backend test suite (29 tests)
cd backend
uv run python manage.py test

# Run Flutter frontend test suite (47 tests)
cd ..
flutter test
flutter analyze
```

---

## 6. Demo Account

Use this working OIDC user to log into the application:

| Field | Value |
|---|---|
| **Username** | `demouser` |
| **Password** | `demo12345` |
| **Email** | `demo@example.com` |

*Note: This account is automatically created when running `uv run python manage.py bootstrap_oidc`.*

---

## 7. Screenshots

### Screenshot 1: Heatmap Home & Muscle Imbalance Alert
*Interactive front and back human body SVG map with muscle zone completion colors, circular progress ring, and dark feature card summarizing opposing muscle imbalances.*

```
+-----------------------------------------------------------+
| (<-) Muscle Heatmap                  [Today]   [U Profile]|
+-----------------------------------------------------------+
|    [ Heatmap (active) ]   [ Log List ]   [ Settings ]     |
|                                                           |
| +-[ Muscle Imbalance Alert (Dark Feature Card) ]--------+ |
| | [!] 1 opposing pair exceeds 40% volume difference     | |
| | > Your back is undertrained compared to your chest    | |
| |   chest: 200 vol  |  back: 80 vol (+60% diff)         | |
| | [============ Add Workout to Balance ===============] | |
| +-------------------------------------------------------+ |
|                                                           |
| +-[ Weekly Training Balance ]---------------------------+ |
| |  ( 68% )  Weekly Volume: Sep 8 - Sep 14                | |
| +-------------------------------------------------------+ |
|                                                           |
| +-[ Body Heatmap (Front + Back Views) ]-----------------+ |
| |   [FRONT VIEW]                    [BACK VIEW]           |
| |   Chest: 100% (Green)             Back: 40% (Red)       |
| |   Legs: 80% (Green)               Hamstrings: 80%       |
| +-------------------------------------------------------+ |
+-----------------------------------------------------------+
```

### Screenshot 2: Workout Log Form (Sets/Reps Stepper & Smart Defaults)
*Form showing dropdown exercise picker, sets & reps stepper controls, and numeric weight pre-filled with last logged values.*

```
+-----------------------------------------------------------+
| (<-) New Workout Log                 [Today]   [U Profile]|
+-----------------------------------------------------------+
| +-[ Exercise Selection ]--------------------------------+ |
| | Exercise: [ Bench Press                       v ]     | |
| | Target muscles: chest + shoulders, triceps            | |
| +-------------------------------------------------------+ |
|                                                           |
| +-[ Sets & Repetitions (Stepper Input) ]----------------+ |
| | Sets:          [-]         4         [+]              |
| | ----------------------------------------------------- | |
| | Reps per Set:  [-]        10         [+]              |
| +-------------------------------------------------------+ |
|                                                           |
| +-[ Weight & Notes ]------------------------------------+ |
| | Weight: [ 70.0 ] kg (pre-filled from last session)    | |
| | Notes:  [ Feeling strong, smooth reps ]               | |
| +-------------------------------------------------------+ |
|                                                           |
| [================ Save Workout Log ===================]   |
+-----------------------------------------------------------+
```

### Screenshot 3: Settings & Dark Mode Preference
*Appearance settings with persistent Dark Mode toggle and OIDC session status.*

```
+-----------------------------------------------------------+
| (<-) Settings                        [Today]   [U Profile]|
+-----------------------------------------------------------+
|    [ Heatmap ]   [ Log List ]   [ Settings (active) ]     |
|                                                           |
| +-[ Appearance ]----------------------------------------+ |
| | [*] Dark mode with saved preference         [ ON / OFF] |
| | Theme Mode: ( ) Light   (*) Dark   ( ) System           |
| +-------------------------------------------------------+ |
|                                                           |
| +-[ Account Profile ]-----------------------------------+ |
| | User: demouser (demo@example.com)                     | |
| | [v] OIDC Session Active & Persisted in Secure Storage  | |
| +-------------------------------------------------------+ |
|                                                           |
| [=================== Sign Out ========================]   |
+-----------------------------------------------------------+
```

---

## 8. Demo Video Link

- **Video Demonstration Link**: [https://youtu.be/placeholder-demo-video](https://youtu.be/placeholder-demo-video)
*(Placeholder link — will be updated with the recorded 5-minute video presentation covering fresh setup, OIDC login, workout CRUD, heatmap body rendering, and imbalance alerts per the course grading rubric).*
