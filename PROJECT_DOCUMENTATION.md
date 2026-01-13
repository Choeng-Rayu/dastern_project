# DasTern Project - Comprehensive Documentation

## 📱 Project Overview

**DasTern** is a **Medication Reminder Mobile Application** built with Flutter. It helps patients manage their medications by providing timely reminders, tracking intake history, and maintaining a personal health profile.

### Key Features
- 🔐 User Authentication (Login/Registration)
- 💊 Medication Management (CRUD operations)
- ⏰ Smart Reminders with Native Notifications
- 📊 Intake History Tracking & Statistics
- 🌙 Dark/Light Theme Support
- 🌏 Multi-language Support (English & Khmer)
- 📱 Cross-platform (Android, iOS, Web, Desktop)

---

## 🏗️ Project Architecture

### Layered Architecture Pattern

The project follows a **clean layered architecture** that separates concerns and improves maintainability:

```
lib/
├── main.dart                 # Entry point - initializes services & providers
├── app.dart                  # Root widget - routing, theming, localization
├── models/                   # DATA LAYER - Business entities
│   ├── patient.dart
│   ├── medication.dart
│   ├── reminder.dart
│   ├── intakeHistory.dart
│   ├── generateId.dart
│   └── enum/
│       └── blood.dart
├── services/                 # SERVICE LAYER - Business logic & external services
│   ├── storage_service.dart
│   └── notification_service.dart
├── presentation/             # PRESENTATION LAYER - UI components
│   ├── providers/            # State management
│   │   ├── auth_provider.dart
│   │   ├── medication_provider.dart
│   │   ├── reminder_provider.dart
│   │   ├── intake_history_provider.dart
│   │   └── settings_provider.dart
│   ├── screens/              # Full-page widgets
│   │   ├── welcome_screen.dart
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── medications_screen.dart
│   │   ├── medicine_form_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── today_reminders_screen.dart
│   │   ├── intake_history_screen.dart
│   │   └── main_navigation_screen.dart
│   ├── widget/               # Reusable UI components
│   │   ├── gradient_background.dart
│   │   ├── health_metric_widget.dart
│   │   ├── in_app_notification.dart
│   │   ├── medication_card_widget.dart
│   │   ├── medicine_schedule_item_widget.dart
│   │   ├── today_schedule_widget.dart
│   │   └── weight_card_widget.dart
│   ├── theme/                # Centralized theming
│   │   └── theme.dart
│   └── layout/               # Layout components
│       └── app_layout.dart
└── l10n/                     # LOCALIZATION - Multi-language support
    ├── app_en.arb
    ├── app_km.arb
    ├── app_localizations.dart
    ├── app_localizations_en.dart
    └── app_localizations_km.dart
```

### Architecture Layers Explained

| Layer | Purpose | Files |
|-------|---------|-------|
| **Data Layer (Models)** | Define business entities with JSON serialization | `patient.dart`, `medication.dart`, `reminder.dart`, `intakeHistory.dart` |
| **Service Layer** | Handle external operations (storage, notifications) | `storage_service.dart`, `notification_service.dart` |
| **State Management (Providers)** | Manage application state with ChangeNotifier | All `*_provider.dart` files |
| **Presentation Layer** | UI screens and reusable widgets | `screens/`, `widget/`, `theme/` |
| **Localization** | Multi-language support | `l10n/` directory |

---

## 📦 Dependencies (Packages Used)

### pubspec.yaml Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # State Management
  provider: ^6.1.2              # ChangeNotifier-based state management

  # Navigation
  go_router: ^14.6.2            # Declarative routing with deep linking

  # Localization
  intl: ^0.20.2                 # Internationalization utilities

  # Persistence
  shared_preferences: ^2.2.3    # Key-value local storage
  uuid: ^4.5.2                  # Unique ID generation

  # Notifications
  flutter_local_notifications: ^18.0.1  # Native push notifications
  timezone: ^0.9.4              # Timezone handling for scheduled notifications

  # UI
  cupertino_icons: ^1.0.8       # iOS-style icons

