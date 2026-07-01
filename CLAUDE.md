# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository structure

Two independent apps, no shared code between them:

- `CRMS/` — ASP.NET Core 10 Web API backend, plus a vanilla HTML/CSS/JS frontend served as static files from `CRMS/wwwroot` (no bundler/framework — plain multi-page HTML with hand-written JS).
- `crms_mobile/` — Flutter (GetX) staff app. Consumes the same backend API. Intentionally does **not** implement everything the web frontend has (see "Current status" below).

## Commands

### Backend (`CRMS/`)

- Build: `dotnet build`
- Run: `dotnet run` — binds to `http://localhost:5235` only. `dotnet run` uses the **first** profile in `Properties/launchSettings.json`, which is `"http"` (no HTTPS listener). The `"https"` profile (port 7235) exists but is not what's normally running — don't assume 7235 is live.
- EF migration after changing a model or `AppDbContext`: `dotnet ef migrations add <Name>` (run from `CRMS/`)
- Migrations apply automatically on startup via `context.Database.Migrate()` in `Program.cs` — no separate `dotnet ef database update` needed in normal dev.
- Requires a reachable SQL Server instance matching `ConnectionStrings:DefaultConnection` in `appsettings.json`.
- No backend test project exists yet (`CRMS.slnx` only references `CRMS/CRMS.csproj`).

### Mobile (`crms_mobile/`)

- Install deps: `flutter pub get`
- Static analysis: `flutter analyze`
- Tests: `flutter test` (single file: `flutter test test/widget_test.dart`)
- Run: `flutter run -d windows` is the verified path in this dev environment (no Android emulator configured). `flutter run -d chrome` will hit CORS errors unless the dev server's origin is added to `Cors:AllowedOrigins` in `CRMS/appsettings.json` first.

## Architecture

### Backend layering

Every feature follows the same four-layer shape: **Controller → Service → Repository → `AppDbContext`/EF model**, with DTOs in `Data/DTOs/<Feature>/`. New features should follow this exact shape (see `Users`, `Departments`, `ReferralSources`, `Customers` as templates) — repository does raw EF queries, service has the business rules/DTO mapping, controller just routes + auth attributes.

### Auth

JWT bearer auth (`TokenService`/`AuthService`). One important non-obvious fix: `Program.cs` sets `JwtSecurityTokenHandler.DefaultMapInboundClaims = false` — without this, the JWT's `sub` claim gets auto-mapped to `ClaimTypes.NameIdentifier` by the framework, colliding with the explicit numeric-id `NameIdentifier` claim `TokenService` adds, and `User.FindFirstValue(ClaimTypes.NameIdentifier)` silently returns the username instead of the id. Don't remove that line.

On first run with an empty `Users` table, `Program.cs` seeds one Admin from `appsettings.json`'s `AdminSeed` section. No sign-up flow exists — accounts are only created via `UsersController` (Admin-only).

### Soft-delete convention

`User`, `Department`, `ReferralSource`, and `Doctor` all use an `IsActive` bool instead of hard deletes — "delete" in the UI always means `PATCH .../{id}/status`. This exists because `Customer` has FK references (`DeleteBehavior.Restrict`) to these lookups, and `Customer` history must survive a lookup value being retired. Follow this pattern for any future lookup-style entity. Lookup `GET` (no suffix) requires auth and returns active rows; the `/manage` suffix routes are Admin-only and return inactive rows too. `Doctor` additionally has an FK to `Department` (every doctor belongs to one) — the Waiting follow-up's doctor dropdown filters by the chosen department.

### Cases feature (internal CRM, employee-driven)

A `Customer` row **is a "case"** — a patient lead created by an employee, not a public form. Cases start **unassigned** (`AssignedToUserId = null`); anyone can claim one (`POST /api/cases/{id}/claim`). From there, any employee can act on a case:

- **Follow-up** (`POST /api/cases/{id}/follow-up`) — sets the patient status to one of `Pending / Waiting / Success / Failed`, each carrying a date + notes; `Waiting` additionally assigns department + doctor + appointment date. Logged as a `FollowUp` `CaseAction` with `ResultingStatus`.
- **Forward** (`POST /api/cases/{id}/forward`) — owner forwards to a colleague. Sets `Customer.PendingForwardToUserId`; logs a `Forwarded` `CaseAction`; sends a `CaseForwarded` notification. The case stays owned by the sender until the recipient acts.
  - **Accept** (`POST /api/cases/{id}/accept-forward`) — transfers `AssignedToUserId` to the recipient, sets `ForwardedByUserId` = previous owner, clears `PendingForwardToUserId`. Logs `ForwardAccepted`, notifies sender.
  - **Decline** (`POST /api/cases/{id}/decline-forward`) — clears `PendingForwardToUserId` only; ownership stays. Logs `ForwardDeclined`, notifies sender.

`CustomerStatus` and `CaseActionType` (`Created`/`Claimed`/`Forwarded`/`ForwardAccepted`/`ForwardDeclined`/`FollowUp`) are enums stored as **string** columns. The `CaseAction` table is the append-only timeline rendered on the case view page. **Forwarded to Me** list = cases where `PendingForwardToUserId == me`.

### Frontend (`wwwroot`)

- `nav.js`'s `NAV_ITEMS` array is the single source of truth for the drawer on every authenticated page (`dashboard.html`, `newCase.html`, `cases-mine.html`, `cases-forwarded-in.html`, `cases-forwarded-out.html`, `manageLists.html`, `userManage.html`). Adding a new section = one entry in that array; `roles: [...]` restricts visibility, omit it to show to everyone. The shared topbar/drawer markup is duplicated per-page (no templating engine) but the behavior lives entirely in `nav.js` (which also injects the signed-in user into the drawer and, via `js/notifications.js`, the notification bell into the topbar).
- There is **no** unauthenticated page anymore (the old bilingual public `customer.html` was retired). `index.html` is the login page; every other page redirects to it without a session. `js/countries.js` is a static dial-code dataset (not admin-managed) reused by `newCase.html`'s phone field.
- The three case **list** pages share `js/cases.js` (rows + search → link to `case.html?id=…`); the case **detail** page is `case.html` + `js/case.js` (form-style detail, JS-built Forward/Follow-up modals, and the `CaseAction` timeline). Departments, ReferralSources, and Doctors are all managed in `manageLists.html` — a single tabbed panel (one list shown at a time, per-list search, fixed-height scroll with sticky header) driven by the generic `RESOURCES` map in `js/manageLists.js`; the `doctor` entry sets `hasDepartment: true` to show the extra dropdown in the add/edit modal and a Department column. Adding a fourth lookup = one more `RESOURCES` entry + one `.seg` tab button.
- CSS gotcha: an element toggled via the `hidden` attribute must not also get an explicit `display` value from the same class selector, or the `hidden` attribute stops working (author CSS beats the UA `[hidden]` rule at equal specificity). See `.modal-overlay[hidden] { display: none; }` in `dashboard.css` for the fix pattern — apply it to any new class that sets `display` on a `[hidden]`-toggled element.

### Mobile (`crms_mobile`)

- Standard GetX module shape per feature: `modules/<feature>/{bindings,controllers,views}`. Routes/bindings registered in `routes/app_pages.dart` + `routes/app_routes.dart`.
- `data/nav_items.dart`'s `NavItems.items` mirrors web's `NAV_ITEMS` — same role-filtering idea, rendered via Flutter's built-in `Scaffold.drawer` (hamburger icon is automatic, no manual burger button needed).
- `ApiConfig.host` is the single source of truth for the backend address (now `http://192.168.1.63:8082`, the LAN/IIS deployment) — one constant, same for every platform (the old localhost / `10.0.2.2`-emulator split is gone). For local dev against `dotnet run`, change it back to `http://localhost:5235` (or `10.0.2.2` for an Android emulator).
- Shared "modern" form widgets: `widgets/app_text_field.dart` and `widgets/app_dropdown_field.dart` (rounded filled fields with focus glow) plus a global `dialogTheme` in `theme/app_theme.dart`. Use these instead of raw `TextField`/`DropdownButtonFormField` in any new dialog, for visual consistency.
- Gotcha: don't wrap a `ListTile` directly in a `Container`/`DecoratedBox` that sets a background color — it breaks the `ListTile`'s ink-splash rendering (`Material` ancestor assertion). Wrap in `Material(color: ...)` instead (see `widgets/app_drawer.dart`).
- `flutter test` golden-file screenshots render text as solid blocks unless fonts are explicitly loaded via `FontLoader` — not generally worth doing for a quick visual check; prefer a real `flutter run` smoke test instead.

