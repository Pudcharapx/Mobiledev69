# Software Requirements Specification (SRS)
## Muscle Heatmap Workout Tracker

**Document Version:** 1.0
**Status:** Draft for Course Project — Mobile Development (Week 16)

---

## 1. Project Overview

### 1.1 Description
A mobile workout tracking app that visualizes weekly training data as a **Muscle Heatmap** — a body diagram that colors each muscle group based on how much it has been trained this week (red = under-trained, green = target met), combined with a Muscle Imbalance Alert system.

### 1.2 Problem Statement
Most people who exercise regularly don't have a clear picture of which muscle groups they've trained more or less in a given week. This leads to imbalance (e.g., overtraining chest while neglecting back), which increases injury risk and causes uneven progress. This app makes that picture instantly visible through a visual body map instead of plain numbers or bar charts.

### 1.3 Target Users
People who do regular weight/resistance training and want to track which muscle groups they've trained each week.

### 1.4 Value Proposition / Differentiation
- General fitness apps (Strong, Hevy, MyFitnessPal) display data as numbers or bar charts — none show an instantly readable, color-coded body visualization.
- This app focuses on **muscle balance** (imbalance detection), a dimension most existing apps don't highlight as a core feature.

---

## 2. Scope

The system is a **single-user** app — each user only sees and manages their own data. Multi-user data sharing is out of scope.

### In Scope
- CRUD of workout data for the logged-in user
- Authentication via OIDC
- Calculation and display of the Muscle Heatmap from the user's own data
- Imbalance alerts between opposing muscle group pairs

### Out of Scope (Future Work)
- AI-based exercise recommendations to correct imbalance
- Wearable device integration
- Social features / sharing progress with other users
- Aggregated market-wide statistics from multiple users

---

## 3. System Architecture

### 3.1 Architecture Pattern
MVVM (Model-View-ViewModel), as required by the course.

```
View (UI) ⇄ ViewModel (State + Logic) ⇄ Repository (SSOT) ⇄ Service (ApiClient, SecureStorage, OIDC)
```

- View never talks to Service directly
- Dependency Injection via `provider`
- Errors handled with the Result Pattern in the Data Layer

### 3.2 Authentication
- Authorization Code Flow + PKCE against an OIDC Server (Django + django-oidc-provider)
- Tokens stored with `flutter_secure_storage`
- Route Guard protects every content screen via `go_router`
- Session persists after closing and reopening the app
- Logout button clears session/token completely

### 3.3 Folder Structure (Flutter)
```
lib/
├── app.dart
├── main.dart
├── core/
│   ├── api/         # ApiClient (dio)
│   ├── auth/         # OIDC client, token store
│   └── theme/        # theme, dark mode
├── features/
│   ├── workout/
│   │   ├── data/           # WorkoutRepository, DTOs
│   │   ├── domain/         # WorkoutLog model
│   │   ├── presentation/   # ViewModel, LogScreen, LogForm
│   │   └── router/
│   └── heatmap/
│       ├── data/            # ExerciseRepository (loads seed exercises)
│       ├── domain/          # MuscleVolumeCalculator
│       └── presentation/    # HeatmapScreen, BodySvgWidget
```

### 3.4 Backend
- Django + django-oidc-provider
- Models: `Exercise`, `WorkoutLog`, `WeeklyGoal`
- Seed fixture loads baseline exercises on `migrate`

---

## 4. Data Model

### 4.1 Exercise (seed data — pre-loaded, not entered by users)
| Field | Type | Description |
|---|---|---|
| id | int | primary key |
| name | string | Exercise name, e.g. "Bench Press" |
| primary_muscle | string | Main muscle trained, e.g. "chest" |
| secondary_muscles | list[string] | Secondary muscles, e.g. ["shoulders", "triceps"] |
| contribution_weight | JSON | Weighting per muscle group, e.g. {"chest": 1.0, "shoulders": 0.5, "triceps": 0.5} |

*Source: muscle mapping based on publicly available general fitness references (e.g. ExRx.net) — cite this source in the README*

### 4.2 WorkoutLog (entered by the user)
| Field | Type | Description |
|---|---|---|
| id | int | primary key |
| user_id | FK | Owner of the log |
| exercise_id | FK | Exercise selected from dropdown |
| date | date | Date of the workout |
| sets | int | Number of sets |
| reps | int | Reps per set |
| weight_kg | float | Weight used (optional, for bodyweight exercises) |
| note | string | Optional note |