dev_dependencies:
  flutter_lints: ^4.0.0         # Linting rules
  device_preview: ^1.2.0        # Test on different device sizes
```

### Package Purposes

| Package | Purpose | Usage in Project |
|---------|---------|------------------|
| **provider** | State management | All 5 providers use `ChangeNotifier` for reactive state |
| **go_router** | Navigation | Declarative routing with guards for auth protection |
| **shared_preferences** | Local storage | Persists user data, medications, reminders, history |
| **uuid** | ID generation | Creates unique IDs for all entities |
| **flutter_local_notifications** | Notifications | Schedules medication reminders |
| **timezone** | Time handling | Ensures notifications fire at correct local times |
| **intl** | Localization | Date formatting, multi-language support |
| **device_preview** | Testing | Preview UI on different screen sizes (dev only) |

---

## 🗃️ Data Models

### 1. Patient Model (`models/patient.dart`)

Represents a user/patient in the system.

```dart
class Patient {
  final String id;           // Unique identifier (UUID)
  final String name;         // Patient's full name
  final DateTime dateOfBirth; // Birth date for age calculation
  final String? address;     // Optional address
  final String tel;          // Phone number (used for login)
  final String? bloodtype;   // Blood type (A+, B-, O+, etc.)
  final String? familyContact; // Emergency contact
  final double? weight;      // Weight in kg

  // Computed property
  int get age;               // Calculates age from dateOfBirth
  
  // JSON serialization
  Map<String, dynamic> toJson();
  factory Patient.fromJson(Map<String, dynamic> json);
  
  // Immutable updates
  Patient copyWith({...});
}
```

### 2. Medication Model (`models/medication.dart`)

Represents a medication prescribed to the patient.

```dart
// Dosage unit enum
enum Unit { tablet, ml, mg, other }

// Dosage value object
class Dosage {
  final double amount;  // e.g., 500
  final Unit unit;      // e.g., mg
}

class Medication {
  final String id;           // Unique identifier
  final String name;         // Medicine name (e.g., "Paracetamol")
  final Dosage dosage;       // Amount and unit
  final String instruction;  // How to take (e.g., "After meals")
  final String prescribeBy;  // Doctor's name
  final Color? color;        // UI display color
  final IconData? icon;      // UI display icon
  
  // JSON serialization & copyWith included
}
```

### 3. Reminder Model (`models/reminder.dart`)

Represents a scheduled reminder for taking medication.

```dart
// Time of day categories
enum MedicationTimeOfDay { morning, afternoon, evening, night, other }

// Days of the week
enum WeekDay { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

class Reminder {
  final String id;                    // Unique identifier
  final String medicationId;          // Links to Medication
  final DateTime time;                // Specific time (hour:minute)
  final int dosageAmount;             // How many tablets/units
  final MedicationTimeOfDay timeOfDay; // Category (morning, etc.)
  final List<WeekDay> activeDays;     // Which days to remind
  final bool isActive;                // Toggle on/off