## Current status (as of 2026-06-30)

> The case feature went through a v1→v2 redesign. v1 (public intake + pick-from-pool/assign workflow, statuses `Waiting/Assigned/Forwarded/FollowUp/Resolved/Failed`, manager-only follow-up) was a misread of the requirements and has been fully replaced by the employee-driven CRM model below. The `AddDoctorsAndCaseRedesign` migration remaps any leftover v1 status/action strings so old rows still load.

### Done, both web and mobile

- Auth (JWT, seeded admin).
- User Management: list, create, edit username/role, reset password, enable/disable (self-disable blocked both client- and server-side).
- Department + ReferralSource admin-managed lookup lists.
- Drawer/nav shell, role-filtered, same `NAV_ITEMS`/`NavItems` shape on both platforms.

### Done, both web and mobile (mobile migrated 2026-06-29)

- **Doctor** + **Procedure** lookups (admin-managed, each belongs to a Department; `Department` itself carries a `LocationType` of Hospital/Clinics). Web `manageLists.html`; mobile tabbed `manage_lists` module.
- **Cases (employee-driven CRM)**: create (location → department → procedure/doctor cascade, Jordan phone default), a filterable list (All / Today / Assigned to me / Unassigned + name/phone search), and a full case detail with `CaseAction` timeline. Actions: **Assign to me** (claim), **Follow-up** (status `Pending/Waiting/Success/Failed`; `Waiting` books dept + doctor + appointment), and **Forward** with Accept/Decline. Cases start unassigned; anyone can claim and follow up. Forward is owner-only; recipient sees pending cases in "Forwarded to Me" nav item.
- **Notification center**: `api/notifications/*`, web bell via `js/notifications.js`; mobile bell + badge in the top bar (`NotificationCenterController` polls every 30s) + a notifications screen (tap = mark read + open case, swipe = delete, mark-all-read). A **new case creates a `CaseCreated` notification for every other active user** (`CaseService.NotifyNewCaseAsync`). On mobile the poller raises an OS-level popup via `flutter_local_notifications` when a new notification arrives.

### Mobile specifics

