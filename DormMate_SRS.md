# DormMate --- Software Requirements Specification (SRS)

> **Project Type:** Flutter Mobile Application\
> **Application:** DormMate --- Dormitory Management App\
> **Architecture:** MVVM + Repository + Service\
> **Authentication:** OIDC Authorization Code Flow\
> **Backend:** Existing backend infrastructure adapted from the previous
> fitness application\
> **UI Direction:** Minimal / Modern / Premium / iOS-inspired
> Glassmorphism\
> **Document Version:** 1.0

------------------------------------------------------------------------

## 1. Overview

### 1.1 Project Name

**DormMate**

### 1.2 Project Concept

DormMate is a mobile application designed to help students and dormitory
residents manage everyday dormitory information in one place.

The application focuses on:

-   Viewing room and resident information
-   Checking monthly dormitory expenses
-   Tracking electricity, water, and internet charges
-   Reporting maintenance problems
-   Tracking maintenance request status
-   Receiving dormitory announcements
-   Viewing historical records
-   Managing personal account information

The project is designed specifically to demonstrate a clean **MVVM
architecture** with clear separation between View, ViewModel,
Repository, and Service layers.

### 1.3 Project Objectives

1.  Create a practical mobile application for dormitory residents.
2.  Provide a centralized place for dormitory-related information.
3.  Demonstrate Flutter MVVM architecture in a real application.
4.  Demonstrate Repository and Service separation.
5.  Use dependency injection through constructors.
6.  Connect the mobile application to a backend/API.
7.  Demonstrate authentication and protected user data.
8.  Demonstrate application state changes such as creating, updating,
    and deleting records.
9.  Make the ViewModel independently testable using a fake repository.
10. Provide a premium, minimal, iOS-inspired user experience.

------------------------------------------------------------------------

# 2. Scope

## 2.1 In Scope

### Authentication

-   Login through OIDC.
-   Logout.
-   Display authenticated user's name.
-   Maintain authenticated application state.
-   Protect private application data.

### Dashboard

-   Display current room information.
-   Display current month expense summary.
-   Display maintenance request summary.
-   Display latest announcements.
-   Display important status indicators.

### Room

-   View room number.
-   View dormitory/building information.
-   View room status.
-   View basic resident information.

### Expenses

Users can: - View monthly expense records. - View electricity charges. -
View water charges. - View internet/other charges. - View total
amount. - View payment status. - View historical expense records.

### Maintenance

Users can: - View maintenance requests. - Create a maintenance
request. - Select a problem category. - Add a description. - Add an
optional image. - View request status. - View request history. -
Delete/cancel a request when permitted.

Possible status values:

``` text
Pending
In Progress
Completed
Cancelled
```

### Announcements

Users can: - View announcements. - Open announcement details. - View
announcement date. - Mark announcements as read locally or through the
backend if supported.

### Profile

Users can: - View their profile. - View room information. - View account
information. - Logout.

------------------------------------------------------------------------

## 2.2 Out of Scope

The first version will not include:

-   Online rent payment gateway.
-   Real-time chat with dormitory staff.
-   Smart-lock hardware integration.
-   IoT electricity monitoring.
-   Automatic bank/payment reconciliation.
-   AI-based maintenance diagnosis.
-   Multi-dormitory commercial management.
-   Complex administrator analytics dashboard.

These features may be considered future extensions.

------------------------------------------------------------------------

# 3. Target Users

## 3.1 Resident

The main user of DormMate.

A resident can:

-   Authenticate.
-   View their room.
-   View expenses.
-   Report maintenance problems.
-   Track maintenance status.
-   Read announcements.
-   View their profile.

## 3.2 Administrator / Dormitory Staff

The backend may support an administrator role.

Administrators may eventually:

-   Manage rooms.
-   Manage residents.
-   Create announcements.
-   Manage expense records.
-   Update maintenance request status.

> The first mobile prototype primarily focuses on the resident
> experience. Administrator functionality may be implemented through the
> existing backend or a future admin interface.

------------------------------------------------------------------------

# 4. System Architecture

DormMate will follow the architecture required by the course:

``` text
┌─────────────────────────────┐
│            View             │
│     Flutter UI / Screens    │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│         ViewModel           │
│ Business Logic / UI State   │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│         Repository          │
│ Data Access / Data Mapping  │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│          Service            │
│       Stateless API Client  │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│       Backend REST API      │
│       Database / OIDC       │
└─────────────────────────────┘
```

## 4.1 View

The View is responsible only for displaying UI and receiving user
interactions.

The View:

-   Knows its own ViewModel.
-   Displays ViewModel state.
-   Sends user actions to the ViewModel.
-   Does not directly call the API.
-   Does not contain business/data-access logic.

## 4.2 ViewModel

The ViewModel manages presentation state and application logic.

Examples:

-   `HomeViewModel`
-   `ExpenseViewModel`
-   `MaintenanceViewModel`
-   `AnnouncementViewModel`
-   `ProfileViewModel`

ViewModels receive repositories through their constructors.

Example:

``` dart
class MaintenanceViewModel extends ChangeNotifier {
  final MaintenanceRepository repository;

  MaintenanceViewModel(this.repository);

  // state and business logic
}
```

## 4.3 Repository

The Repository provides a clean interface between the ViewModel and
external data sources.

Responsibilities:

-   Fetch data.
-   Create records.
-   Update records.
-   Delete records.
-   Convert API responses into application models.
-   Hide API implementation details from the ViewModel.

Example:

``` text
MaintenanceViewModel
        ↓
MaintenanceRepository
        ↓
ApiService
```

## 4.4 Service

The Service is a stateless API client.

Responsibilities:

-   HTTP requests.
-   Authentication headers.
-   API endpoint communication.
-   JSON request/response handling.
-   Basic network error handling.

The Service does not know about the ViewModel or UI.

------------------------------------------------------------------------

# 5. Dependency Injection

Dependencies should be provided through constructors.

Example:

``` text
ApiService
    ↓
MaintenanceRepository
    ↓
MaintenanceViewModel
    ↓
MaintenanceScreen
```

This structure makes the application easier to:

-   Test.
-   Maintain.
-   Replace implementations.
-   Mock/fake data sources.
-   Separate responsibilities.

For unit testing, a `FakeMaintenanceRepository` can be injected into
`MaintenanceViewModel`.

Example:

``` dart
final fakeRepository = FakeMaintenanceRepository();
final viewModel = MaintenanceViewModel(fakeRepository);
```

The ViewModel can then be tested without opening the UI or requiring a
real internet connection.

------------------------------------------------------------------------

# 6. Functional Requirements

## FR-01 Authentication

The system shall allow users to authenticate through the configured OIDC
authentication flow.

### Acceptance Criteria

-   User can start login.
-   User is redirected/authenticated through OIDC.
-   Successful authentication returns the user to the application.
-   Application displays the authenticated user's name.
-   Unauthorized users cannot access protected resident data.

------------------------------------------------------------------------

## FR-02 Logout

The system shall allow authenticated users to log out.

### Acceptance Criteria

-   User selects Logout.
-   Authentication state is cleared.
-   User is returned to the login screen.
-   Protected screens cannot be accessed without authentication.

------------------------------------------------------------------------

## FR-03 Dashboard

The system shall display a summary of important dormitory information.

Dashboard should contain:

``` text
Good morning, [Name]

Room
B-204
Building B

This Month
฿ 1,850
Utilities + Internet

Maintenance
1 request
In Progress

Latest Announcement
Water system maintenance
```

### Acceptance Criteria

-   Dashboard loads authenticated user data.
-   Loading state is displayed while data is being fetched.
-   Error state is displayed when data cannot be loaded.
-   Data is refreshed when requested.

------------------------------------------------------------------------

## FR-04 Room Information

The system shall allow users to view their assigned room information.

Information may include:

-   Building
-   Floor
-   Room number
-   Room type
-   Occupancy/status
-   Resident information

------------------------------------------------------------------------

## FR-05 Expense List

The system shall display the user's dormitory expense records.

Each expense should contain:

-   Month
-   Electricity amount
-   Water amount
-   Internet amount
-   Other charges
-   Total amount
-   Payment status
-   Due date

Example:

``` text
September 2026

Electricity       ฿ 620
Water             ฿ 180
Internet          ฿ 300
Other             ฿ 0
──────────────────────
Total             ฿ 1,100

Status: Unpaid
Due: 30 Sep 2026
```

------------------------------------------------------------------------

## FR-06 Expense Detail

The system shall allow users to open a specific expense record.

The detail screen should show:

-   Billing period.
-   Individual charges.
-   Total.
-   Due date.
-   Payment status.

------------------------------------------------------------------------

## FR-07 Maintenance List

The system shall display all maintenance requests belonging to the
authenticated resident.

Each request should show:

-   Title/problem.
-   Category.
-   Created date.
-   Status.
-   Last updated date.

------------------------------------------------------------------------

## FR-08 Create Maintenance Request

The system shall allow residents to submit a maintenance request.

Required fields:

-   Problem title.
-   Category.
-   Description.

Optional fields:

-   Image.
-   Additional note.

Possible categories:

``` text
Electrical
Water
Air Conditioner
Furniture
Internet
Bathroom
Cleaning
Other
```

------------------------------------------------------------------------

## FR-09 Maintenance Status

The system shall display the current status of a maintenance request.

Status:

``` text
Pending
In Progress
Completed
Cancelled
```

The status should be visually represented using a small status indicator
rather than large colorful UI elements.

------------------------------------------------------------------------

## FR-10 Delete / Cancel Maintenance Request

The system shall allow an eligible maintenance request to be deleted or
cancelled.

Recommended interaction:

``` text
Swipe left
      ↓
Cancel
      ↓
Confirmation
      ↓
Repository.delete/cancel()
      ↓
ViewModel updates state
      ↓
notifyListeners()
      ↓
UI updates immediately
```

This feature is important for demonstrating state management during the
project presentation.

------------------------------------------------------------------------

## FR-11 Announcements

The system shall display dormitory announcements.

Each announcement should contain:

-   Title.
-   Short summary.
-   Full content.
-   Published date.
-   Optional image.
-   Read/unread state if supported.

------------------------------------------------------------------------

## FR-12 Profile

The system shall display:

-   User name.
-   Email.
-   Room number.
-   Building.
-   Account information.
-   Logout button.

------------------------------------------------------------------------

# 7. Data Models

The initial application should use a small number of clear entities.

## 7.1 User

``` text
User
- id
- name
- email
- roomId
- role
```

## 7.2 Room

``` text
Room
- id
- building
- floor
- roomNumber
- roomType
- status
```

## 7.3 Expense

``` text
Expense
- id
- roomId
- billingMonth
- electricity
- water
- internet
- other
- total
- dueDate
- paymentStatus
- createdAt
```

## 7.4 MaintenanceRequest

``` text
MaintenanceRequest
- id
- roomId
- userId
- title
- category
- description
- imageUrl
- status
- createdAt
- updatedAt
```

## 7.5 Announcement

``` text
Announcement
- id
- title
- summary
- content
- imageUrl
- publishedAt
- isRead
```

------------------------------------------------------------------------

# 8. Backend / API Requirements

The existing fitness-app backend will be reused as the technical
foundation where practical.

The domain models and endpoints should be adapted from workout-related
resources to DormMate resources.

> Exact endpoint paths are intentionally marked as TBD until the
> existing backend structure is inspected. The SRS does not assume
> endpoint names that have not yet been verified.

Suggested API structure:

``` text
/api/auth/
/api/profile/
/api/rooms/
/api/expenses/
/api/maintenance/
/api/announcements/
```

## 8.1 Suggested API Operations

### Profile

``` http
GET /api/profile/
```

### Room

``` http
GET /api/rooms/me/
```

### Expenses

``` http
GET /api/expenses/
GET /api/expenses/{id}/
```

### Maintenance

``` http
GET /api/maintenance/
POST /api/maintenance/
GET /api/maintenance/{id}/
DELETE /api/maintenance/{id}/
```

### Announcements

``` http
GET /api/announcements/
GET /api/announcements/{id}/
```

