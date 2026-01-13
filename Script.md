# DasTern Presentation Script

## 🎯 Presentation Flow: Introduction → Dashboard → Team Transition → Demo

---

## PART 1: INTRODUCTION & PROJECT OVERVIEW (Your Part)

### Slide 1: Opening
**"Good morning/afternoon everyone. Today I'm presenting DasTern, a medication reminder application built with Flutter."**

### Slide 2: Problem Statement
**"Many patients struggle to take their medications on time, leading to poor health outcomes. DasTern solves this by providing smart, automated medication reminders with tracking capabilities."**

### Slide 3: Key Features
**"Our app includes:**
- **Multi-language support** - English and Khmer
- **Smart reminders** with native notifications
- **Medication tracking** with intake history
- **Dark/Light theme** for better accessibility
- **User-friendly interface** with real-time updates"**

### Slide 4: Technology Stack
**"We built this using:**
- **Flutter** for cross-platform development
- **Provider** for state management
- **GoRouter** for navigation
- **SharedPreferences** for local storage
- **Flutter Local Notifications** for native alerts"**

---

## PART 2: DASHBOARD WALKTHROUGH (Your Part)

### Slide 5: Dashboard Features
**"Let me walk you through the main dashboard."**

**Point to each section:**
- **"At the top, we have the user greeting and profile access"**
- **"Quick Stats show today's medication counts - total medications and completion status"**
- **"Quick Actions provide direct access to common tasks"**
- **"Today's Schedule displays all medications due today with time-based organization"**

### Slide 6: Architecture Overview
**"Our application follows a layered architecture pattern:**

**Presentation Layer:**
- **Screens** - UI components
- **Widgets** - Reusable UI elements  
- **Providers** - State management

**Business Logic Layer:**
- **Services** - Notification and storage logic
- **Models** - Data structures

**Data Layer:**
- **Local Storage** via SharedPreferences
- **User-specific data isolation"**

---

## TRANSITION TO TEAMMATE

**"Now I'll pass it to [Teammate Name] to demonstrate [their feature/section]."**

*(Your teammate presents their part)*

---

## PART 3: LIVE DEMO (Your Part - After Teammate)

### Before Demo Setup:
**"Now let me demonstrate how the app works in practice."**

### Demo Flow:

#### 1. **Login/Registration** (30 seconds)
**"First, let's login. For demo purposes, we have a bypass account:**
- **Phone: 012345678**
- **Password: demo123"**

*(Enter credentials and login)*

#### 2. **Dashboard Overview** (45 seconds)
**"After logging in, we see the dashboard with:**
- **Personalized greeting**
- **Today's medication summary - showing X medications**
- **Quick stats displaying our adherence rate**
- **Today's schedule organized by time"**

*(Navigate through different sections on dashboard)*

#### 3. **Adding a Medication** (1 minute)
**"Let's add a new medication:"**
1. **"Tap the Add Medication button"**
2. **"Enter medication name - for example, 'Paracetamol'"**
3. **"Set dosage - 500mg, 1 tablet"**
4. **"Add instructions - 'Take after meals'"**
5. **"Prescribed by - 'Dr. Sokha'"**
6. **"Enable auto-generate reminders for 3 daily notifications"**
7. **"Save"**

*(Show the automatic creation of morning, afternoon, and evening reminders)*

#### 4. **Medication List** (30 seconds)
**"In the medications screen, we can see all medications with:**
- **Medication names and dosages**
- **Prescribed by information**
- **Edit and delete options"**

#### 5. **Today's Reminders** (30 seconds)
**"The reminders screen shows:**
- **Upcoming reminders with scheduled times**
- **Medication details and dosage amounts**
- **Status tracking - pending, taken, missed, or skipped"**

#### 6. **Marking Medication as Taken** (30 seconds)
**"When a reminder appears, users can:**
- **Mark as Taken - records the exact time**
- **Skip - if not needed**
- **View details about the medication"**

*(Demonstrate marking one medication as taken)*

#### 7. **Intake History** (30 seconds)
**"The history screen provides:**
- **Complete medication intake records**
- **Adherence rate calculation**
- **Filtering by week, month, or all time**
- **Status indicators with color coding"**

