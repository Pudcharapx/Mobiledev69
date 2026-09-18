# DormMate

DormMate is an enterprise-grade mobile application designed for dormitory and student residence management. It centralizes essential residential services into a unified digital experience, including utility billing with PromptPay QR generation, maintenance ticket tracking, parcel delivery notifications, amenity scheduling, and official administrative announcements.

The application is engineered strictly around the Model-View-ViewModel (MVVM) architecture with the Repository pattern and Service layer separation, ensuring strict decoupling, dependency injection via constructors, and comprehensive automated testability.

---

## Table of Contents

- [1. Executive Summary](#1-executive-summary)
- [2. System Architecture](#2-system-architecture)
- [3. Core Functional Modules](#3-core-functional-modules)
- [4. Technology Stack](#4-technology-stack)
- [5. System Requirements](#5-system-requirements)
- [6. Installation and Setup Guide](#6-installation-and-setup-guide)
- [7. Demonstration Credentials](#7-demonstration-credentials)
- [8. REST API Specification](#8-rest-api-specification)
- [9. Automated Testing and Quality Assurance](#9-automated-testing-and-quality-assurance)
- [10. Directory Structure](#10-directory-structure)
- [11. License and Attributions](#11-license-and-attributions)

---

## 1. Executive Summary

Dormitory residents frequently encounter fragmented communication channels, manual paper billing for utilities, and opaque maintenance request workflows. DormMate addresses these operational inefficiencies by providing:

- Real-time room occupancy and contract status visibility.
- Itemized utility tracking (electricity, water, internet, and facility surcharges) with automated PromptPay QR generation.
- Full lifecycle maintenance ticketing (submission, status progression, and cancellation).
- Administrative announcement distribution with category filtering and read state management.
- Shared facility and laundry machine availability tracking.
- Secure package delivery tracking with access PIN codes.
- OpenID Connect (OIDC) authentication with Authorization Code Flow and PKCE.
- Modern iOS-inspired glassmorphism user interface with dynamic theme presets and system-wide dark mode support.

---

## 2. System Architecture

DormMate implements a decoupled four-tier architecture designed for maintainability, predictable state progression, and complete isolation of concerns.

```
+-------------------------------------------------------------------------+
|                               VIEW LAYER                                |
|  Screens, Dialogs, Sheets, Reusable Glass Containers, Navigation Shell |
+-------------------------------------------------------------------------+
                                    |
                                    v (User Actions / State Listeners)
+-------------------------------------------------------------------------+
|                            VIEWMODEL LAYER                              |
|  ChangeNotifier implementations managing reactive UI state and business |
|  validation. ViewModels never import network or storage primitives.    |
+-------------------------------------------------------------------------+
                                    |
                                    v (Constructor Injection)
+-------------------------------------------------------------------------+
|                           REPOSITORY LAYER                              |
|  Abstract contracts and concrete implementations mediating data between |
|  remote APIs, local caches, and domain entity models.                   |
+-------------------------------------------------------------------------+
                                    |
                                    v (Constructor Injection)
+-------------------------------------------------------------------------+
|                            SERVICE LAYER                                |
|  Stateless network clients (Dio), secure keystore managers, and OIDC    |
|  protocol orchestrators (PKCE, token refreshing).                       |
+-------------------------------------------------------------------------+
```

### Architectural Principles

1. **Model-View-ViewModel (MVVM)**: Views observe ViewModels through the `provider` package (`ChangeNotifierProvider` and `ListenableBuilder`). Business rules and state mutations reside exclusively within ViewModels.
2. **Repository Pattern**: ViewModels interact only with repository interfaces (`RoomRepository`, `ExpenseRepository`, `MaintenanceRepository`, etc.). This enables seamless swapping between production implementations and test doubles (`FakeRepository`).
3. **Constructor-Based Dependency Injection**: Concrete service and repository instances are instantiated during application bootstrapping (`main.dart`) and injected downward via constructor parameters. Service locators and global mutable singletons are avoided.
4. **State Machine Predictability**: ViewModels expose clear state indicators (`isLoading`, `errorMessage`, `isEmpty`) to render appropriate deterministic UI states (skeletons, empty states, retry views).

---

## 3. Core Functional Modules

### 3.1 Authentication and Session Security
- **OpenID Connect (OIDC)**: Standards-compliant Authorization Code Flow with Proof Key for Code Exchange (PKCE) against a Django OIDC identity provider.
- **Token Persistence**: Access and refresh tokens are securely stored on-device using platform-native keystores via `flutter_secure_storage`.
- **Route Guarding**: Declarative redirection rules configured within `go_router` prevent unauthenticated access to protected residential views.

### 3.2 Resident Dashboard (Home)
- **Room Information**: Displays room number, building, floor, room type, and occupancy state.
- **Financial Status at a Glance**: Displays current billing cycle balance, due date, and payment status.
- **Quick Actions**: Direct navigation shortcuts for logging maintenance issues, paying bills, checking laundry availability, and viewing parcel lockers.
- **Notice Board Feed**: Highlights priority bulletins published by dormitory administration.

### 3.3 Utility Billing and PromptPay Payment
- **Itemized Breakdown**: Displays granular consumption records for electricity, water, internet, and recurring room rent.
- **PromptPay QR Integration**: Generates EMVCo-compliant PromptPay QR payloads for instant peer-to-merchant domestic payments.
- **Transaction History**: Retains past billing statements with status indicators (`Paid`, `Unpaid`).

### 3.4 Maintenance Ticket Management (CRUD)
- **Ticket Submission**: Form validation for issue title, category selection (Electrical, Plumbing, Air Conditioning, Furniture, Internet, Bathroom, General Cleaning), description, and urgency.
- **Status Progression**: Tracks ticket lifecycle states from `Pending` to `In Progress`, `Completed`, or `Cancelled`.
- **Cancellation**: Allows residents to cancel pending requests directly from the ticket detail screen.

### 3.5 Administrative Announcements
- **Search and Categorization**: Real-time client-side search across announcement headers and contents, with category chips.
- **Read State Tracking**: Unread badge indicators and one-tap "Mark all as read" capability.

### 3.6 Facility and Laundry Monitoring
- **Appliance State Simulation**: Real-time operational status for washing machines and dryers (`Available`, `In Use`, `Maintenance`).
- **Remaining Cycle Timers**: Displays remaining cycle durations for active appliances.
- **Facility Availability**: Operational schedules for shared study rooms and fitness areas.

### 3.7 Parcel Locker Tracking
- **Delivery Ingestion**: Tracks arriving packages categorized by carrier and arrival timestamp.
- **Pickup Verification**: Displays secure locker box numbers and one-time retrieval PIN codes.

### 3.8 Personalization and Theme System
- **Dynamic Glassmorphism**: Translucent frosted surfaces with customizable background mesh gradients.
- **Theme Presets**: Multiple curated visual schemes (Classic Navy, Emerald Oasis, Royal Violet, Rose Quartz, Dark Slate).
- **Mode Toggle**: Full support for Light, Dark, and System appearance modes with persistent local preferences.

---

## 4. Technology Stack

### Client (Mobile and Web)
- **Language**: Dart (v3.8 or newer)
- **Framework**: Flutter (v3.24 or newer)
- **State Management**: `provider` (^6.1.2)
- **Declarative Routing**: `go_router` (^14.8.1)
- **HTTP Client**: `dio` (^5.8.0)
- **Identity Protocol**: `openid_client` (^0.4.10)
- **Encrypted Storage**: `flutter_secure_storage` (^9.2.4)
- **Vector Assets**: `flutter_svg` (^2.0.17)
- **Localization and Formatting**: `intl` (^0.20.2)

### Server (Backend)
- **Runtime**: Python (v3.12 or newer)
- **Package Manager**: `uv` (Fast Python package resolver and virtual environment manager)
- **Web Framework**: Django 5.x
- **API Engine**: Django REST Framework (DRF)
- **Identity Server**: `django-oidc-provider` (OAuth 2.0 / OIDC Authorization Code Flow with PKCE, RS256 cryptographic signing)
- **Relational Database**: SQLite (Default development instance)

---

## 5. System Requirements

Before setting up the environment, verify that the following dependencies are installed on your workstation:

1. **Git**: Distributed version control ([Download Git](https://git-scm.com/downloads))
2. **Flutter SDK**: Version 3.24.0 or higher ([Install Flutter](https://docs.flutter.dev/get-started/install))
3. **Python**: Version 3.12 or higher ([Install Python](https://www.python.org/downloads/))
4. **uv**: High-performance Python package installer ([Install uv](https://docs.astral.sh/uv/getting-started/installation/))
   - Windows (PowerShell):
     ```powershell
     powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
     ```
   - macOS / Linux:
     ```bash
     curl -LsSf https://astral.sh/uv/install.sh | sh
     ```
5. **Google Chrome**: Recommended target browser for Web client execution ([Download Chrome](https://www.google.com/chrome/))

---

## 6. Installation and Setup Guide

Execute the following commands from clean shell sessions.

### Step 1: Repository Clone

```bash
git clone https://github.com/Pudcharapx/Mobiledev69.git
cd Mobiledev69
git checkout project
```

### Step 2: Backend Setup and Database Initialization (Terminal 1)

Navigate to the `backend/` directory, install virtual environment dependencies, apply migrations, seed initial data, and launch the development server:

```bash
cd backend

# Synchronize Python dependencies
uv sync

# Execute database migrations
uv run python manage.py migrate

# Initialize OIDC RSA keys and client registration
uv run python manage.py bootstrap_oidc

# Seed default DormMate rooms, residents, bills, and announcements
uv run python manage.py bootstrap_dormmate

# Start the Django REST API server on port 8000
uv run python manage.py runserver 8000
```

The Django server will accept incoming HTTP requests at `http://127.0.0.1:8000/`.

### Step 3: Frontend Client Execution (Terminal 2)

From the project root directory (`Mobiledev69`), resolve Flutter dependencies and run the application:

```bash
# Retrieve Flutter package dependencies
flutter pub get

# Launch Flutter Web in Google Chrome on port 50000
flutter run -d chrome --web-port=50000
```

*Note: Port `50000` corresponds to the pre-authorized redirect URI registered in the OIDC client configuration (`http://localhost:50000/callback`).*

To target a desktop or mobile emulator instead:

```bash
# List available platforms and emulators
flutter devices

# Run on selected device target (e.g. Windows desktop)
flutter run -d windows
```

---

## 7. Demonstration Credentials

The database bootstrapping command (`bootstrap_dormmate` and `bootstrap_oidc`) creates pre-seeded accounts configured with corresponding residential profiles:

| Role | Username | Password | Email | Assigned Room | Room Type |
|---|---|---|---|---|---|
| Primary Resident | `demouser` | `demo12345` | `demo@example.com` | Room A-101 | Single |
| Secondary Resident | `test` | `1234` | `test@example.com` | Room B-204 | Twin |

---

## 8. REST API Specification

All endpoints are hosted under `/api/dormmate/` and expect JSON payloads.

| HTTP Method | Endpoint Path | Description | Access Control |
|---|---|---|---|
| `POST` | `/api/dormmate/auth/login/` | Direct token authentication fallback | Public |
| `GET` | `/api/dormmate/profile/` | Retrieve current resident personal details | Authenticated |
| `GET` | `/api/dormmate/rooms/me/` | Retrieve resident room information and roommates | Authenticated |
| `GET` | `/api/dormmate/expenses/` | List all utility and room billing records | Authenticated |
| `GET` | `/api/dormmate/expenses/<id>/` | Retrieve granular itemized billing record | Authenticated |
| `GET` | `/api/dormmate/maintenance/` | List resident maintenance tickets | Authenticated |
| `POST` | `/api/dormmate/maintenance/` | Submit a new maintenance ticket | Authenticated |
| `GET` | `/api/dormmate/maintenance/<id>/` | Retrieve maintenance ticket detail | Authenticated |
| `DELETE` | `/api/dormmate/maintenance/<id>/` | Cancel a pending maintenance ticket | Authenticated |
| `GET` | `/api/dormmate/announcements/` | Retrieve all administrative announcements | Authenticated |
| `GET` | `/api/dormmate/announcements/<id>/` | Retrieve announcement details | Authenticated |
| `GET` | `/api/dormmate/dashboard/` | Aggregated payload for the Home screen | Authenticated |

---

## 9. Automated Testing and Quality Assurance

The codebase maintains strict verification coverage across both frontend and backend layers.

### Frontend Test Suite (Flutter)

The Flutter test suite encompasses unit tests for business models, fake repository state tests for ViewModels, and widget rendering verification for UI screens:

```bash
# Run all automated Flutter unit and widget tests
flutter test

# Run static analysis and lint rule enforcement
flutter analyze
```

Expected output:
- **114 automated tests passed** with zero failures.
- Static analyzer reports **0 issues**.

### Backend Test Suite (Django)

```bash
cd backend
uv run python manage.py test
```

---

## 10. Directory Structure

```
Mobiledev69/
├── backend/
│   ├── config/                     # Django core settings, URL routing, WSGI/ASGI
│   │   ├── settings.py
│   │   └── urls.py
│   ├── dormmate/                   # DormMate REST API application
│   │   ├── management/commands/    # Data bootstrap commands (bootstrap_dormmate)
│   │   ├── migrations/             # Database schema migrations
│   │   ├── models.py               # Room, Resident, Expense, Maintenance, Announcement
│   │   ├── serializers.py          # DRF model serializers
│   │   ├── urls.py                 # Endpoint routing rules
│   │   └── views.py                # Class-based API view controllers
│   ├── manage.py                   # Django CLI executable
│   └── pyproject.toml              # uv Python environment and dependencies
├── lib/
│   ├── core/                       # Cross-cutting concerns
│   │   ├── constants/              # Dimension, color, and string constants
│   │   ├── routing/                # GoRouter declarative configuration
│   │   ├── services/               # Shared device utilities
│   │   ├── theme/                  # Theme presets, glassmorphism specs, ThemeService
│   │   └── widgets/                # Reusable glass cards, mesh backgrounds, navbars
│   ├── models/                     # Immutable domain data transfer objects (DTOs)
│   ├── repositories/               # Repository interfaces and concrete implementations
│   ├── services/                   # Stateless network and storage services
│   ├── viewmodels/                 # ChangeNotifier MVVM controllers
│   ├── views/                      # UI screens partitioned by domain feature
│   │   ├── announcements/          # Announcement list, details, search
│   │   ├── auth/                   # OIDC Login interface
│   │   ├── expenses/               # Utility breakdowns and PromptPay QR sheets
│   │   ├── facility/               # Laundry and shared amenity monitors
│   │   ├── home/                   # Resident dashboard
│   │   ├── maintenance/            # Ticket CRUD, forms, timeline status
│   │   ├── parcels/                # Package arrival and locker PINs
│   │   └── profile/                # Profile management and theme picker
│   └── main.dart                   # Application entrypoint and dependency injection graph
├── test/
│   ├── core/                       # Theme and core widget unit tests
│   ├── fake_repositories/          # In-memory test doubles for ViewModel testing
│   ├── viewmodels/                 # ViewModel business logic and state tests
│   ├── views/                      # Widget tests validating screen behavior
│   └── dormmate_app_smoke_test.dart# End-to-end routing and provider smoke tests
├── web/                            # Web platform bootstrapping, manifest, index.html
├── pubspec.yaml                    # Flutter dependencies and asset registrations
├── DormMate_SRS.md                 # Complete Software Requirements Specification
└── README.md                       # Project technical documentation
```

---

## 11. License and Attributions

This project is developed for academic and demonstration purposes as part of the Mobile Application Development curriculum. All rights reserved.