- `ApiConfig.host` (lib/app/data/services/api_config.dart) is the single place to set the backend address — currently `http://192.168.1.63:8082`. Same URL for all platforms now (no localhost / 10.0.2.2 split). Cleartext HTTP is allowed via `usesCleartextTraffic` (Android) + `NSAppTransportSecurity` (iOS) because the backend has no TLS.
- Android release APK builds on this Windows box (`flutter build apk --release`). Two gotchas baked into `android/`: `coreLibraryDesugaring` is enabled (flutter_local_notifications needs it) and `kotlin.incremental=false` in `gradle.properties` (pub cache on C: + project on D: breaks Kotlin's incremental cache). App id is `com.alamal.crms`.
- **iOS build (.ipa) must be done on macOS/Xcode** — cannot build from Windows. Info.plist is already configured (display name, ATS, local-network usage string).

### Explicitly deferred (don't build ahead of this)

- **True background push** — notifications are delivered by a 30s foreground poll, not FCM/APNs, so a fully-killed app won't get a popup until reopened. No SignalR/background scheduler. Appointment reminders not built. `NotificationType.FollowUpReminder` is kept in the enum only so legacy rows still deserialize.
- **Mobile User Management edits** beyond what already exists, and the cosmetic `withOpacity`→`withValues` deprecation cleanup in the older login/users widgets (analyze shows them as infos only).
- **Editing a case's base patient info** after creation, and any per-status validation beyond what `CaseService.FollowUpAsync` enforces.

### Environment notes for next session

- The dev DB currently has a disabled seeded `admin` account; a separate Admin account (`Hamza`) created by the user is the active one. Don't assume `admin`/`ChangeMe123!` works without checking `Users.IsActive` first.
- When verifying anything against the live DB, only touch rows you can positively identify as your own test data (by exact id/name) — the user tests the live app manually in parallel.
- Dev SQL Server instance is `localhost\MSSQLSERVER01` (Windows auth, `ALAMAL\it.officer`). This is overridden in `appsettings.Development.json` — production `appsettings.json` points to `localhost\SQLEXPRESS01` (the IIS server). Don't conflate the two.

## Changelog

> Standing instruction from the user: **log every change we make to the app here.** Append a dated bullet (newest day at the bottom of its date group) whenever code/config/deploy changes. Keep entries terse — what changed and the key file(s), not a diff.

### 2026-06-29

- **Removed the entire forward workflow** (controller endpoints, service/repository methods, `INotificationRepository` use in `CaseService`, web Forward modal + API calls, "Forwarded to/by Me" lists, nav items). Cases no longer have a forward action.
- **Cases now start unassigned** (`CreateAsync` sets `AssignedToUserId = null`); **anyone can claim** a case (`POST /api/cases/{id}/claim`, new `CaseActionType.Claimed`) and **anyone can follow up** (`FollowUpAsync` no longer checks ownership).
- **Added `LocationType` enum (Hospital/Clinics)** stored as a string. `Department` and `Customer` both carry a `Location`; `Department` is filtered by location in the new-case cascade. Migration `AddLocationAndClaimSupport` (default value `Hospital` set manually in the migration — `HasDefaultValue` + `HasConversion<string>()` can't coexist).
- **Added `HasDoctor` bool on `Customer`** (reporting flag only; does NOT gate the doctor dropdown). Migration `AddHasDoctor`.
- **Added `Procedure` lookup** (soft-delete, admin-managed) — full Controller→Service→Repository→DTO stack, `manageLists.html` tab. Migration `AddProcedure`. Then made each **Procedure belong to a Department** (`DepartmentId` FK, per-department name uniqueness, filtered by department in new-case + validated in `CaseService.CreateAsync`). Migration `AddProcedureDepartment`.
- **Web frontend**: employee dashboard (`dashboard.html` + `js/employeeDashboard.js`) with All/Today/Assigned-to-me/Unassigned filters + name/phone search + per-row "Assign to Me"; New Case location→department→procedure/doctor cascade with a "has a doctor" checkbox; **Procedure** label + **Created By** column on employee and admin dashboards; **Jordan phone display** (`formatPhone` in `api.js`: `+962` shows no country code and a leading `0`); default dial code on New Case is Jordan (`+962`).
- **New-case notification**: `NotificationType.CaseCreated` added; `CaseService.NotifyNewCaseAsync` notifies **every other active user** when a case is created (re-added `INotificationRepository` to `CaseService`). No migration (enum stored as string).
- **Production prep (backend)**: `api.js` → relative `/api` base URL; `Program.cs` dropped OpenAPI + `UseHttpsRedirection` (TLS terminates at IIS); `appsettings.json` set to Warning logs, 8h token (`ExpiryMinutes: 480`), a real `Jwt:Key`, empty `Cors:AllowedOrigins`; dev-only overrides moved to `appsettings.Development.json`; connection string → `Server=localhost\SQLEXPRESS01;Database=CRMS`. Published to `D:\repos\crms\publish`.
- **IIS deployment** of the published backend at `http://192.168.1.63:8082` (in-process hosting). Notes: app pool needs a SQL login (`CREATE LOGIN [IIS AppPool\<pool>]` + `db_owner` on `CRMS`) or use SQL auth; `web.config` must not contain the `inheritInheritance` attr; `app_offline.htm` (or `iisreset /stop` + kill `w3wp.exe`) releases the `CRMS.dll` lock for redeploys. A backend-only change re-deploys as just `CRMS.dll`; frontend edits also need `wwwroot\` copied.
- **Mobile (`crms_mobile/`) full migration** to the v2 API — see "Done, both web and mobile" and "Mobile specifics" above. New modules (cases hub, new_case, case_detail, notifications), models (case_summary, case_detail, doctor, procedure, app_notification; department gained `location`), `NotificationCenterController` (30s poll → `flutter_local_notifications` OS popup), bell+badge in the top bar, tabbed Manage Lists. `ApiConfig.host` → `192.168.1.63:8082`. Android `build.gradle.kts`: desugaring on, app id `com.alamal.crms`; `kotlin.incremental=false`. Release APK builds clean (`build/app/outputs/flutter-apk/app-release.apk`). iOS Info.plist configured; .ipa needs a Mac. Deleted the dead `customers` module + `customer.dart`.

### 2026-06-30

- Republished the backend (`dotnet publish -c Release -o D:\repos\crms\publish`) carrying the `CaseCreated` notification change, for redeploy to the IIS server.
- **Dev connection string** added to `appsettings.Development.json` (`Server=localhost\MSSQLSERVER01`) so `dotnet run` works on the dev machine without touching the production `appsettings.json`.
- **Removed Location and standalone Department/Doctor/Procedure FKs**. `LocationType` enum deleted; `Location` column dropped from `Departments` and `Customers`. `DepartmentId` FK dropped from `Doctors` and `Procedures` — all four managed lists are now fully independent (no relationship between them). Doctor/Procedure uniqueness check is now global (name-only, not per-department). Web: location dropdown removed from New Case form and Manage Lists modal; all dropdowns (dept/procedure/doctor) populate upfront without cascading; `Location` row removed from case detail. Mobile: same changes across `department.dart`, `doctor.dart`, `procedure.dart`, `case_summary.dart`, `case_detail.dart`, `api_service.dart`, `manage_lists_controller.dart`, `list_item_form_dialog.dart`, `manage_lists_view.dart`, `new_case_controller.dart`, `new_case_view.dart`, `case_detail_view.dart`, `case_detail_controller.dart`, `follow_up_dialog.dart`, `case_status.dart`. Migration `RemoveLocationAndDepartmentFKs`.
- **`ForwardedByUsername` added to `CaseDto`**: after a forward is accepted, the assignee's dashboard shows a purple "Forwarded" badge on that case. `CaseDto.cs` + `CaseService.ToDto` (`ForwardedByUsername = customer.ForwardedBy?.Username`); web `employeeDashboard.js`; mobile `case_summary.dart` + `cases_view.dart`.
- **Accept forward navigates into the case**: web `cases.js` redirects to `case.html?id=…` on accept instead of reloading the list; mobile `forwarded_cases_view.dart` calls `Get.toNamed(Routes.caseDetail)` on success.
- **Case detail field label styling**: each field is now a self-contained card with a blue left border, the label rendered as tiny uppercase blue text (10.5 px, letter-spaced), and the value as medium-weight ink text — making label vs content immediately distinct. Web: `.detail-item` in `dashboard.css`; mobile: `_DetailRow` in `case_detail_view.dart` (outer `_DetailCard` wrapper removed; each row is its own container).
- **Forwarded to Me / Forwarded by Me nav items + visibility rules**. Added "Forwarded by Me" nav item (web + mobile). "Forwarded to Me" now shows both pending (Accept/Decline buttons) and accepted cases (stay after accept; disappear when re-forwarded onward). Cases with status `Success` or `Failed` are hidden from Employee/Manager in all list endpoints — Admin sees all. Admin can **Re-open** a completed case (sets status back to `Pending`, logs `CaseActionType.Reopened`). Backend: `CustomerRepository` new `GetForwardedByMeAsync` + `excludeCompleted` param on list methods; new `GET /api/cases/forwarded-by-me` + `POST /api/cases/{id}/reopen` (Admin only). Mobile: new `forwarded_by_me` module; `forwarded_cases_view` distinguishes pending vs accepted; `case_detail` adds Re-open for Admin.
- **Restored Forward workflow with Accept/Decline**. A case owner can forward to any active colleague. The recipient sees the case in a new "Forwarded to Me" list (nav item added web + mobile) with Accept and Decline buttons. Accept: transfers ownership + sets `ForwardedByUserId`. Decline: clears the pending forward (ownership stays). Both log a `CaseAction` (`ForwardAccepted`/`ForwardDeclined`) and send a notification back to the forwarder. Model: `Customer.PendingForwardToUserId` (int?, nullable) tracks the pending recipient; cleared on accept/decline. New DTO `ForwardDto`, new action types `ForwardAccepted`/`ForwardDeclined`, new notification types `ForwardAccepted`/`ForwardDeclined`. Migration `AddPendingForwardToCase`. Key files: `Customer.cs`, `CaseActionType.cs`, `NotificationType.cs`, `ForwardDto.cs`, `CaseDto.cs`, `CaseDetailDto.cs`, `AppDbContext.cs`, `ICustomerRepository.cs`/`CustomerRepository.cs`, `ICaseService.cs`/`CaseService.cs`, `CasesController.cs`; web: `api.js`, `nav.js`, `cases.js`, `case.js`, `dashboard.css`; mobile: `case_summary.dart`, `case_detail.dart`, `api_service.dart`, `nav_items.dart`, `app_routes.dart`, `app_pages.dart`, new `forwarded_cases/` module, `case_detail_controller.dart`, `case_detail_view.dart`, new `forward_dialog.dart`, `notification_center_controller.dart`.

### 2026-07-01

- **Follow-up dialog reworked — date removed from Pending/Success/Failed; date optional for Waiting; Success gains عيادات (Clinics) checkbox with doctor dropdown**. `FollowUpDto.cs`: `Date` changed from `[Required] DateTime` to `DateTime?`. `CaseService.FollowUpCoreAsync`: removed mandatory date check, `ActionDate` falls back to `UtcNow` when no date; Waiting sets `AppointmentDate` only if provided; Success now handles `HasDoctor` + optional `DoctorId` (clinics doctor, logged to timeline). Web `case.js`: modal restructured — date field (`#followup-date-field`) only visible for Waiting; new `#followup-clinics-field` checkbox + `#followup-clinics-doctor-field` only visible for Success; submit validation updated to drop the date requirement. `i18n.js`: `followUp.clinics` key added. Mobile `follow_up_dialog.dart`: same logic — `_appointmentDate` nullable, date picker only for Waiting, clinics checkbox + doctor for Success; translation files updated with `followUp.clinics`.
- **Bilingual (Arabic/English) i18n added — web frontend**. New `js/i18n.js`: full EN + AR translation map (~225 strings), `t(key, vars)` function, `applyTranslations()` DOM scanner (`data-i18n` / `data-i18n-html` / `data-i18n-placeholder` / `data-i18n-aria`), `setLang()` persists to `localStorage` and reloads the page. Language toggle button (`id="lang-toggle"`, class `btn-lang`) added to every page topbar (login page: absolute-positioned in `.form-panel`). All 9 HTML pages updated with `data-i18n` attributes and load `i18n.js` as the first script. All 10 JS files updated: `nav.js` uses `t(item.labelKey)` for nav items and `t('topbar.hi', {name})` for the greeting; every dynamically-rendered string in `employeeDashboard.js`, `adminDashboard.js`, `cases.js`, `case.js`, `newCase.js`, `manageLists.js`, `userManage.js`, `login.js`, `notifications.js` uses `t()`. CSS: `.btn-lang` + `.login-lang-toggle` added to `nav.css`; `.form-panel` gets `position: relative` in `styles.css`.
- **Bilingual (Arabic/English) i18n added to the mobile app**. GetX `Translations` wired up: `lib/app/translations/en_us.dart` + `ar_ar.dart` + `app_translations.dart`. `LanguageService` (`lib/app/data/services/language_service.dart`) persists the chosen locale in `SharedPreferences` and exposes `toggleLanguage()`. `main.dart`: `SharedPreferences` instance registered in GetX (`Get.put(prefs)`), `LanguageService` initialized before `runApp`, `GetMaterialApp` gains `translations`/`locale`/`fallbackLocale`. Language toggle (`lang.toggle`.tr) added to the bottom of `AppDrawer`. `NavItem.label` renamed to `labelKey` (now holds translation key). All user-visible hardcoded strings across every view, dialog, and widget replaced with `.tr` / `.trParams({…})`. API status values (`Pending`/`Waiting`/`Success`/`Failed`) left untouched on the wire; `caseStatusMeta` maps them to translated labels at display time. Key files changed: `main.dart`, `nav_items.dart`, `app_drawer.dart`, `app_top_bar.dart`, `status_pill.dart`, `confirm_dialog.dart`, `case_status.dart`, all views and dialogs under `modules/` (login, cases, new_case, case_detail, forwarded_cases, forwarded_by_me, notifications, manage_lists, users). `test/widget_test.dart` updated to supply required `initialLocale` param.
### 2026-07-01 (continued)

- **`NotifyOnNewCase` flag added to users — targeted new-case notifications**. `User.NotifyOnNewCase bool` (default false); migration `AddNotifyOnNewCase`. `CaseService.NotifyNewCaseAsync` now filters recipients to only those with `NotifyOnNewCase == true`. `UserDto` + `UpdateUserDto` expose the flag; `UserService.UpdateAsync` sets it. Web: checkbox `#user-notify-new-case` in the edit modal (`userManage.html` + `userManage.js`), hidden on Add (defaults false). Mobile: `AppUser.notifyOnNewCase` field; `CheckboxListTile` in `user_form_dialog.dart` (edit mode only); `UsersController.updateUser` + `ApiService.updateUser` pass the flag. Translation key `userForm.notifyNewCase` in `i18n.js` + both mobile translation files.
- **`HasPendingForward` field added to `CaseDto`** (`= PendingForwardToUserId.HasValue`) and `CaseSummary` in mobile — gives consumers an unambiguous "pending accept" signal regardless of who previously forwarded the case.
- **"Forwarded to Me" page: correct pending detection + badge labels**. `isPending` is now `c.hasPendingForward` (was `c.forwardedByUsername == null`, which broke when a case was re-forwarded back to its original owner). Re-forward detection: `c.forwardedByUsername == currentUser`. Web `cases.js`: pending 'in'-view cases now show a blue "Forwarded" badge; re-forwarded cases show only the actual status pill. Mobile `forwarded_cases_view.dart`: pending normal → blue "Forwarded" badge; re-forwarded (was originally mine) → no badge, just status; subtitle shows "Now with: X" instead of "From: X" for re-forwarded cases.

- **Clinic (عيادات) signature capture added to the Success follow-up flow**. When the عيادات checkbox is checked on a Success follow-up, the notes field is replaced by a required signature input. Web: file upload (`<input type="file" accept="image/*">`), read via `FileReader.readAsDataURL`, preview shown inline; `i18n.js` gains `followUp.signature/signatureChoose/signatureRequired` + `case.signature`. Mobile: `signature ^5.0.2` package added (`pubspec.yaml`); `SignatureController` in `follow_up_dialog.dart` renders a 200px finger-draw canvas (white background); on save, exported to PNG bytes → base64 data URL. Backend: `Customer.ClinicSignature string?` added; `FollowUpDto.SignatureData string?`; `CaseDetailDto.ClinicSignature string?`; `CaseService.FollowUpCoreAsync` validates signature is non-empty when `HasDoctor == true` on Success and writes it to `customer.ClinicSignature`; `ToDetailDto` maps it back. Migration `AddClinicSignature`. Display: web `renderCase()` shows an `<img>` tag from the data URL if `clinicSignature` is set; mobile `_DetailSignature` widget decodes base64 and renders `Image.memory`. Translation keys `followUp.signature`, `followUp.signatureRequired`, `case.signature` added to all four translation files.
- **iOS Codemagic IPA build prep**. Fixed `PRODUCT_BUNDLE_IDENTIFIER` in `ios/Runner.xcodeproj/project.pbxproj` — all 3 Runner configs changed from `com.example.crmsMobile` → `com.alamal.crms`; all 3 RunnerTests configs → `com.alamal.crms.RunnerTests`. Created `crms_mobile/ios/Podfile` (platform iOS 13.0, standard Flutter CocoaPods setup). Created `crms_mobile/ios/ExportOptions.plist` (ad-hoc distribution, no bitcode). Created `codemagic.yaml` at repo root with `ios-release` workflow (mac_mini_m2, managed `ios_signing`, ad-hoc) and `android-release` workflow (linux_x2). Backend republished: `dotnet publish -c Release -o D:\repos\crms\publish`.
