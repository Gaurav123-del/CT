# 🚨 Self Life Monitoring App

A smart personal safety and emergency response mobile application built with Flutter.

The app is designed to improve personal security through emergency alerts, trusted contacts, timer-based SOS triggers, notifications, and smart life monitoring tools.

---

# 📌 Overview

Self Life Monitoring App helps users stay safe in daily life situations such as:

* Traveling alone
* Night commuting
* Meeting unknown people
* Medical emergencies
* Unsafe surroundings
* Delayed check-ins

The app can automatically trigger emergency actions when the user does not respond in time.

---

# ✨ Key Features

## 🔐 Authentication System

* User Login
* User Signup
* Secure Entry Screens
* First-time Setup Screen

---

## 🛡️ Safety Features

### 🚨 SOS Emergency Trigger

Instant emergency alert button for urgent situations.

### ⏱️ Timer-Based SOS

Users can start a safety timer before travel or risky situations.

If the timer expires and user does not cancel it:

* SOS alert triggers automatically
* Emergency workflow starts
* Notifications are shown
* Trusted contacts can be alerted

### ⚠️ Emergency Type Selection

Choose emergency situations like:

* Medical
* Accident
* Threat
* Fire
* Women Safety
* Other

### 🔔 Smart Notifications

* Safety reminders
* Timer alerts
* SOS notifications
* Status warnings

---

## 👥 Contact Protection

* Add trusted contacts
* Manage emergency contact list
* Quick emergency calling support

---

## 📊 Monitoring Dashboard

* Main Monitoring Screen
* Safety status tools
* Quick action access
* Real-time control flow

---

## 🎨 UI / UX

* Clean Modern Design
* Dark Theme
* Smooth Navigation
* Responsive Layout
* Reusable Widgets

---

# 📂 Project Structure

```text id="yabx0d"
lib/
│── main.dart
│── theme.dart
│
├── screens/
│   ├── alert_screen.dart
│   ├── contacts_screen.dart
│   ├── emergency_type.dart
│   ├── login_screen.dart
│   ├── main_monitoring_screen.dart
│   ├── safety_timer_screen.dart
│   ├── setup_screen.dart
│   └── signup_screen.dart
│
├── services/
│   └── notification_service.dart
│
├── widgets/
│   └── common_widgets.dart
│
├── models/
├── utils/
```

---

# 🛠️ Tech Stack

* Flutter
* Dart
* Material UI
* Flutter Local Notifications
* Android SDK
* VS Code / Android Studio

---

# 💻 System Requirements

Install these tools before running project:

## Required Software

1. Flutter SDK
2. Android Studio
3. Visual Studio Code *(optional)*
4. Git
5. Chrome Browser *(for Flutter Web testing)*

---

# ⚙️ Installation Guide

## Clone Project

```bash id="3nyj3h"
git clone https://github.com/your-username/self_life_monitoring_app.git
cd self_life_monitoring_app
```

## Install Dependencies

```bash id="vqfvv8"
flutter pub get
```

## Verify Setup

```bash id="n0gj64"
flutter doctor
```

## Run Project

```bash id="v3ibsy"
flutter run
```

---

# 📱 Run on Real Android Device

1. Enable Developer Options
2. Enable USB Debugging
3. Connect device with USB cable
4. Run:

```bash id="59m4yk"
flutter run
```

---

# 📦 Build APK

```bash id="xbqsz6"
flutter build apk
```

APK Output:

```text id="g3jjf5"
build/app/outputs/flutter-apk/app-release.apk
```

---

# 🧠 Core Logic Example

## Timer-Based SOS Flow

```text id="o4a3ee"
Start Timer
↓
User Safe? Cancel Timer
↓
If No Response
↓
Auto Trigger SOS
↓
Show Alert / Notify Contacts
```

---

# 🚀 Future Enhancements

* Live GPS Tracking
* Real SMS Alerts
* AI Danger Detection
* Voice Activated SOS
* Family Safety Dashboard
* Cloud Backup
* Wearable Device Support

---

# 📸 Screenshots

Add your screenshots here:

```text id="fj7w8i"
assets/screenshots/login.png
assets/screenshots/home.png
assets/screenshots/sos.png
assets/screenshots/timer.png
```

---

# 🎯 Use Cases

* Women Safety
* Student Safety
* Solo Travelers
* Elderly Monitoring
* Daily Commute Safety
* Medical Emergency Support

---

# 👨‍💻 Developer

**Gagan Deep**

Flutter Developer | Mobile App Enthusiast

---

# 📄 License

This project is developed for educational, portfolio, and learning purposes.

---

# ⭐ Support

If you like this project, give it a star on GitHub.