### 4.3 WeeklyGoal (set by the user, optional)
| Field | Type | Description |
|---|---|---|
| id | int | primary key |
| user_id | FK | Owner of the goal |
| muscle_group | string | Muscle group |
| target_sets_per_week | int | Target sets per week |

---

## 5. User Input Requirements

To keep the app as easy to use as possible, the user only needs to enter **3 main things** per log entry — everything related to heatmap calculation is handled automatically:

1. **Select an exercise** — from a dropdown/search (no free typing, reduces errors)
2. **Sets + reps** — via a stepper (+/-) instead of typing numbers, for speed on mobile
3. **Weight used (if any)** — numeric keypad, pre-filled with the last value used for that exercise (reduces repetitive entry)

The user does **not** need to specify which muscles an exercise affects — the system pulls this automatically from the pre-seeded `Exercise.contribution_weight`.

### Usability Guidelines
- **Quick-add**: a "repeat last entry" button for recently logged exercises
- **Favorite exercises**: pin frequently-used exercises to the top of the dropdown
- **Smart defaults**: the form pre-fills sets/reps/weight from the last log of that exercise — the user just confirms or makes small adjustments
- **3-tap logging**: select exercise → adjust numbers with the stepper → tap Save

---

## 6. Seed Data — Exercise List

Pre-loaded in the system via a Django fixture on `migrate`; users select from a dropdown without entering this data themselves. 18 baseline exercises covering all major muscle groups, each with a `contribution_weight` (primary = 1.0, secondary = 0.5) based on general publicly available fitness references (e.g. ExRx.net) — cite this source in the README.

| # | Exercise | Primary Muscle | Secondary Muscles |
|---|---|---|---|
| 1 | Bench Press | chest | shoulders, triceps |
| 2 | Incline Dumbbell Press | chest | shoulders, triceps |
| 3 | Push-up | chest | shoulders, triceps, core |
| 4 | Pull-up | back | biceps, shoulders |
| 5 | Lat Pulldown | back | biceps |
| 6 | Barbell Row | back | biceps, shoulders |
| 7 | Deadlift | back | glutes, hamstrings, core |
| 8 | Overhead Press | shoulders | triceps, chest |
| 9 | Lateral Raise | shoulders | — |
| 10 | Face Pull | shoulders | back |
| 11 | Barbell Squat | legs | glutes, core |
| 12 | Leg Press | legs | glutes |
| 13 | Romanian Deadlift | hamstrings | glutes, back |
| 14 | Lunge | legs | glutes |
| 15 | Bicep Curl | biceps | — |
| 16 | Triceps Pushdown | triceps | — |
| 17 | Plank | core | shoulders |
| 18 | Hanging Leg Raise | core | — |

**Example `contribution_weight` (JSON) for Bench Press:**
```json
{ "chest": 1.0, "shoulders": 0.5, "triceps": 0.5 }
```

**Muscle groups used in the system:**
`chest`, `back`, `shoulders`, `biceps`, `triceps`, `legs`, `hamstrings`, `glutes`, `core`

**Opposing muscle group pairs (for Imbalance Alert):**
| Group A | Group B |
|---|---|
| chest | back |
| legs (quads) | hamstrings |
| biceps | triceps |

---

## 7. Core Features

| # | Feature | Description |
|---|---|---|
| 1 | Authentication | Full Login/Logout flow via OIDC |
| 2 | Create | Add a new WorkoutLog through an easy-to-fill form |
| 3 | Read | List all logs (sorted by date) + daily detail view |
| 4 | Update | Edit a log entered incorrectly |
| 5 | Delete | Delete a log |
| 6 | Error Handling | Friendly error messages (SnackBar/Dialog) when the network drops or the API fails |

---

## 8. Extra Features

### 8.1 Muscle Heatmap (main selling point)
- Displays a human body (front + back view) via SVG, divided into muscle zones
- Calculates volume per muscle group from this week's logs:
  ```
  volume(muscle group X) = Σ (sets × reps × contribution_weight[X])
                            for every log that affects muscle group X this week
  ```
- Normalizes against `WeeklyGoal` → converts to a percentage → maps to a color (red → yellow → green)
- Tapping a muscle zone opens a popup showing the logs that contributed to it

