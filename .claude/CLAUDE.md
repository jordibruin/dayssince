# Days Since - Project Guide

## Overview

Days Since is a SwiftUI iOS app for tracking the number of days since important life events. Users organize events into color-coded categories, receive reminders, and display events on home screen widgets. No backend — all data is local.

App Store: https://apps.apple.com/us/app/days-since-track-memories/id1634218216

## Project Structure

```
DaysSince/                  # Main app target
├── DaysSinceApp.swift      # Entry point, TelemetryDeck init, manager setup
├── ContentView.swift       # Routes onboarding vs iCloud migration vs main app, WishKit config, legacy migration
├── Analytics.swift         # Analytics wrapper (AnalyticType enum + send method)
├── Model/                  # DSItem, Category, CategoryColor
├── Managers/               # Managers + their extracted pure logic (AppRoute, ExportFormatter,
│                           # ReminderRequestBuilder) and DI protocols (CategoryStore,
│                           # NotificationScheduling, PurchaseNotifying). New non-view code
│                           # belongs here: it is a synchronized group, so no pbxproj edit.
├── Migration/              # iCloudMigrationView (shown to existing users on first iCloud-enabled launch)
├── Extensions/             # Calendar, Color, Date, Defaults, Array, Binding, UIApplication
├── Settings/               # SettingsScreen, ThemeView, ColorThemeView, AppIcons
├── CategoriesViews/        # Category grid, filter, rectangle views
├── AddItemViews/           # Add event flow
├── EditItemViews/          # Edit event flow
├── Onboarding/             # Onboarding TabView pages
├── Supporter/              # Help, FAQ, changelog, contact support module
├── AppIcons/               # Alternate app icons
└── DaysSince/              # Nested folder with MainScreen views and additional model/extensions
    ├── MainScreen/         # MainScreen, TopSection, BottomSection, DSItemView, MenuBlockView
    └── Model/              # DSItemReminders, AlternativeIcon
Widget/                     # WidgetKit extension
├── Widget.swift            # Timeline providers and widget definitions
├── SingleEventWidgetView.swift
└── MultipleEventsWidgetView.swift
WidgetIntents/              # Widget intent configuration
```

## Tech Stack & Dependencies

- **UI**: 100% SwiftUI (no UIKit views)
- **Persistence**: Sindre Sorhus `Defaults` library (UserDefaults wrapper) — preferred over raw UserDefaults
- **Analytics**: TelemetryDeck SDK (app ID: `FBE58244-22B0-4207-9ED7-052DEB5B8A26`)
- **Feedback**: WishKit-iOS for feature requests/voting (project ID: `6443C4AA-4663-4A27-89E5-846598908A4E`)
- **Widgets**: WidgetKit with App Groups (`group.goodsnooze.dayssince`)
- **Notifications**: UNUserNotificationCenter for local reminders
- **Reviews**: StoreKit for app review prompts (once per version)
- **iCloud Sync**: NSUbiquitousKeyValueStore (iCloud Key-Value Store) via `DataSyncManager`
- **No backend, no CoreData/SwiftData, no CloudKit**

## Data Layer

### Persistence Strategy
- **App settings & categories**: Use `Defaults` library with `@Default` property wrapper
- **Items (events)**: Owned by `DataSyncManager`, dual-written to App Group UserDefaults + iCloud KVS
- **Widget shared data**: `UserDefaults(suiteName: "group.goodsnooze.dayssince")` — widgets read from here (unchanged)
- All models are `Codable` structs serialized to UserDefaults
- **Critical**: `@AppStorage` with arrays uses `RawRepresentable` (via `Array+Extensions.swift`) which stores arrays as **JSON strings**, not `Data`. Any code reading items from UserDefaults must use `.string(forKey:)` + `.data(using: .utf8)`, NOT `.data(forKey:)`. The latter returns nil for string values and causes data loss.