  // Helper method
  bool shouldFireToday();  // Checks if reminder should fire today
}
```

### 4. IntakeHistory Model (`models/intakeHistory.dart`)

Tracks medication intake status.

```dart
enum IntakeStatus { pending, missed, skipped, taken }

class IntakeHistory {
  final String id;              // Unique identifier
  final String medicationId;    // Links to Medication
  final String reminderId;      // Links to Reminder
  final DateTime scheduledTime; // When it was supposed to be taken
  final DateTime? takenAt;      // When actually taken (null if not taken)
  final IntakeStatus status;    // Current status
}
```

### Entity Relationship Diagram

```
┌─────────────┐
│   Patient   │
│─────────────│
│ id          │
│ name        │
│ tel         │◄──────────────┐
│ dateOfBirth │               │
│ bloodtype   │               │
│ weight      │               │
└─────────────┘               │
                              │ (stored by phone)
┌─────────────┐               │
│ Medication  │───────────────┘
│─────────────│
│ id          │◄──────────────┐
│ name        │               │
│ dosage      │               │
│ instruction │               │
│ prescribeBy │               │
└─────────────┘               │
       │                      │
       │ 1:N                  │ N:1
       ▼                      │
┌─────────────┐               │
│  Reminder   │               │
│─────────────│               │
│ id          │◄──────────────┼───────────┐
│ medicationId│───────────────┘           │
│ time        │                           │
│ dosageAmount│                           │
│ activeDays  │                           │
│ isActive    │                           │
└─────────────┘                           │
       │                                  │
       │ 1:N                              │
       ▼                                  │
┌──────────────┐                          │
│IntakeHistory │                          │
│──────────────│                          │
│ id           │                          │
│ medicationId │                          │
│ reminderId   │──────────────────────────┘
│ scheduledTime│
│ takenAt      │
│ status       │
└──────────────┘
```

---

## 🔧 Services Layer

### 1. StorageService (`services/storage_service.dart`)

Handles all local data persistence using `SharedPreferences`.

**Key Features:**
- User-specific data isolation (data keyed by phone number)
- CRUD operations for all entities
- Credential verification for login
- Session management (login state)

**Storage Keys Pattern:**
```dart
String _getUserDataKey(String userPhone) => 'user_data_$userPhone';
String _getPasswordKey(String userPhone) => 'user_password_$userPhone';
String _getMedicationsKey(String userPhone) => 'medications_$userPhone';
String _getRemindersKey(String userPhone) => 'reminders_$userPhone';
String _getIntakeHistoriesKey(String userPhone) => 'intake_histories_$userPhone';
```

**Key Methods:**
| Method | Purpose |
|--------|---------|
| `saveUserData(patient, password)` | Registers/updates user |
| `verifyCredentials(phone, password)` | Validates login |
| `saveMedications(List<Medication>)` | Persists medications |
| `getMedications()` | Retrieves medications |
| `saveReminders(List<Reminder>)` | Persists reminders |
| `getReminders()` | Retrieves reminders |
| `saveIntakeHistories(List<IntakeHistory>)` | Persists history |
| `getIntakeHistories()` | Retrieves history |
| `clearAuthData()` | Logs out user (preserves data) |

### 2. NotificationService (`services/notification_service.dart`)

Handles native push notifications using `flutter_local_notifications`.

**Key Features:**
- Singleton pattern for global access
- Timezone-aware scheduling (Asia/Phnom_Penh)
- iOS & Android permission handling
- Immediate and scheduled notifications
- Notification tap handling

**Key Methods:**
| Method | Purpose |
|--------|---------|
| `initialize()` | Sets up notification channels |
| `scheduleReminder(...)` | Schedules a future notification |
| `cancelReminder(id)` | Cancels a specific notification |
| `cancelAllReminders()` | Clears all scheduled notifications |
| `scheduleRemindersForToday(reminders, medications)` | Batch schedule today's reminders |
| `showNotification(title, body)` | Shows immediate notification |

---

## 🔄 State Management (Providers)

All providers extend `ChangeNotifier` and follow a consistent pattern:

```dart
class XxxProvider extends ChangeNotifier {
  List<Xxx> _items = [];
  bool _isLoading = true;
  
