# DormMate — Implementation Plan

> อ้างอิงจาก DormMate_SRS.md (v1.0)
> Flutter Mobile App — MVVM + Repository + Service, OIDC Auth

---

## 1. ภาพรวมแผนการทำงาน

แบ่งงานออกเป็น **7 Phase** ตามลำดับความสำคัญ (MVP-first) เพื่อให้ demo ได้ในแต่ละช่วง และแสดง architecture ได้ครบตามข้อกำหนดของวิชา (MVVM, Repository, Service, DI, Testability)

```
Phase 0: Project Setup & Architecture Skeleton
Phase 1: Authentication (OIDC)
Phase 2: Home / Dashboard
Phase 3: Expenses
Phase 4: Maintenance (CRUD)
Phase 5: Announcements
Phase 6: Testing (Fake Repository)
Phase 7: UI Polish (Glassmorphism)
```

---

## 2. Phase 0 — Project Setup & Architecture Skeleton

**เป้าหมาย:** เตรียมโครงสร้างโปรเจกต์ให้ตรงกับ MVVM + Repository + Service ก่อนเขียนฟีเจอร์ใดๆ

### งานที่ต้องทำ
1. สร้างโปรเจกต์ Flutter ใหม่ (หรือ reuse โครง fitness app เดิม)
2. ตั้งค่า dependency management (เลือก `provider` หรือ `riverpod` สำหรับ ChangeNotifier/state — ตาม SRS ใช้ `ChangeNotifier`)
3. สร้างโฟลเดอร์ตามผังที่ SRS กำหนดไว้:
   ```
   lib/
   ├── models/
   ├── services/
   ├── repositories/
   ├── viewmodels/
   ├── views/
   ├── widgets/
   └── main.dart
   ```
4. ตั้งค่า `ApiService` พื้นฐาน (base URL, header injection, error handling) — ยังไม่ผูก endpoint จริง
5. ตรวจสอบโครงสร้าง backend เดิม (fitness app) เพื่อ map resource → DormMate resource (auth, profile, rooms, expenses, maintenance, announcements) — ตาม SRS endpoint ยังเป็น TBD ต้อง inspect จริงก่อน
6. ตั้งค่า dependency injection ผ่าน constructor (ไม่ใช้ service locator/global singleton)
7. เพิ่ม `flutter_test` + `mockito`/manual fake classes สำหรับเตรียม Phase 6

### Deliverable
- โปรเจกต์ build ผ่าน, มีโครง MVVM ว่างพร้อมต่อฟีเจอร์
- เอกสาร mapping endpoint เดิม → endpoint ใหม่ (แม้จะยัง TBD บางส่วน)

---

## 3. Phase 1 — Authentication (OIDC) — FR-01, FR-02

**เป้าหมาย:** ผู้ใช้ login/logout ผ่าน OIDC และป้องกันข้อมูลส่วนตัว

### งานที่ต้องทำ
1. เลือก/ติดตั้ง OIDC client package (เช่น `flutter_appauth`)
2. สร้าง `AuthService` (stateless) — จัดการ authorization code flow, token exchange, token storage (secure storage)
3. สร้าง `AuthRepository` — ครอบ `AuthService`, expose สถานะ login/logout, ดึงชื่อผู้ใช้
4. สร้าง `AuthViewModel extends ChangeNotifier` — รับ `AuthRepository` ผ่าน constructor, จัดการ state: `unauthenticated / authenticating / authenticated / error`
5. สร้าง `LoginScreen` (glass card, ปุ่ม "Continue with Sign In")
6. เพิ่ม route guard: ป้องกันการเข้าถึงหน้าอื่นถ้ายังไม่ authenticated
7. เพิ่ม logout flow: เคลียร์ token, กลับไปหน้า Login

### Acceptance Criteria (ตรวจตาม SRS)
- เริ่ม login ได้, redirect ผ่าน OIDC, กลับเข้าแอปสำเร็จ
- แสดงชื่อผู้ใช้ที่ authenticated แล้ว
- หน้า protected เข้าไม่ได้ถ้ายังไม่ login

---

## 4. Phase 2 — Home / Dashboard — FR-03, FR-04

**เป้าหมาย:** แสดงข้อมูลสรุปห้อง, ค่าใช้จ่ายเดือนนี้, สถานะแจ้งซ่อม, ประกาศล่าสุด

### งานที่ต้องทำ
1. สร้าง model: `Room` (`id, building, floor, roomNumber, roomType, status`)
2. สร้าง `RoomRepository` → `RoomService`/ใช้ `ApiService` เดียวกัน (`GET /api/rooms/me/`)
3. สร้าง `HomeViewModel` — รวมข้อมูลจาก room, expense summary, maintenance summary, latest announcement (อาจ inject repository หลายตัว)
4. สร้าง `HomeScreen`:
   - Greeting ("Good morning, [Name]")
   - Room card
   - Monthly expense card
   - Maintenance status summary
   - Latest announcement