### iCloud Sync (DataSyncManager)
- Uses `NSUbiquitousKeyValueStore` (iCloud Key-Value Store) — 1 MB hard limit, last-writer-wins
- **DataSyncManager** (`DaysSince/Managers/DataSyncManager.swift`) is the central sync coordinator
  - Owns `@Published var items` and `@Published var categories`
  - On local write: dual-writes to App Group UserDefaults (for widgets) AND KVS (for iCloud)
  - On remote change: applies iCloud data locally, mirrors to App Group UserDefaults
  - Never overwrites non-empty local items with empty remote items (safety guard)
- **Sync flow on launch (`startSync()`):**
  - If local items are empty (fresh install/reinstall): restores from iCloud, sets `iCloudMigrationComplete = true`
  - If local items exist: pushes to iCloud
- **Migration for existing users:** `iCloudMigrationView` shown when `hasSeenOnboarding && !iCloudMigrationComplete`
- **Storage warning:** Alerts user when approaching 950 KB of the 1 MB KVS limit
- iCloud KVS keys: `"items"` for events, `"icloud_categories"` for categories
- `KeyValueStoreProtocol` abstracts KVS for testability

### Codable Compatibility (DSItem & Category)
- Both DSItem and Category have custom `init(from decoder:)` in extensions (preserves memberwise init)
- Uses `decodeIfPresent` with defaults for fields added after initial release (`lastModified`, `stableID`, etc.)
- **Important**: Swift's auto-synthesized Decodable does NOT use default property values as fallbacks for missing keys. Any new field added to DSItem or Category MUST use `decodeIfPresent` in the custom decoder, or existing stored data will fail to decode silently (`try?` returns nil).

### Key Models
- **`DSItem`**: id, name, category, dateLastDone, remindersEnabled, reminder, reminderNotificationID, lastModified. Computed: `daysAgo`
- **`Category`**: id (UUID), stableID (String), name, emoji, color (CategoryColor). Conforms to `Defaults.Serializable`
  - **`stableID`** is the stable persistent identity (foreign key). Equality and hashing use `stableID`, NOT `id`.
  - Built-in categories have hardcoded stableIDs: `"work"`, `"life"`, `"hobby"`, `"health"`, `"home"`, `"pet"`, `"friends"`, `"projects"`, `"journal"` (constants on `Category`)
  - User-created categories get `UUID().uuidString` as stableID at creation time
  - Custom decoder handles migration from pre-stableID data: maps known built-in names to their well-known stableIDs, generates a UUID string for unknown categories
  - **When creating built-in categories**, always pass the corresponding `Category.stableID*` constant. Never create a built-in category without its stableID.
- **`CategoryColor`**: 10 cases (work, life, health, hobbies, marioBlue, zeldaYellow, animalCrossingsGreen, marioRed, animalCrossingsBrown, black)
- **`DSItemReminders`**: daily, weekly, monthly, none

### Defaults Keys (in Defaults+Extension+Colors.swift)
- `.mainColor`, `.backgroundColor`, `.selectedThemeId`, `.categories`

## State Management (MVVM-lite)

- **`@StateObject`** for managers at top-level (DaysSinceApp)
- **`@EnvironmentObject`** to pass managers down the view hierarchy
- **`@Binding`** for parent-to-child data flow (items arrays)
- **`@Default`** for persistent Defaults values
- **`@AppStorage`** for UserDefaults-backed state
- **`@State`** for local view state
- Uses older `ObservableObject` + `@Published` pattern (not @Observable)

### Managers
- **DataSyncManager**: Central data coordinator — owns items/categories, syncs to iCloud KVS and App Group UserDefaults. Injected as `@EnvironmentObject`.
- **CategoryManager**: Category CRUD, drag-and-drop reordering, fires analytics on add/update. Has `weak var dataSyncManager` reference for triggering iCloud sync.
- **NotificationManager**: Schedules daily/weekly/monthly reminders at 10:00 AM. Receives items externally via `refreshNotifications(items:)`.
- **ReviewManager**: Prompts StoreKit review once per app version. `presentReview` returns whether the sheet was actually shown — StoreKit declines silently without a foreground-active window scene, and `.reviewPrompt` analytics must not claim a prompt that never happened. Note the stored version advances even on a decline, which spends that version's single chance (pinned by `ReviewManagerTests`, not a fix).

## Analytics

Always fire analytics for user actions. Use the `Analytics.send()` wrapper:

```swift
Analytics.send(.addNewEvent, with: ["remindersEnabled": String(remindersEnabled)])
```

Tracked events: `launchApp`, `addNewEvent`, `editEvent`, `updateCategory`, `addNewCategory`, `chooseIcon`, `chooseTheme`, `settingsReview`, `reviewPrompt`, `detailedModeOn`, `iCloudMigrationStarted`, `iCloudMigrationCompleted`, `iCloudSyncConflict`, `iCloudDataSize`

## Design System

### Fonts
- **Always use `.rounded` design**: `.font(.system(.title2, design: .rounded))`
- Title/item names: `.title2` + `.bold()`
- Section headers: `.headline` + `.bold()`
- Numeric values: `.title3` + `.bold()`
- Labels/captions: `.caption`
- Body text: `.body`
- Widget text uses minimum scale factor 0.6–0.7

### Colors
- Custom colors defined in `Color+Extensions.swift`: workColor, lifeColor, hobbiesColor, healthColor, peachLightPink, peachDarkPink, marioBlue, marioRed, zeldaGreen, zeldaYellow, animalCrossingsBrown, animalCrossingsGreen, backgroundColor
- Color utilities: `.lighter(by:)`, `.darker(by:)`, `.mix(with:amount:)`
- 11 color themes defined in ThemeView.swift (default, blackWhite, health, life, hobbies, zelda, blackDefaultBackground, marioRedBlue, peachPink, marioRed, animalCrossings)
- Dark mode: `Color(.systemBackground)`. Light mode: LinearGradient of backgroundColor at 45° angle

### Shapes & Corner Radii
- **Primary cards/blocks**: `cornerRadius: 20` (DSItemView, MenuBlockView, text fields, emoji buttons)
- **Color themes**: `cornerRadius: 24`
- **Background containers**: `cornerRadius: 16`
- **Color picker buttons**: `cornerRadius: 8`
- **Dividers**: `cornerRadius: 4`
- **App icons**: `cornerRadius: 20` with `.continuous` style
- **Widgets**: `.clipShape(ContainerRelativeShape())`
- Prefer `RoundedRectangle(cornerRadius:)` with `.clipShape()`

### Shadows
- DSItem cards: `shadow(color: .black.opacity(0.05), radius: 20, x: 0, y: 0)`
- MenuBlock: `shadow(color: accentColor.opacity(0.4), radius: 5, x: 0, y: 5)`

### Gradients
- Buttons/blocks: `LinearGradient(colors: [mainColor, mainColor.lighter()], startPoint: .topLeading, endPoint: .bottomTrailing)`
- Background: diagonal gradient from `.opacity(0.6)` to full color

### Opacity Conventions
- Light tint backgrounds: `.opacity(0.16)`
- Subtle backgrounds: `.opacity(0.1)`
- Secondary text: `.opacity(0.6)`
- Labels/hints: `.opacity(0.4)`
- Drag indicators: `.opacity(0.5)`

### Spacing
- Container padding: default `padding()` (~16pt)
- Horizontal content: 16–32pt
- VStack spacing: 0, 2, 4, 6, 12, 20
- HStack spacing: 0, 6
- Grid item spacing: 10–24pt

### DSItemView (main event card)
- Colored background with 3pt border stroke
- RoundedRectangle cornerRadius 20
- Subtle shadow
- Supports simple (days only) and detailed (years/months/days) display

### MenuBlockView (category pill in top scroll)
- Square aspect ratio (1.0)
- LinearGradient background with category color
- Shadow colored by category

## Navigation
- **Onboarding**: TabView with `.page` style (Introduction → CreateFirstEvent)
- **Main app**: NavigationView wrapping MainScreen
- **Modal sheets**: AddItem, EditItem, Settings, ThemeView, AddCategory
- **Settings navigation**: NavigationLinks to sub-views (AppIcons, etc.)

## Widgets
- **SingleEventWidget**: systemSmall, systemMedium, accessoryCircular/Inline/Rectangular
- **MultipleEventsWidget**: systemMedium, systemLarge (up to 5 events)
- Data from shared App Group UserDefaults
- Timeline policy: `.atEnd`
- Border: 4pt stroke with event color