  List<Xxx> get items => _items;
  bool get isLoading => _isLoading;
  
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    _items = await _storageService.getXxx();
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> addItem(Xxx item) async {
    _items.add(item);
    await _storageService.saveXxx(_items);
    notifyListeners();
  }
  // ... update, delete methods
}
```

### 1. AuthProvider (`presentation/providers/auth_provider.dart`)

**Purpose:** Manages user authentication state.

**State:**
- `isLoggedIn` - Whether user is authenticated
- `currentPatient` - Current user's Patient data
- `isLoading` - Auth initialization status

**Key Features:**
- **Bypass Account:** Demo login (Phone: `012345678`, Password: `demo123`)
- Auto-creates demo account on first run
- Session persistence across app restarts

**Methods:**
- `initialize()` - Loads auth state from storage
- `login(phone, password)` - Authenticates user
- `register(patient, password)` - Creates new user
- `logout()` - Clears session
- `updatePatient(patient)` - Updates user profile

### 2. MedicationProvider (`presentation/providers/medication_provider.dart`)

**Purpose:** Manages the list of user's medications.

**Methods:**
- `getMedicationById(id)` - Find specific medication
- `addMedication(medication)` - Add new medication
- `updateMedication(medication)` - Update existing
- `deleteMedication(id)` - Remove medication
- `clearAllMedications()` - Remove all

### 3. ReminderProvider (`presentation/providers/reminder_provider.dart`)

**Purpose:** Manages medication reminders.

**Key Features:**
- Auto-generates 3 reminders per medication (morning, afternoon, evening)
- Links reminders to medications via `medicationId`

**Methods:**
- `getRemindersForMedication(medicationId)` - Get medication's reminders
- `getTodayReminders()` - Get reminders active today
- `autoGenerateReminders(medication)` - Create default reminders
- `toggleReminderActive(id)` - Enable/disable reminder
- `deleteRemindersForMedication(id)` - Cascade delete

### 4. IntakeHistoryProvider (`presentation/providers/intake_history_provider.dart`)

**Purpose:** Tracks medication intake and statistics.

**Methods:**
- `getTodayHistories()` - Get today's intake records
- `getTodayPendingIntakes()` - Get pending for today
- `getTodayCompletedIntakes()` - Get completed today
- `getStatistics(startDate, endDate)` - Get counts by status
- `getAdherenceRate(startDate, endDate)` - Calculate compliance %
- `generateTodayIntakes(reminders)` - Create today's records
- `markAsTaken(id)` - Mark medication as taken
- `markAsSkipped(id)` - Mark as skipped
- `updateMissedIntakes()` - Auto-mark past pending as missed

### 5. SettingsProvider (`presentation/providers/settings_provider.dart`)

**Purpose:** Manages app settings (theme, locale).

**State:**
- `themeMode` - Current theme (light/dark/system)
- `locale` - Current language (en/km)

**Methods:**
- `setThemeMode(mode)` - Change theme
- `setLocale(locale)` - Change language
- `toggleTheme()` - Quick toggle light/dark

---

## 🧭 Navigation (Routing)

Uses **go_router** for declarative, type-safe routing.

### Route Structure

```dart
GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    // Auth guard logic
    if (!isLoggedIn && !isAuthRoute) return '/';
    if (isLoggedIn && isAuthRoute) return '/dashboard';
    return null;
  },
  routes: [
    GoRoute(path: '/', builder: WelcomeScreen),
    GoRoute(path: '/login', builder: LoginScreen),
    GoRoute(path: '/register', builder: RegisterScreen),
    
    // Main app with bottom navigation
    StatefulShellRoute.indexedStack(
      branches: [
        StatefulShellBranch(routes: ['/dashboard']),
        StatefulShellBranch(routes: ['/medicine-list']),
        StatefulShellBranch(routes: ['/medicine-form']),
        StatefulShellBranch(routes: ['/profile']),
      ],
    ),
    
    // Standalone screens
    GoRoute(path: '/today-reminders'),
    GoRoute(path: '/intake-history'),
  ],
)
```

### Navigation Flow

```
App Start
    │
    ▼
┌──────────────┐
│WelcomeScreen │ (if not logged in)
│  /           │
└──────┬───────┘
       │
   ┌───┴───┐
   ▼       ▼