5. Implement loading / error / empty state ตาม Acceptance Criteria
6. เพิ่ม pull-to-refresh

### Acceptance Criteria
- โหลดข้อมูลของผู้ใช้ที่ authenticated แล้ว
- แสดง loading ระหว่างโหลด, error state ถ้าโหลดไม่สำเร็จ
- รีเฟรชข้อมูลได้เมื่อผู้ใช้ต้องการ

---

## 5. Phase 3 — Expenses — FR-05, FR-06

**เป้าหมาย:** ดูรายการค่าใช้จ่ายรายเดือนและรายละเอียด

### งานที่ต้องทำ
1. สร้าง model: `Expense` (`id, roomId, billingMonth, electricity, water, internet, other, total, dueDate, paymentStatus, createdAt`)
2. สร้าง `ExpenseRepository` (`GET /api/expenses/`, `GET /api/expenses/{id}/`)
3. สร้าง `ExpenseViewModel` — list state + selected detail state
4. สร้าง `ExpenseScreen` (list, แต่ละรายการแสดง เดือน/ยอดรวม/สถานะ)
5. สร้าง `ExpenseDetailScreen` (billing period, รายการค่าแยก, total, due date, payment status)
6. Widget: `ExpenseCard`

### Acceptance Criteria
- ดูรายการค่าใช้จ่ายทั้งหมด + ประวัติได้
- เปิดรายละเอียดของแต่ละรายการได้ครบตามฟิลด์

---

## 6. Phase 4 — Maintenance (CRUD) — FR-07 ถึง FR-10

**เป้าหมาย:** ส่วนสำคัญที่สุดสำหรับ demo state management (Create + Delete/Cancel)

### งานที่ต้องทำ
1. สร้าง model: `MaintenanceRequest` (`id, roomId, userId, title, category, description, imageUrl, status, createdAt, updatedAt`)
2. สร้าง enum: `MaintenanceStatus { pending, inProgress, completed, cancelled }`
3. สร้าง enum: `MaintenanceCategory { electrical, water, airConditioner, furniture, internet, bathroom, cleaning, other }`
4. สร้าง `MaintenanceRepository`:
   - `getAll()` → `GET /api/maintenance/`
   - `create(request)` → `POST /api/maintenance/`
   - `getById(id)` → `GET /api/maintenance/{id}/`
   - `delete(id)` → `DELETE /api/maintenance/{id}/`
5. สร้าง `MaintenanceViewModel extends ChangeNotifier`:
   - รับ `MaintenanceRepository` ผ่าน constructor (ตาม SRS example)
   - state: list, loading, error, submitting
   - method: `loadRequests()`, `createRequest()`, `cancelRequest(id)`
   - เรียก `notifyListeners()` ทุกครั้งที่ state เปลี่ยน (สำคัญสำหรับ demo)
6. สร้าง `MaintenanceScreen` (list + swipe-to-cancel)
7. สร้าง `CreateMaintenanceScreen` (form: title, category picker, description, optional image)
8. สร้าง `MaintenanceDetailScreen` (status, ประวัติ)
9. Widget: `MaintenanceCard`, `StatusBadge`
10. Implement flow ตาม SRS:
    ```
    Swipe left → Cancel → Confirmation dialog
    → Repository.delete() → ViewModel update state
    → notifyListeners() → UI update ทันที
    ```

### Acceptance Criteria
- สร้าง/ดู/ลบ (ที่ได้รับอนุญาต) คำขอแจ้งซ่อมได้
- UI อัปเดตทันทีหลัง state เปลี่ยน (ไม่ใช่ต้อง refresh manual)

---

## 7. Phase 5 — Announcements — FR-11

**เป้าหมาย:** ดูประกาศของหอพัก

### งานที่ต้องทำ
1. สร้าง model: `Announcement` (`id, title, summary, content, imageUrl, publishedAt, isRead`)
2. สร้าง `AnnouncementRepository` (`GET /api/announcements/`, `GET /api/announcements/{id}/`)
3. สร้าง `AnnouncementViewModel`
4. สร้าง `AnnouncementScreen` (list) + `AnnouncementDetailScreen`
5. Implement mark-as-read (local state ก่อน, เพิ่ม backend sync ถ้ารองรับ)
6. Widget: `AnnouncementCard`

### Acceptance Criteria
- ดูรายการประกาศ, เปิดดูรายละเอียดได้
- แสดงวันที่ประกาศ และสถานะอ่าน/ไม่อ่าน (ถ้ารองรับ)

---

## 8. Phase 6 — Testing (Fake Repository) — ข้อกำหนดสำคัญของวิชา