### 8.2 Imbalance Alert
- Compares volume between opposing muscle group pairs (e.g. chest vs back, quads vs hamstrings)
- If the difference exceeds a set threshold (e.g. 40%) → shows an alert, e.g. "Your back is undertrained compared to your chest — consider adding more back work"
- Simple numeric-comparison logic, no AI/ML involved

### 8.3 Additional Extra Features (choose at least 1)
- Dark Mode with saved preference
- Search/filter logs by muscle group or date range
- Calendar view summarizing workout days (streak)
- Progress chart of weight lifted per exercise over time

---

## 9. UI/UX Design Direction

### 9.1 Design Principles
- **Visual-first**: the Heatmap screen is the home screen shown immediately on open, not buried in a menu
- **Clear color meaning**: uses a red-yellow-green gradient with sufficient contrast for readability (also considers colorblind users by labeling each zone with a percentage, not relying on color alone)
- **Micro-interactions**: tapping a muscle zone triggers a subtle scale/bounce animation before showing the detail popup, adding a responsive feel
- **Fast-entry forms**: steppers/sliders instead of typed numbers to reduce friction on mobile
- **Dark mode friendly**: heatmap colors must remain readable in both light and dark themes

### 9.2 Visual Style Reference

Design direction inspired by a card-based, pastel-toned fitness app aesthetic — clean and easy to read:

- **Background tone**: mostly white/light gray, with contrasting pastel cards (light purple, mint/light green, light orange) separating data categories — in this app, replaced with heatmap colors (red-yellow-green) as the primary accent
- **Large rounded cards**: every section is wrapped in a card with rounded corners and generous padding
- **Typography**: bold, large headings; key numbers (heatmap percentages, set counts) shown in large, prominent type
- **Simple progress bars**: thin bars with percentage labels — applied to the volume proportion per muscle group
- **Minimal bar charts**: no heavy borders — applied to the weight-lifted progress chart per exercise
- **Clean top navigation**: circular back button on the left, calendar icon + round profile photo on the right, consistent across all screens
- **Pill/segmented control tab bar**: rounded capsule tab switcher, selected tab shown as black background with white text — used to switch between "Heatmap / Log List / Settings"
- **Dark feature card**: a dark-background card highlighting the most important info on the screen, with a prominent action button — used here for the Imbalance Alert summary or weekly goal card
- **Circular progress ring**: shows a number in the center — used for overall body balance percentage on the Heatmap Home screen

**Applying this to the Heatmap:** keep the same card/typography/navigation structure, but repurpose color to represent training intensity level (red-yellow-green) so heatmap data communicates clearly without losing the polish of the reference design.

### 9.3 Main Screens
1. **Login** — OIDC sign-in screen
2. **Heatmap Home** — front/back body view with this week's colors + Imbalance Alert summary at the top
3. **Log List** — all workout logs, with search/filter
4. **Log Form** — add/edit log (exercise picker, sets/reps stepper, numeric weight)
5. **Exercise Detail (popup)** — tapping a muscle zone shows related logs
6. **Settings** — set weekly goals (WeeklyGoal), dark mode toggle, logout

---

## 10. Success Criteria (Grading Rubric Alignment)

| Category | Weight |
|---|---|
| Repository & Branch (`project`) | 10 |
| README.md (all 8 sections) | 10 |
| Zero-Error Setup (runs from README as-is) | 20 |
| OIDC Authentication | 20 |
| Main Functions (CRUD) | 15 |
| Extra Features (Heatmap + Imbalance Alert) | 10 |
| Code Quality & Architecture (MVVM) | 10 |
| Video Presentation Quality | 5 |
| **Total** | **100** |

---

## 11. Risks and Mitigation

| Risk | Mitigation |
|---|---|
| Finding/adapting an SVG body diagram split into zones matching muscle_group takes time | Start this task first, before other features |
| Incomplete seed data makes the demo look sparse | Prepare all 15-20 baseline exercises before UI testing begins |
| `--web-port` mismatched with `redirect_uris` in the OIDC client | Verify all 3 locations match before recording: OIDC client config, Flutter redirectUri, and the README command |
| Demo video shows errors during setup | Test a fresh clone in an empty folder before the actual recording |

---

## 12. Future Work (Out of Scope for This Project)
- AI system that automatically recommends exercises to correct imbalance
- Integration with wearable device data (smartwatch)
- Social features — sharing progress or comparing with friends
- Aggregating statistics across multiple users to show market-wide trends/behavior