┌──────┐ ┌────────┐
│Login │ │Register│
│/login│ │/register│
└──┬───┘ └────┬───┘
   │          │
   └────┬─────┘
        ▼
┌──────────────────────────────────────┐
│      MainNavigationScreen            │
│  (Bottom Navigation Bar)             │
│  ┌────────────────────────────────┐  │
│  │ Dashboard │ Meds │ Add │Profile│  │
│  │ /dashboard│/list │/form│/profile  │
│  └────────────────────────────────┘  │
└──────────────────────────────────────┘
        │
        ├─────────────────┐
        ▼                 ▼
┌──────────────┐  ┌──────────────┐
│TodayReminders│  │IntakeHistory │
│/today-remind │  │/intake-hist  │
└──────────────┘  └──────────────┘
```

---

## 🎨 Theming

Centralized in `presentation/theme/theme.dart`.

### Color Palette

```dart
// Primary colors
primaryColor:  Color(0xFF4DD0E1)  // Cyan
primaryDark:   Color(0xFF00ACC1)
primaryLight:  Color(0xFF80DEEA)

// Status colors
takenColor:    Color(0xFF4CAF50)  // Green
missedColor:   Color(0xFFF44336)  // Red
skippedColor:  Color(0xFFFF9800)  // Orange
pendingColor:  Color(0xFF9E9E9E)  // Grey
```

### Theme Configuration

Both `lightTheme` and `darkTheme` are fully configured with:
- ColorScheme
- AppBar styling
- Card styling
- Button themes (Elevated, Text, Outlined)
- Input decoration
- Switch, Chip, BottomNavigationBar themes
- Typography scale

---

## 🌍 Localization (i18n)

### Supported Languages
- 🇺🇸 English (`en`)
- 🇰🇭 Khmer (`km`)

### Implementation

1. **ARB Files** (`lib/l10n/app_en.arb`, `app_km.arb`):
```json
{
  "@@locale": "en",
  "appTitle": "DasTern",
  "welcomeMessage": "Your medication reminder companion",
  "dashboard": "Dashboard",
  ...
}
```

2. **Generated Localizations** (auto-generated):
   - `app_localizations.dart`
   - `app_localizations_en.dart`
   - `app_localizations_km.dart`

3. **Usage in Widgets**:
```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.dashboard)
```

---

## 📱 Screen Breakdown

### 1. WelcomeScreen
- **Route:** `/`
- **Purpose:** Landing page for unauthenticated users
- **Features:** App branding, Login/Register buttons
- **Design:** Cyan gradient background

### 2. LoginScreen
- **Route:** `/login`
- **Purpose:** User authentication
- **Fields:** Phone number, Password
- **Features:** Form validation, Demo account support

### 3. RegisterScreen
- **Route:** `/register`
- **Purpose:** New user registration
- **Fields:** Name, Phone, Password, DOB, Blood Type, Address, Weight, Family Contact
- **Features:** Date picker, dropdown for blood type

### 4. DashboardScreen
- **Route:** `/dashboard`
- **Purpose:** Main hub showing overview
- **Sections:**
  - Header with user info
  - Greeting with date
  - Quick stats (Taken/Pending/Missed)
  - Medication cards
  - Quick actions
  - Today's schedule

### 5. MedicationsScreen
- **Route:** `/medicine-list`
- **Purpose:** List all medications
- **Features:** Add, Edit, Delete medications

### 6. MedicineFormScreen
- **Route:** `/medicine-form`
- **Purpose:** Add/Edit medication
- **Fields:** Name, Dosage, Unit, Instructions, Prescribed By

### 7. ProfileScreen
- **Route:** `/profile`
- **Purpose:** User settings
- **Features:** Theme toggle, Language selector, Test notification, Logout

### 8. TodayRemindersScreen
- **Route:** `/today-reminders`
- **Purpose:** View today's medication schedule

### 9. IntakeHistoryScreen
- **Route:** `/intake-history`
- **Purpose:** View intake history and statistics

---

## 🔔 Notification Flow

```
1. App Start
   └─► NotificationService.initialize()
       ├─► Initialize timezone (Asia/Phnom_Penh)
       ├─► Request permissions (iOS/Android)
       └─► Set up notification channels