**เป้าหมาย:** แสดงว่า ViewModel ทดสอบได้โดยไม่ต้องพึ่ง backend จริง

### งานที่ต้องทำ
1. สร้าง `FakeMaintenanceRepository implements MaintenanceRepository` — คืนข้อมูล mock, จำลอง delay/error ได้
2. เขียน unit test สำหรับ `MaintenanceViewModel`:
   - test loading state
   - test success state (data โผล่ถูกต้อง)
   - test error state (repository throw exception)
   - test empty state (list ว่าง)
   - test create/delete แล้ว state เปลี่ยนถูกต้อง + `notifyListeners()` ถูกเรียก
3. ทำแบบเดียวกันกับ ViewModel อื่นอย่างน้อย 1 ตัวเพิ่มเติม (เช่น `ExpenseViewModel`) ถ้าเวลาเหลือ
4. ตั้ง `flutter test` ให้รันผ่าน CI/local ได้

### Acceptance Criteria
- อย่างน้อย 1 ViewModel ทดสอบผ่าน Fake Repository ได้สำเร็จ (ตาม Success Criteria ข้อ 11 ของ SRS)
- ครอบคลุม loading / success / error / empty state (Success Criteria ข้อ 12)

---

## 9. Phase 7 — UI Polish (Glassmorphism / iOS-inspired)

**เป้าหมาย:** ทำให้แอปดู premium ตาม Final Product Vision ใน SRS

### งานที่ต้องทำ
1. สร้าง design token กลาง (สี, radius, blur, typography) แยกไฟล์ theme
2. สร้าง widget กลาง `GlassCard` (translucent + blur + thin border) ใช้ซ้ำได้ทุกหน้า
3. ปรับ navigation ให้รู้สึกแบบ iOS (transition, bottom nav หรือ tab bar แบบ minimal)
4. เพิ่ม micro-animation (fade/slide เมื่อโหลดข้อมูล, สถานะเปลี่ยน)
5. ปรับ spacing/typography ให้สอดคล้องกับตัวอย่างในหัวข้อ 23 ของ SRS
6. ออกแบบ empty state และ loading state ให้ดู premium (ไม่ใช่ spinner ธรรมดา/ข้อความ error ดิบ)
7. รีวิว UI ทุกหน้าเทียบกับ mockup ตัวอย่างใน SRS (Login, Home, Expense, Maintenance, Announcement)

### Acceptance Criteria
- ทุกหน้าใช้ `GlassCard` และ theme เดียวกัน
- Loading/Error/Empty state มี UI ที่ออกแบบแล้ว ไม่ใช่ default widget เปล่าๆ

---

## 10. สรุป Milestone สำหรับ Presentation (ตาม SRS หมวด 19)

| ลำดับ Demo | สิ่งที่ต้องโชว์ | อ้างอิง Phase |
|---|---|---|
| 1 | Login → OIDC → กลับเข้าแอป → แสดงชื่อผู้ใช้ | Phase 1 |
| 2 | Home แสดงข้อมูลจาก backend จริง (room/expense/maintenance/announcement) | Phase 2–5 |
| 3 | สร้าง Maintenance Request ใหม่ → ปรากฏใน list ทันที | Phase 4 |
| 4 | Swipe ยกเลิก request → หายจาก UI ทันทีผ่าน `notifyListeners()` | Phase 4 |
| 5 | อธิบาย Architecture: View → ViewModel → Repository → Service → Backend | ทุก Phase |
| 6 | โชว์ Unit Test ที่รันผ่าน FakeRepository โดยไม่ต่อ backend จริง | Phase 6 |

---

## 11. Risk & สิ่งที่ต้องตรวจสอบก่อนเริ่ม

1. **Backend endpoint ยังเป็น TBD** — ต้อง inspect fitness-app backend จริงก่อนเริ่ม Phase 2 เป็นต้นไป เพื่อ map resource ให้ตรง (อาจต้องเพิ่ม endpoint ใหม่ฝั่ง backend ถ้าไม่มี)
2. **OIDC provider/config** — ต้องยืนยันว่าจะใช้ provider ตัวไหน (Auth0/Keycloak/อื่นๆ) และมี client id/redirect URI พร้อมหรือยัง
3. **Image upload** (สำหรับ maintenance request) — ต้องเช็คว่า backend เดิมรองรับ multipart upload หรือต้องเพิ่มเอง
4. **Scope creep** — Administrator features (หมวด 3.2) และ Future Enhancements (หมวด 20) ไม่ต้องทำใน MVP นี้

---

*แผนนี้จัดทำจาก DormMate_SRS.md v1.0 — หากโครงสร้าง backend จริงต่างจากที่สมมติไว้ ควรปรับ Phase 0 และ endpoint mapping ก่อนเริ่ม Phase อื่น*