These are proposed resource contracts for the new domain and are not
claims about the current fitness backend.

------------------------------------------------------------------------

# 9. Screen Requirements

## 9.1 Login Screen

Purpose:

-   Authenticate the user.
-   Provide a clean entry point.

UI direction:

``` text
        DormMate

   Your dorm, simplified.

   ┌───────────────────────┐
   │      Continue with    │
   │        Sign In        │
   └───────────────────────┘
```

Visual style:

-   Large whitespace.
-   Soft glass card.
-   Thin translucent border.
-   Minimal typography.
-   Subtle background blur.
-   No excessive gradients.

------------------------------------------------------------------------

## 9.2 Home Screen

Main dashboard.

Sections:

1.  Greeting.
2.  Room card.
3.  Monthly expense card.
4.  Maintenance status.
5.  Latest announcement.

Example structure:

``` text
Good evening
Pudcharapon

┌───────────────────────────┐
│ ROOM                      │
│ B-204                     │
│ Building B · 2nd Floor   │
└───────────────────────────┘

┌───────────────────────────┐
│ SEPTEMBER                 │
│ ฿1,850                    │
│ Monthly expenses          │
└───────────────────────────┘

Maintenance
1 active request

Latest
Water system maintenance
```

------------------------------------------------------------------------

## 9.3 Expense Screen

Features:

-   Current month summary.
-   Expense history.
-   Payment status.
-   Detail navigation.

Visual direction:

-   Large total amount.
-   Small supporting metadata.
-   Rounded glass cards.
-   Minimal chart only if useful.
-   Avoid dashboard clutter.

------------------------------------------------------------------------

## 9.4 Maintenance Screen

Features:

-   Request list.
-   Status filter.
-   Create request button.
-   Swipe action.
-   Empty state.

Example:

``` text
Maintenance

All     Pending     Active     Done

┌───────────────────────────┐
│ Air conditioner           │
│ Room B-204                │
│ In Progress          ›    │
└───────────────────────────┘
```

------------------------------------------------------------------------

## 9.5 Create Maintenance Screen

Fields:

``` text
Problem
[ Air conditioner not cooling ]

Category
[ Air Conditioner        ]

Description
[ The AC has been running
  but the room is still hot. ]

Add photo
[ + ]

          Submit Request
```

------------------------------------------------------------------------

## 9.6 Announcement Screen

Features:

-   Announcement list.
-   Announcement detail.
-   Date.
-   Read state.

------------------------------------------------------------------------

## 9.7 Profile Screen

Sections:

``` text
Profile

Pudcharapon
pudcharapon@example.com

Room
B-204

Account
Personal information

Settings

Log out
```

------------------------------------------------------------------------

# 10. Navigation

Recommended navigation:

``` text
Login
  │
  ▼
Home
 ├── Room
 ├── Expenses
 │    └── Expense Detail
 ├── Maintenance
 │    ├── Maintenance Detail
 │    └── Create Request
 ├── Announcements
 │    └── Announcement Detail
 └── Profile
```

Recommended bottom navigation:

``` text
Home        Expenses       Maintenance       Profile
  ●             ○                ○                ○
```

Announcements can be accessed from the Home screen or as a secondary
destination.

------------------------------------------------------------------------

# 11. UI / UX Design System

## 11.1 Design Direction

The visual identity of DormMate should communicate:

-   Minimal
-   Modern
-   Premium
-   Calm
-   Clean
-   iOS-inspired
-   Sophisticated

The application should avoid looking like a generic administration
system.

## 11.2 Glassmorphism

Glass effects should be used selectively.

Recommended characteristics:

-   Semi-transparent surfaces.
-   Background blur.
-   Very subtle borders.
-   Soft shadows.
-   Large rounded corners.
-   Layered cards.
-   Strong contrast between text and background.

Do not apply glassmorphism to every element.

Use glass surfaces primarily for:

-   Dashboard cards.
-   Modal sheets.
-   Floating controls.
-   Important summary cards.

## 11.3 Color Direction

Base palette:

``` text
Background
#F5F5F7

Primary Text
#111111

Secondary Text
#6E6E73

Glass Surface
White with transparency

Border
White / low-opacity neutral

Accent
One restrained accent color

Success
Used only for completed/paid states

Warning
Used only for pending states

Error
Used only for critical/error states
```

The UI should remain mostly monochromatic, with color reserved for
status and important data.

## 11.4 Typography

Recommended hierarchy:

``` text
Large Title
32–40 px
Bold / Semibold

Section Title
20–24 px
Semibold

Card Value
28–36 px
Semibold

Body
15–17 px

Caption
12–14 px
```

Typography should feel similar to modern iOS system interfaces.

## 11.5 Components

Reusable components should include:

-   `GlassCard`
-   `StatusBadge`
-   `PrimaryButton`
-   `SecondaryButton`
-   `AppTextField`
-   `ExpenseCard`
-   `MaintenanceCard`
-   `AnnouncementCard`
-   `RoomCard`
-   `LoadingView`
-   `ErrorView`
-   `EmptyState`

------------------------------------------------------------------------

# 12. State Management

The application should explicitly represent common UI states.

## 12.1 Loading

``` text
isLoading = true
```

The UI displays a loading indicator or skeleton.

## 12.2 Success

``` text
isLoading = false
data != null
error = null
```

The UI displays the data.

## 12.3 Error

``` text
isLoading = false
error != null
```

The UI displays an appropriate error state.

## 12.4 Empty

``` text
data.isEmpty == true
```

The UI displays a meaningful empty state.

Example:

``` text
No maintenance requests

Everything looks good.
```

------------------------------------------------------------------------

# 13. State Completion Demo

The maintenance module should be used as the primary MVVM
state-management demonstration.

Example flow:

``` text
User
 ↓
Swipe maintenance request
 ↓
View
 ↓
MaintenanceViewModel
 ↓
MaintenanceRepository
 ↓
ApiService
 ↓
Backend
 ↓
Repository returns result
 ↓
ViewModel updates local state
 ↓
notifyListeners()
 ↓
View rebuilds
```

This directly demonstrates the course requirement for state completion
and visible UI updates.

------------------------------------------------------------------------

# 14. Testing Requirements

## 14.1 Unit Testing

ViewModels should be testable independently of the real API.

Example:

``` text
FakeMaintenanceRepository
        ↓
MaintenanceViewModel
        ↓
Test
```

Tests should cover:

### Maintenance

-   Load maintenance requests.
-   Create request.
-   Delete/cancel request.
-   Handle empty data.
-   Handle repository errors.
-   Update state after successful deletion.

### Expense

-   Load expense data.
-   Calculate/display total.
-   Handle empty history.
-   Handle API errors.

### Authentication

-   Authenticated state.
-   Logged-out state.
-   User information display.

------------------------------------------------------------------------

# 15. Functional Test Cases

  --------------------------------------------------------------------------------
  Test ID           Test              Condition               Expected Result
  ----------------- ----------------- ----------------------- --------------------
  TC-01             Login             Valid authentication    User enters Home

  TC-02             Login             Authentication fails    Error is displayed

  TC-03             Dashboard         API returns data        Dashboard displays
                                                              current data

  TC-04             Dashboard         API fails               Error state is
                                                              displayed

  TC-05             Expense List      Expense data exists     Expense list is
                                                              displayed

  TC-06             Expense Detail    User selects an expense Detail screen opens

  TC-07             Maintenance List  Requests exist          Requests are
                                                              displayed

  TC-08             Create Request    Required fields are     New request is
                                      valid                   submitted

  TC-09             Create Request    Required field is empty Validation message
                                                              appears

  TC-10             Delete Request    User confirms           Request
                                      cancellation/deletion   disappears/updates

  TC-11             State Update      Repository operation    ViewModel notifies
                                      succeeds                UI

  TC-12             Announcement      Announcement exists     Announcement appears

  TC-13             Profile           User is authenticated   Profile information
                                                              appears

  TC-14             Logout            User selects logout     User returns to
                                                              Login
  --------------------------------------------------------------------------------

------------------------------------------------------------------------