## Naming Conventions
- Model prefix: `DS` (Days Since) — `DSItem`, `DSItemReminders`
- Views: `ScreenName.swift` or `ComponentNameView.swift`
- Managers: `*Manager.swift`
- Extensions: `Type+Extensions.swift` or `Type+Extension+Feature.swift`
- Color names: descriptive game/theme references (marioBlue, zeldaYellow, animalCrossingsGreen)

## Testing

### Framework
- **Swift Testing** (`import Testing`) is the standard for all tests. Do not add new XCTest files. Use `@Suite` / `@Test` / `#expect` / `try #require`, and `@Test(arguments:)` for table-driven cases.
- XCTest remains only for UI tests (`DaysSinceUITests`), because XCUITest has no Swift Testing equivalent.

### Targets
- `DaysSinceTests` — unit tests, hosted by the app
- `DaysSinceUITests` — XCUITest target
- Both are `PBXFileSystemSynchronizedRootGroup`s: **files added under those folders are compiled automatically. Never hand-edit the .pbxproj to add a test file.**

### Running
- `Scripts/test.sh --unit-only` — 299 unit tests in ~5 seconds. This is the default while iterating.
- `Scripts/test.sh --ui-only` / `Scripts/test.sh` — the UI suites cost ~20 minutes serially, which is
  all app launches and UI settling, not test logic. Don't run them on every edit: run the one suite
  covering what you touched (`-only-testing:DaysSinceUITests/ThemeTests`), and the full set before a
  release. CI runs the unit target on every PR and the UI target only on `workflow_dispatch`.
- The script resolves the simulator udid itself; override with `DEVICE_NAME` / `OS_VERSION` / `SIMULATOR_ID`.
- Or Cmd+U in Xcode with the DaysSince scheme

### Test isolation (this is the anti-flake contract)
Swift Testing runs tests **in parallel by default**, and this app keeps a lot of state in `UserDefaults.standard` via `Defaults[...]`, `@Default`, and `@AppStorage`. Pick a tier per suite:
- **Pure** — models, extensions, sorting, formatting. No traits, fully parallel. Keep this tier as large as possible by extracting pure functions out of views/managers.
- **Injected suite** — inject a per-test `UserDefaults` suite via `IsolatedDefaults`. Parallel-safe.
- **Global** — only when a suite genuinely must touch process-global state (`.standard`, `Analytics.sink`, `SKTestSession`). Declare it nested inside `GlobalStateSuite` (`extension GlobalStateSuite { @Suite struct ... }`), which carries `.serialized`, and save/restore whatever it mutates in `init`/`deinit` (see `DataSyncManagerMergeTests`). `.serialized` does **not** serialize across sibling top-level suites — that is why the umbrella exists, so never declare a global-state suite at top level.

### Shared support layer — `DaysSinceTests/Support/`
- `IsolatedDefaults` — per-test `UserDefaults` suite that deletes its persistent domain on `deinit`. Always use this instead of creating a suite inline, or every run leaks a plist into the test host container.
- `Fixtures` — `Fixtures.item(...)`, `Fixtures.category(...)`, fixed reference dates, `gmtCalendar`. Never build fixtures from `Date.now`: `DSItem.daysAgo` uses `Calendar.current` internally, so dates near midnight make assertions flaky.
- `Mocks/MockKeyValueStore` — in-memory `KeyValueStoreProtocol`. Support types must **not** be declared `private` in a test file; a file-private type still occupies module scope and collides with the shared one.
- `Mocks/SpyAnalytics` + `withAnalyticsSpy { spy in ... }` — swaps `Analytics.sink` for the duration of the closure and restores it afterwards. Production code keeps calling `Analytics.send(...)`, so no call site changes.
- `Mocks/MockCategoryStore`, `Mocks/SpyWidgetReloader` (+ `StubUbiquityChecker`), `Mocks/MockNotificationScheduler`, `Mocks/SpyPurchaseNotifier` — doubles for the manager DI seams. `MockNotificationScheduler` fires every completion **synchronously**, so assert on the mock rather than on `NotificationManager.pendingNotifications`, which is published via `DispatchQueue.main.async`. `SpyPurchaseNotifier` keeps tests from POSTing to the live ntfy topic.
- `LegacyPayloads` — builds legacy JSON by encoding a real model and *removing* keys, so fixtures stay honest as the models change. Don't hand-write stored-shape JSON.

