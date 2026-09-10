
# Implementation Task List
## Muscle Heatmap Workout Tracker — derived from SRS.md

Feed these tasks to your coding agent (e.g. Antigravity CLI) **one at a time, in order**.
Before each task, attach/reference the full `SRS.md` file so the agent has ground truth.
After each task, review the diff before moving to the next one — don't run everything unattended.

---

### Task 0 — Setup
```
Read SRS.md fully before doing anything. Confirm back to me in plain text which
sections you understood for: architecture pattern, folder structure, and tech stack,
before writing any code.
```
Goal: force the agent to prove it ingested the spec, not just skimmed a summary.

---

### Task 1 — Repo & Branch
```
Create a git branch named exactly `project` (all lowercase). Do not touch `main`.
Set up the base folder structure exactly as described in SRS.md section 3.3
(lib/core, lib/features/workout, lib/features/heatmap) as empty folders with
placeholder .gitkeep files if needed. Do not generate any business logic yet.
```

---

### Task 2 — Backend: Django project + OIDC
```
Set up a Django backend in /backend using django-oidc-provider, per SRS.md
section 3.2 and 3.4. Configure:
- OIDC client as public (PKCE)
- redirect_uris = ["http://localhost:50000/callback"]
Do not implement any app-specific models yet — this task is only the
authentication server setup. Use uv for dependency management.
```

---

### Task 3 — Backend: Data Models
```
Implement exactly these Django models, matching SRS.md section 4 field-by-field
(no extra fields, no renamed fields):

- Exercise (SRS 4.1): id, name, primary_muscle, secondary_muscles (list/JSON),
  contribution_weight (JSON)
- WorkoutLog (SRS 4.2): id, user_id (FK), exercise_id (FK), date, sets, reps,
  weight_kg (nullable), note (nullable)
- WeeklyGoal (SRS 4.3): id, user_id (FK), muscle_group, target_sets_per_week

Do not add authentication logic in this task — models only.
```

---

### Task 4 — Backend: Seed Data
```
Create a Django fixture that loads exactly the 18 exercises listed in SRS.md
section 6, with the exact primary_muscle, secondary_muscles, and
contribution_weight values shown in that table. This fixture must load
automatically on `migrate`, as described in the risk mitigation table
(SRS.md section 11).
```

---

### Task 5 — Backend: REST API
```
Expose REST endpoints for Exercise (read-only) and WorkoutLog (full CRUD),
scoped to the authenticated user only — a user must never see another user's
WorkoutLog data. Do not implement WeeklyGoal endpoints yet.
```

---

### Task 6 — Flutter: Core layer
```
Implement lib/core/ exactly as described in SRS.md section 3.3:
- core/api: ApiClient using dio
- core/auth: OIDC client using openid_client, token storage using
  flutter_secure_storage
- core/theme: light/dark theme definitions

Do not build any screens yet. This task is infrastructure only.
```

---

### Task 7 — Flutter: Authentication flow
```
Implement OIDC Authorization Code Flow + PKCE login/logout exactly as described
in SRS.md section 3.2:
- Login screen redirects to OIDC server
- Successful login stores token securely
- Route guard (go_router) blocks all content screens for unauthenticated users
- Logout clears session/token completely
- Session must persist across app restarts

Do not build the workout logging feature yet.
```

---

### Task 8 — Flutter: Workout CRUD (MVVM)
```
Implement the `workout` feature exactly following the MVVM layering in
SRS.md section 3.1 and 3.3:
- domain: WorkoutLog model
- data: WorkoutRepository (calls the API from Task 5)
- presentation: ViewModel + LogScreen (list) + LogForm (create/edit)

Follow SRS.md section 5 for the input UX specifically:
- Exercise selection via dropdown/search (no free text)
- Sets/reps via stepper, not a text field
- Weight via numeric keypad, pre-filled with the last logged value for
  that exercise

Views must not call Service classes directly — only through ViewModel →
Repository, per the architecture rule in SRS.md section 3.1.

Implement error handling per SRS.md section 7, item 6: friendly SnackBar/dialog
on network or API failure.
```

---

### Task 9 — Flutter: Muscle Heatmap
```
Implement the `heatmap` feature per SRS.md section 8.1:
- Use flutter_svg to render a front+back body view divided into muscle zones
  matching the muscle_group list in SRS.md section 6
  (chest, back, shoulders, biceps, triceps, legs, hamstrings, glutes, core)
- Implement MuscleVolumeCalculator using exactly this formula from SRS.md 8.1:
  volume(muscle group X) = Σ (sets × reps × contribution_weight[X])
  over this week's WorkoutLog entries
- Normalize against WeeklyGoal, map to a red→yellow→green color scale
- Tapping a zone shows a popup with the contributing logs

Do not implement Imbalance Alert in this task — heatmap only.
```

---

### Task 10 — Flutter: Imbalance Alert
```
Implement Imbalance Alert per SRS.md section 8.2, using exactly these
opposing muscle pairs from SRS.md section 6:
- chest vs back
- legs (quads) vs hamstrings
- biceps vs triceps

If the volume difference between a pair exceeds 40%, show an alert message
in the style described in SRS.md section 8.2. Use simple numeric comparison —
no AI/ML.
```

---

### Task 11 — Flutter: UI styling pass
```
Apply the visual style described in SRS.md section 9.2 (Visual Style Reference)
across all existing screens:
- Large rounded cards, generous padding
- Bold large typography for key numbers
- Pill/segmented tab bar for switching Heatmap / Log List / Settings
- Circular back button + calendar/profile icons in top navigation
- Dark feature card for the Imbalance Alert summary
- Circular progress ring for overall balance percentage on Heatmap Home

Do not change any business logic in this task — visual/styling only.
```

---

### Task 12 — Flutter: Extra feature (pick 1 from SRS 8.3)
```
Implement ONE of the following from SRS.md section 8.3 — confirm with me
which one before starting:
- Dark Mode with saved preference
- Search/filter logs by muscle group or date range
- Calendar view of workout days (streak)
- Progress chart of weight lifted per exercise over time (using fl_chart)
```

---

### Task 13 — README.md
```
Write README.md with exactly these 8 sections, per the course spec:
1. Project name + description
2. Features (must match what's actually implemented — no extra claims)
3. Tech Stack
4. Prerequisites (with install links)
5. How to Run (line-by-line terminal commands, tested from a fresh clone)
6. Demo Account (a working OIDC test user)
7. Screenshots (at least 2)
8. Demo Video link (placeholder until video is recorded)

Do not proceed until you've actually run these commands yourself from an
empty folder to confirm they work with zero errors.
```

---

## Notes for using this list
- Do NOT feed all tasks at once — the whole point is controlling scope per step.
- After each task, ask the agent to summarize what it changed and diff it
  against the relevant SRS.md section before accepting.
- If the agent deviates from a field name, package choice, or folder path
  listed in SRS.md, correct it immediately in that same task — don't let it
  carry forward into later tasks.
- Task 13 (README) should only start after Tasks 1–12 are verified working,
  since the "Zero-Error Setup" video (worth 20 points) depends on the README
  matching a working, already-tested app exactly.