# 16. Non-Functional Requirements

## NFR-01 Performance

The application should:

-   Load screens without unnecessary blocking.
-   Avoid repeated API requests.
-   Update UI immediately after local state changes when appropriate.
-   Keep list rendering efficient.

## NFR-02 Maintainability

The system shall maintain clear separation between:

``` text
View
ViewModel
Repository
Service
Model
```

## NFR-03 Testability

ViewModels shall be testable without:

-   Opening the real UI.
-   Calling the real backend.
-   Depending directly on network availability.

## NFR-04 Security

The system should:

-   Use authenticated API requests.
-   Avoid storing sensitive credentials directly in source code.
-   Protect user-specific data.
-   Prevent unauthenticated access to protected resources.

## NFR-05 Usability

The application should:

-   Use clear navigation.
-   Provide understandable error messages.
-   Provide loading and empty states.
-   Require minimal user interaction for common tasks.

## NFR-06 Visual Quality

The application should maintain:

-   Consistent spacing.
-   Consistent typography.
-   Consistent corner radius.
-   Consistent iconography.
-   Restrained use of color.
-   Premium visual hierarchy.

------------------------------------------------------------------------

# 17. Suggested Flutter Project Structure

``` text
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   ├── routing/
│   └── utils/
│
├── models/
│   ├── user.dart
│   ├── room.dart
│   ├── expense.dart
│   ├── maintenance_request.dart
│   └── announcement.dart
│
├── services/
│   ├── api_service.dart
│   └── auth_service.dart
│
├── repositories/
│   ├── profile_repository.dart
│   ├── room_repository.dart
│   ├── expense_repository.dart
│   ├── maintenance_repository.dart
│   └── announcement_repository.dart
│
├── viewmodels/
│   ├── auth_viewmodel.dart
│   ├── home_viewmodel.dart
│   ├── expense_viewmodel.dart
│   ├── maintenance_viewmodel.dart
│   ├── announcement_viewmodel.dart
│   └── profile_viewmodel.dart
│
├── views/
│   ├── auth/
│   │   └── login_screen.dart
│   │
│   ├── home/
│   │   └── home_screen.dart
│   │
│   ├── expenses/
│   │   ├── expense_screen.dart
│   │   └── expense_detail_screen.dart
│   │
│   ├── maintenance/
│   │   ├── maintenance_screen.dart
│   │   ├── maintenance_detail_screen.dart
│   │   └── create_maintenance_screen.dart
│   │
│   ├── announcements/
│   │   ├── announcement_screen.dart
│   │   └── announcement_detail_screen.dart
│   │
│   └── profile/
│       └── profile_screen.dart
│
├── widgets/
│   ├── glass_card.dart
│   ├── status_badge.dart
│   ├── expense_card.dart
│   ├── maintenance_card.dart
│   ├── announcement_card.dart
│   └── common/
│
└── main.dart
```

------------------------------------------------------------------------

# 18. Recommended MVP

To keep the project realistic and presentation-ready, the first version
should prioritize:

### Phase 1 --- Authentication

-   OIDC Login
-   Logout
-   User information

### Phase 2 --- Home

-   Room information
-   Expense summary
-   Maintenance summary
-   Latest announcement

### Phase 3 --- Expenses

-   Expense list
-   Expense detail

### Phase 4 --- Maintenance

-   Request list
-   Create request
-   Request detail
-   Delete/cancel request
-   Status update

### Phase 5 --- Announcements

-   Announcement list
-   Announcement detail

### Phase 6 --- Testing

-   Fake Repository
-   ViewModel unit tests
-   Loading/error/empty state tests

### Phase 7 --- UI Polish

-   Glassmorphism
-   iOS-inspired navigation
-   Animation
-   Spacing
-   Typography
-   Empty states
-   Loading states

------------------------------------------------------------------------

# 19. Presentation / Live Demo Scenario

The recommended presentation flow is:

## Step 1 --- Authentication

``` text
Open DormMate
    ↓
Login
    ↓
OIDC Authentication
    ↓
Return to App
    ↓
Display User Name
```

## Step 2 --- Data Integrity

Open Home:

``` text
Room
Expenses
Maintenance
Announcements
```

Show that the data comes from the backend.

## Step 3 --- Maintenance CRUD

``` text
Open Maintenance
    ↓
Create Request
    ↓
Submit
    ↓
New request appears
```

Then:

``` text
Swipe request
    ↓
Cancel/Delete
    ↓
Repository operation
    ↓
ViewModel state update
    ↓
notifyListeners()
    ↓
Request disappears from UI
```

## Step 4 --- Architecture

Explain:

``` text
View
  ↓
ViewModel
  ↓
Repository
  ↓
Service
  ↓
Backend
```

Emphasize that:

-   View does not call API directly.
-   ViewModel does not know the View.
-   Repository hides data-access details.
-   Service is a stateless API client.
-   Dependencies are injected through constructors.

## Step 5 --- Testing

Show:

``` text
FakeRepository
      ↓
ViewModel
      ↓
Unit Test
```

Demonstrate that ViewModel logic can be tested without the real backend.

------------------------------------------------------------------------

# 20. Future Enhancements

Possible future versions may include:

-   Online payment.
-   Push notifications.
-   QR-based room access.
-   Dormitory staff dashboard.
-   Maintenance technician assignment.
-   Utility usage charts.
-   Digital receipts.
-   Roommate management.
-   Visitor registration.
-   Parcel tracking.
-   Dormitory rules and documents.
-   Multiple dormitory support.

These features are not required for the MVP.

------------------------------------------------------------------------

# 21. Success Criteria

DormMate will be considered successful when:

1.  A user can authenticate successfully.
2.  Authenticated user information is displayed.
3.  The application can retrieve real backend data.
4.  Room information is displayed.
5.  Expense records can be viewed.
6.  Maintenance requests can be created and displayed.
7.  Maintenance state can be changed or removed.
8.  UI updates correctly after state changes.
9.  Repository and Service layers are separated.
10. ViewModels receive repositories through dependency injection.
11. At least one ViewModel can be tested using a Fake Repository.
12. The application demonstrates loading, success, error, and empty
    states.
13. The final UI follows a minimal, modern, premium, iOS-inspired
    glassmorphism design.

------------------------------------------------------------------------

# 22. Architecture Summary

The final DormMate architecture is:

``` text
                         ┌───────────────┐
                         │     View      │
                         │ Flutter UI    │
                         └───────┬───────┘
                                 │
                                 ▼
                         ┌───────────────┐
                         │   ViewModel   │
                         │ State + Logic │
                         └───────┬───────┘
                                 │
                         Constructor Injection
                                 │
                                 ▼
                         ┌───────────────┐
                         │  Repository   │
                         │  Data Access  │
                         └───────┬───────┘
                                 │
                                 ▼
                         ┌───────────────┐
                         │    Service    │
                         │ Stateless API │
                         └───────┬───────┘
                                 │
                                 ▼
                         ┌───────────────┐
                         │    Backend    │
                         │ REST + OIDC   │
                         └───────────────┘
```

The design follows the course's intended separation:

-   **View** knows only its ViewModel.
-   **ViewModel** receives Repository dependencies through its
    constructor.
-   **Repository** receives Service dependencies through its
    constructor.
-   **Service** operates as a stateless API client.

This structure supports maintainability, extensibility, and testability
while making the architecture easy to demonstrate during the final
project presentation.

------------------------------------------------------------------------

# 23. Final Product Vision

**DormMate is not intended to look like a traditional dormitory
management system.**

The final product should feel like a premium personal utility app:

``` text
              DormMate
        Your dorm, simplified.

      ┌─────────────────────┐
      │                     │
      │      ROOM B-204     │
      │      Building B     │
      │                     │
      └─────────────────────┘

       This month
          ฿1,850

      Maintenance
      ● In Progress

      Latest announcement
      Water system maintenance
```

The visual language should combine:

**iOS-inspired minimalism + subtle glassmorphism + premium typography +
clean data presentation**

while keeping the underlying architecture simple enough to clearly
demonstrate **MVVM, Repository, Service, dependency injection, backend
integration, and testability**.