2. User Logs In
   └─► main.dart: scheduleRemindersForToday()
       ├─► Get today's active reminders
       └─► Schedule native notifications for each

3. At Scheduled Time
   └─► System triggers notification
       └─► User taps notification
           └─► _onNotificationTapped() → Navigate to app

4. In-App (App Resumed)
   └─► _checkForDueReminders()
       └─► Show in-app overlay notification
```

---

## 🚀 App Startup Flow

```dart
void main() async {
  // 1. Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize services
  final notificationService = NotificationService();
  await notificationService.initialize();

  // 3. Initialize providers (load from storage)
  final settingsProvider = SettingsProvider();
  await settingsProvider.initialize();
  
  final authProvider = AuthProvider();
  await authProvider.initialize();  // Creates demo account if needed
  
  final medicationProvider = MedicationProvider();
  await medicationProvider.initialize();
  
  final reminderProvider = ReminderProvider();
  await reminderProvider.initialize();
  
  final intakeHistoryProvider = IntakeHistoryProvider();
  await intakeHistoryProvider.initialize();

  // 4. Schedule today's notifications (if logged in)
  if (authProvider.currentPatient != null) {
    await notificationService.scheduleRemindersForToday(...);
  }

  // 5. Run app with DevicePreview (debug) or normal (release)
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => MultiProvider(
        providers: [...],
        child: const DasternApp(),
      ),
    ),
  );
}
```

---

## 🧪 Testing the App

### Demo Account
- **Phone:** `012345678`
- **Password:** `demo123`

### Test Flow
1. Launch app → Welcome Screen
2. Tap "Login"
3. Enter demo credentials
4. View Dashboard
5. Add Medication → Auto-creates 3 reminders
6. Go to Profile → Test Notification button
7. Check notification appears
8. Switch theme/language

---

## 📋 Key Code Patterns

### 1. Provider Initialization
```dart
Future<void> initialize() async {
  _isLoading = true;
  notifyListeners();
  // Load data
  _isLoading = false;
  notifyListeners();
}
```

### 2. JSON Serialization
```dart
Map<String, dynamic> toJson() => {...};
factory Xxx.fromJson(Map<String, dynamic> json) => Xxx(...);
```

### 3. Immutable Updates (copyWith)
```dart
Medication copyWith({String? name, ...}) {
  return Medication(
    name: name ?? this.name,
    ...
  );
}
```

### 4. Consumer Pattern
```dart
Consumer2<Provider1, Provider2>(
  builder: (context, prov1, prov2, child) {
    return Widget(...);
  },
)
```

### 5. Navigation with GoRouter
```dart
context.go('/dashboard');  // Replace
context.push('/login');    // Push
context.pop();             // Back
```

---

## 📝 Summary

**DasTern** is a well-structured Flutter medication reminder app that demonstrates:

1. **Clean Architecture** - Separation of concerns with models, services, providers, and presentation layers
2. **State Management** - Provider pattern with ChangeNotifier
3. **Local Persistence** - SharedPreferences for offline-first functionality
4. **Native Notifications** - Platform-specific push notifications
5. **Routing** - Declarative navigation with auth guards
6. **Theming** - Centralized light/dark theme support
7. **Localization** - Multi-language support (EN/KM)
8. **Best Practices** - Immutable models, factory constructors, computed properties

This architecture makes the app:
- **Maintainable** - Clear separation makes updates easy
- **Testable** - Services and providers can be unit tested
- **Scalable** - Easy to add new features
- **Performant** - Efficient state updates with Provider

---

*Documentation generated for DasTern Project v1.0.0*