### StoreKit tests
- Products come from `Configuration/DaysSince.storekit` (weekly $2.99 with a 1-week free trial, monthly $4.99, annual $19.99, one subscription group). It is a **resource of `DaysSinceTests`**, which is what lets `SKTestSession(configurationFileNamed: "DaysSince")` find it. The `DaysSince` scheme's Run action points at it too, so the paywall works when running the app locally.
- Always construct `SubscriptionManager` with `autoStart: false` in tests, or each instance leaks a `Transaction.updates` task that outlives the test.
- `SKTestSession` mutations reach `Transaction.currentEntitlements` **asynchronously**. Drain entitlements (poll until empty) before asserting, or the suite passes on one run and fails the next.
- **Never assign `session.failTransactionsEnabled`.** The setter wedges the session: writing even `false` makes the next `purchase()` throw `StoreKitError.unknown`, so a test built on it passes for the wrong reason while breaking every other purchase in the process. `askToBuyEnabled` is safe to assign.
- `expireSubscription(productIdentifier:)` and `refundTransaction(identifier:)` are silent no-ops here (the transaction keeps a future expiry and a nil revocation date). Simulate losing access with `clearTransactions()`, which is the same thing our code sees: an empty `currentEntitlements`.

### UI tests (`DaysSinceUITests`)

XCTest + page objects ("robots") under `Robots/`, shared harness in `Support/`. Every test class and robot is `@MainActor`.

**Launch harness** — `TestHooks.swift` (app target) reads the flags; `UITestCase.launch(...)` passes them.
- `-uiTest` is passed on every launch and means "this is a UI test run": wipe `UserDefaults.standard` + the App Group, swap `NSUbiquitousKeyValueStore` for an in-memory `KeyValueStoreProtocol`, skip `TelemetryDeck`/`WishKit`/ntfy, stub the notification permission prompt, suppress the StoreKit review alert, disable animations. **Never point a UI test at the real KVS** — it holds real data on the dev iCloud account, and a UI-test write would push junk into it.
- Per-test opt-ins: `-seedDemoData` (16 events / 9 categories — mirrored in `Support/SeedData.swift`), `-showOnboarding`, `-showICloudMigration`, `-showPaywall`, `-keepState` (skip the reset, for relaunch assertions), `UITEST_SUBSCRIBED=0|1`.
- The state reset must be the **first statement of `DaysSinceApp.init()`**: `@StateObject` property initializers run before the init body, so `dataSyncManager` has no default value and is constructed inside `init()`.

**Accessibility identifiers** — `screen.element[.qualifier]`, with data-derived suffixes: `event.name.<name>`, `event.days.<name>`, `category.pill.<name>`, `sort.<SortType.rawValue>`, `theme.<id>`, `paywall.product.<productID>`.

**Gotchas that cost real debugging time:**
- A SwiftUI `Toggle` in a `Form` publishes the **whole row** as the `Switch`, so its centre is the label and `tap()` silently changes nothing. Use `XCUIElement.flipSwitch()`, which taps the trailing edge by coordinate.
- Segmented `Picker` segments are `Button`s addressed by **label text** ("Daily"/"Weekly"/"Monthly"), and expose `isSelected`.
- A `Form` row below the fold does not exist in the hierarchy at all — scroll to it (`app.scrollTo(_:)`), don't just wait.
- The category strip is a `LazyHStack`: a pill past the fold genuinely doesn't exist yet. This looks exactly like a data bug. Use `MainScreenRobot.scrollToCategory(_:)`.
- `app.scrollViews.firstMatch` is **not** the horizontal strip — the full-screen vertical event list precedes it and also contains the pills, so swiping it scrolls nothing and fails silently. Pick the strip by frame height.
- Querying `isHittable` on an element whose frame lies outside the window **raises** ("activation point invalid") instead of returning false, so horizontal scroll loops compare `app.frame.contains(element.frame)`.
- After a data change, `ForEach` children are replaced wholesale — re-query elements, never cache an `XCUIElement`, and poll for the expected ordering (see `SortingTests.awaitOrder`).
- `NavigationStack` keeps earlier pages in the hierarchy, so onboarding needs per-screen identifiers rather than one shared "Continue".
- The graphical `DatePicker` has no addressable field — set dates through the event context menu's Today/Yesterday or through seeded data.