#### 8. **Settings & Localization** (30 seconds)
**"Users can customize their experience:**
- **Switch between Light and Dark themes** *(toggle theme)*
- **Change language between English and Khmer** *(show language switch)*
- **View profile information"**

#### 9. **Notifications** (If time permits - 30 seconds)
**"The app uses native notifications that:**
- **Appear on the notification bar**
- **Include medication name and dosage**
- **Work even when app is closed**
- **Allow direct interaction from notifications"**

---

## CLOSING (Your Part)

### Slide: Summary & Conclusion
**"In summary, DasTern provides:**
- **Automated medication reminders** with smart scheduling
- **Complete tracking** of intake history
- **User-friendly interface** with localization
- **Cross-platform support** through Flutter

**Thank you for your attention. Are there any questions?"**

---

## 💡 DEMO TIPS & TROUBLESHOOTING

### Before Presentation:
1. **Pre-load the app** with 2-3 sample medications
2. **Test the demo account** login
3. **Set one reminder** for a time during/near presentation (for live notification)
4. **Clear any error notifications**
5. **Ensure device is in portrait mode**
6. **Turn up volume** for notification sounds

### During Demo:
- **Speak while clicking** - explain each action
- **Point to UI elements** as you mention them
- **Keep screens visible** for 3-5 seconds before moving
- **If error occurs**: "This sometimes happens during demos, let me show you the expected result..."

### Quick Recovery:
- **App crashes**: Restart and use pre-loaded data
- **Notification doesn't show**: Explain the scheduling system and show past notifications
- **Login fails**: Verify phone number format and use bypass account

### Time Management:
- **Total Demo Time**: ~4-5 minutes
- **If running short**: Skip intake history or theme switching
- **If running long**: Combine medication add + reminder screens

---

## 📱 DEMO CHECKLIST

Before presentation, verify:
- [ ] Device fully charged
- [ ] Demo account exists (012345678 / demo123)
- [ ] 2-3 sample medications pre-loaded
- [ ] At least one reminder set for demo
- [ ] Notification permissions enabled
- [ ] Screen brightness at 80%+
- [ ] Do Not Disturb mode OFF
- [ ] Connected to stable WiFi (if needed)
- [ ] Device cleaned (no personal notifications)

---

## 🎬 ALTERNATIVE FLOWS

### If Teammate Goes First:
**"Building on what [Name] showed, let me demonstrate the core functionality..."**

### If Demo Device Fails:
**"While we resolve this, let me explain the workflow..."**
*(Use slides to explain features while troubleshooting)*

### If Questions During Demo:
**"Great question! Let me finish this flow and I'll address that..."**
*(Note question and answer after current section)*

---

## ❓ ANTICIPATED QUESTIONS & ANSWERS

**Q: "How does the app handle missed medications?"**
**A:** "The app tracks all scheduled medications. If a reminder time passes without being marked as taken, it automatically records it as 'missed' in the intake history. Users can see their adherence rate which factors in missed doses."

**Q: "Can users customize reminder times?"**
**A:** "Yes, when adding a medication, users can enable auto-generation for default times (8 AM, 2 PM, 8 PM) or manually create custom reminders for specific times and days."

**Q: "Is data synced to the cloud?"**
**A:** "Currently, data is stored locally using SharedPreferences for privacy and offline access. Each user's data is isolated by their phone number."

**Q: "What happens if notifications don't appear?"**
**A:** "The app uses flutter_local_notifications for native system notifications. Permissions are requested on first launch. Users can also check reminders manually in the Today's Reminders screen."

**Q: "Can multiple family members use one device?"**
**A:** "Yes, each user has their own account accessed via phone number. They can log out and switch accounts. Data is kept separate for each user."

**Q: "Does it work offline?"**
**A:** "Yes, completely! All data is stored locally, and notifications are scheduled on the device. No internet connection is required."

---

## 🎯 KEY MESSAGE TAKEAWAYS

End your presentation emphasizing:
1. **Solves a real problem** - medication adherence
2. **User-friendly** - simple, intuitive interface
3. **Accessible** - bilingual support, dark mode
4. **Reliable** - works offline with native notifications
5. **Well-architected** - follows layered architecture principles

**FINAL LINE:** *"DasTern - Your medication reminder companion, ensuring you never miss a dose."*
