# DasTern - Quick Start Guide

## 🚀 Getting Started

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Generate Localization Files (if needed)
```bash
flutter gen-l10n
```

### 3. Run the App
```bash
# On a connected device or emulator
flutter run

# For web
flutter run -d chrome

# For specific device
flutter devices  # List available devices
flutter run -d <device-id>
```

## 🧪 Testing the Features

### Theme Switching
1. Launch the app
2. Tap "Get Started" on the Welcome screen
3. Navigate to Dashboard
4. Tap the Profile icon (person icon in top-right)
5. Toggle the **Theme** switch
6. ✅ The app should immediately switch between light and dark mode

### Language Switching
1. Go to the Profile screen
2. Tap the **Language** dropdown
3. Select either "English" or "Khmer" (ខ្មែរ)
4. ✅ All text in the app should update to the selected language

### Navigation
1. **Welcome Screen** → Tap "Get Started" → Dashboard
2. **Dashboard** has 4 cards:
   - Medicine List
   - Add Medicine
   - Reminders (coming soon)
   - Settings (goes to Profile)
3. **Medicine List** → Shows placeholder medicines → Tap "+" to add new
4. **Medicine Form** → Fill in details → Save
5. **Profile** → View settings and user info

## 📱 App Flow

```
┌─────────────────┐
│ Welcome Screen  │
│  "Get Started"  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐     ┌──────────────┐
│ Dashboard       │────▶│  Profile     │
│  - Medicine List│     │  - Theme     │
│  - Add Medicine │     │  - Language  │
│  - Reminders    │     └──────────────┘
│  - Settings     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Medicine List   │
│ (View all meds) │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Medicine Form   │
│ (Add/Edit med)  │
└─────────────────┘
```

## 🎨 Current Features

✅ **Multi-language Support**
- English (en)
- Khmer (km)
- Persisted preference

✅ **Theme Support**
- Light mode
- Dark mode
- Persisted preference

✅ **Navigation**
- Route-based navigation
- Clean URL structure
- Back button support

✅ **State Management**
- Provider for global state
- Local state in StatefulWidgets

✅ **Persistence**
- SharedPreferences for settings
- Survives app restarts

## 📋 Available Routes

| Route | Screen | Description |
|-------|--------|-------------|
| `/welcome` | WelcomeScreen | Entry point |
| `/dashboard` | DashboardScreen | Main hub |
| `/medicine-list` | MedicineListScreen | View medicines |
| `/medicine-form` | MedicineFormScreen | Add/Edit medicine |
| `/profile` | ProfileScreen | Settings |

## 🔧 Current Limitations

⚠️ **These are expected** (UI layer only):
- Medicine data is hardcoded (placeholder)
- No actual database operations
- No real CRUD functionality
- No notification scheduling
- No user authentication

These will be addressed when implementing the Domain and Data layers.

## 🐛 Troubleshooting

### Localization files not found
```bash
flutter gen-l10n
flutter clean
flutter pub get
```

### Hot reload not working after changing ARB files
```bash
# Stop the app and regenerate
flutter gen-l10n
flutter run
```

### Theme/Language not persisting
- Check that SharedPreferences is properly initialized
- Clear app data and restart
- Check for errors in terminal

### Import errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

## 📚 Next Steps

After testing the UI layer, you can:

1. **Implement Domain Layer**
   - Create entity classes
   - Define repository interfaces
   - Write business logic use cases

2. **Implement Data Layer**
   - Set up local database (SQLite)
   - Implement repository pattern
   - Create data models and mappers

3. **Add Features**
   - Notification scheduling
   - Medicine search/filter
   - Data export/import
   - User authentication

4. **Testing**
   - Write unit tests for business logic
   - Write widget tests for UI
   - Write integration tests

## 💡 Tips

- Use `flutter run --hot` for faster development
- Press `r` in terminal for hot reload
- Press `R` for hot restart
- Press `h` for help menu
- Use Flutter DevTools for debugging

## 📖 Documentation

- [ARCHITECTURE.md](ARCHITECTURE.md) - Detailed architecture guide
- [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) - Complete folder structure
- [README.md](README.md) - Project overview

---

**Happy Coding! 🎉**