**Running** — use `Scripts/test.sh --ui-only`. It runs **4 parallel simulator clones** (~8 min for all
54 tests, vs ~19 serial). Parallel testing is safe for the UI target despite the launch-time state
reset: each clone is a separate device with its own app container and App Group, so nothing leaks
between them — verified with all 54 green across 4 clones. An earlier note in this file claimed the
opposite; it was wrong. Drop to `UI_PARALLEL=NO` only to make a failure easier to read, since
parallel output interleaves and reports as `passed on 'Clone N of ...'` rather than `Test Case '-[...]'`.

**Never parallelize the unit target.** `-parallel-testing-enabled` is per-invocation, not per-target,
so the script runs the two targets as two invocations. Under a clone,
`GlobalStateSuite/AnalyticsEnvironmentTests/isSimulatorOrTestFlightUnderTest` fails, because
`isSimulatorOrTestFlight()` reads `Bundle.main.appStoreReceiptURL` and a clone's differs. The unit
suite is ~5 seconds serially, so there is nothing to gain anyway.

The destination is always an explicit `id=`: `name` + `OS=latest` is ambiguous with both iOS 26.0 and
26.1 installed. Unit tests are Swift Testing, so they log `✔`/`✘` — a grep for `Test Case` silently
matches none of them and makes a green unit run look like it never happened.

### Conventions
- Use `DaysSince.Category` (fully qualified) to avoid ambiguity with the system `Category` type
- `@testable import DaysSince` for access to internal types
- Items are persisted as JSON **strings**, so write test fixtures with `.set(jsonString, forKey:)` and read with `.string(forKey:)` — `.data(forKey:)` returns nil and silently produces empty results

## Build & Run
- Xcode project (DaysSince.xcodeproj), not SPM-based
- SPM dependencies resolved via Xcode
- App Group entitlement: `group.goodsnooze.dayssince`
- iCloud Key-Value Store entitlement: `$(TeamIdentifierPrefix)com.goodsnooze.dayssince`
- Alternate icons configured via `.icon` asset packages

## User Scenarios & Migration States

The app handles 3 user states via `hasSeenOnboarding` and `iCloudMigrationComplete` (both `@AppStorage`). The decision itself lives in `AppRoute.route(hasSeenOnboarding:iCloudMigrationComplete:)` (`Managers/AppRoute.swift`), which `ContentView.body` switches over — **change the table here and `RoutingTests` together, they pin each other.**

| State | hasSeenOnboarding | iCloudMigrationComplete | Result |
|-------|-------------------|-------------------------|--------|
| New user | false | false | Onboarding → sets both to true |
| Existing user, first iCloud launch | true | false | iCloudMigrationView → migrates data to iCloud |
| Reinstall (iCloud data exists) | false | true (set by startSync) | Onboarding (iCloud data already restored) |
| Normal launch | true | true | MainScreen |

**Reinstall flow**: On app deletion, UserDefaults is wiped but iCloud KVS persists. On reinstall, `startSync()` detects empty local items, restores from iCloud, and sets `iCloudMigrationComplete = true`. The user still goes through onboarding (`hasSeenOnboarding` was wiped). `CategoryPage.nextPage()` appends only the selections whose `stableID` is not already stored, so iCloud-restored categories survive — a selection matching a restored built-in is dropped rather than duplicated.

**Legacy migration (`oldDSItem`)**: ContentView still declares `@AppStorage("items") var oldItems: [oldDSItem]` for migrating from the old item format (which used `CategoryDSIte` enum). This shares the same `"items"` key as current items, so it always fails to decode (logging a `typeMismatch` error) and evaluates to `[]`. The migration is guarded by `migratedFromOld` flag. This is dead code for any user who has already launched the current app version and can be removed in a future cleanup.
