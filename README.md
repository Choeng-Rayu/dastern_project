<div align="center">

```
██████╗   █████╗ ███████╗████████╗███████╗██████╗ ███╗   ██╗
██╔══██╗██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗████╗  ██║
██║  ██║███████║███████╗   ██║   █████╗  ██████╔╝██╔██╗ ██║
██║  ██║██╔══██║╚════██║   ██║   ██╔══╝  ██╔══██╗██║╚██╗██║
██████╔╝██║  ██║███████║   ██║   ███████╗██║  ██║██║ ╚████║
╚═════╝ ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝
```

### 💊 Your Personal Medication Management Assistant

**Never miss a dose again!**

[![Flutter](https://img.shields.io/badge/Flutter-3.5.4-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5.4-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

[Features](#-features) • [Installation](#-installation) • [Usage](#-usage) • [Contributing](#-contributing) • [Documentation](#-documentation)

---

</div>

## 📋 Overview

**Dastern** is a comprehensive medication management application built with Flutter. It helps users track their medications, set intelligent reminders, and monitor medication adherence with ease. Perfect for individuals managing multiple prescriptions or anyone who wants to stay on top of their health routine.

## ✨ Features

🔔 **Smart Reminders**
- Schedule medication reminders by time of day
- Set specific active days for each medication
- Automatic notifications at scheduled times
- Snooze and customize reminder alerts

💊 **Medication Management**
- Add and organize multiple medications
- Detailed dosage information (tablets, ml, mg)
- Track prescribing doctor and instructions
- Color-coded medication for easy identification

📊 **Adherence Tracking**
- Record medication intake (taken, missed, skipped)
- View complete medication history
- Generate adherence reports
- Monitor compliance patterns

👤 **Profile Management**
- Store personal health information
- Emergency contact details
- Blood type and weight tracking
- Age calculation and health metrics

🌍 **Multilingual Support**
- English (en)
- Khmer (km)
- Easy to add more languages

## 🚀 Installation

### Prerequisites

Before you begin, ensure you have the following installed:
- [Flutter](https://flutter.dev/docs/get-started/install) (SDK 3.5.4 or higher)
- [Dart](https://dart.dev/get-dart) (3.5.4 or higher)
- Android Studio / Xcode (for mobile development)
- A code editor (VS Code, Android Studio, or IntelliJ)

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/dastern_project.git
   cd dastern_project
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For Android/iOS
   flutter run
   
   # For Web
   flutter run -d chrome
   
   # For specific device
   flutter devices
   flutter run -d <device_id>
   ```

## 📱 Usage

### First Time Setup
1. Launch the app
2. Create your profile with basic health information
3. Add emergency contact (optional)

### Adding Medications
1. Navigate to "Medications" screen
2. Tap the **+** button
3. Enter medication details:
   - Name
   - Dosage (amount and unit)
   - Instructions
   - Prescribing doctor
4. Optionally customize color and icon

### Setting Reminders
1. Select a medication
2. Tap "Add Reminder"
3. Configure:
   - Time of day
   - Specific time
   - Active days (Mon-Sun)
   - Dosage amount per reminder
4. Enable the reminder

### Tracking Intake
When a reminder notification appears:
- **Taken**: Mark as completed
- **Skip**: Intentionally skip this dose
- **Miss**: If you didn't take it when scheduled

View your intake history anytime from the Reports section.

## 🛠️ Tech Stack

- **Framework**: Flutter 3.5.4
- **Language**: Dart 3.5.4
- **State Management**: Provider
- **Navigation**: GoRouter
- **Local Storage**: SharedPreferences
- **Notifications**: flutter_local_notifications
- **Localization**: flutter_localizations, intl
- **Utilities**: uuid, timezone

## 📁 Project Structure

```
lib/
├── app.dart                    # Main app configuration
├── main.dart                   # App entry point
├── l10n/                       # Localization files
│   ├── app_en.arb             # English translations
│   └── app_km.arb             # Khmer translations
├── models/                     # Data models
│   ├── patient.dart           # User profile model
│   ├── medication.dart        # Medication model
│   ├── reminder.dart          # Reminder model
│   ├── intakeHistory.dart     # Intake tracking model
│   └── enum/                  # Enumerations
├── presentation/               # UI Layer
│   ├── layout/                # Layout widgets
│   ├── providers/             # State management
│   ├── screens/               # App screens
│   ├── theme/                 # App theming
│   └── widget/                # Reusable widgets
└── services/                   # Business logic
    ├── notification_service.dart
    └── storage_service.dart
```

## 🎨 Design Documents

- [Class Diagram](class_diagram.puml) - UML class diagram showing data models
- [Use Case Diagram](usecase_diagram.puml) - System use cases and interactions

## 🤝 Contributing

We love contributions! Here's how you can help make Dastern even better:

### Getting Started

1. **Fork the repository**
   
   Click the "Fork" button at the top right of this page.

2. **Clone your fork**
   ```bash
   git clone https://github.com/your-username/dastern_project.git
   cd dastern_project
   ```

3. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```

4. **Make your changes**
   - Write clean, documented code
   - Follow Dart/Flutter best practices
   - Test your changes thoroughly

5. **Commit your changes**
   ```bash
   git add .
   git commit -m "Add some amazing feature"
   ```

6. **Push to your fork**
   ```bash
   git push origin feature/amazing-feature
   ```

7. **Open a Pull Request**
   
   Go to the original repository and click "New Pull Request"

### Contribution Guidelines

- ✅ Follow the existing code style and structure
- ✅ Write meaningful commit messages
- ✅ Update documentation for new features
- ✅ Add tests for new functionality
- ✅ Ensure all tests pass before submitting
- ✅ One feature per pull request

### Code Style

```bash
# Format your code
flutter format .

# Analyze code
flutter analyze

# Run tests
flutter test
```

### Areas We Need Help

- 🌍 **Translations**: Add support for more languages
- 🎨 **UI/UX**: Improve design and user experience
- 🐛 **Bug Fixes**: Report and fix bugs
- 📚 **Documentation**: Improve docs and tutorials
- ✨ **Features**: Suggest and implement new features
- 🧪 **Testing**: Add unit and integration tests

## 📝 Documentation

- [Notification Setup Guide](NOTIFICATION_SETUP.md) - Configure push notifications
- [Quick Start Guide](QUICKSTART.md) - Get up and running quickly
- [Flutter Documentation](https://docs.flutter.dev/)

## 🐛 Bug Reports

Found a bug? Please open an issue with:
- Description of the bug
- Steps to reproduce
- Expected behavior
- Screenshots (if applicable)
- Device/Platform information

## 💡 Feature Requests

Have an idea? We'd love to hear it! Open an issue with:
- Clear description of the feature
- Use case and benefits
- Any mockups or examples

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👏 Acknowledgments

- Flutter team for the amazing framework
- All contributors who help improve Dastern
- Open source community for inspiration

## 👥 Credits

<div align="center">

### 🌟 The Brilliant Minds Behind Dastern

**Developers**

| Name | Role |
|------|------|
| 💻 **Choeng Rayu** | Full-Stack Developer |
| 💻 **Kimhour Loem** | Full-Stack Developer |

**Guided By**

| Name | Role |
|------|------|
| 👨‍🏫 **Ronan Ogor** | Lecturer & Mentor |

---

*This project was developed as an educational initiative to create a practical solution for Foundation of Mobile Development*

</div>

---



<div align="center">

**Made with ❤️ for better health management**

⭐ Star this repo if you find it helpful!

[Report Bug](../../issues) · [Request Feature](../../issues) · [Documentation](../../wiki)

</div>
