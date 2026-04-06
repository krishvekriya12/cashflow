<div align="center">

<img src="screenshots/splash.png" alt="CashFlow Logo" width="120" height="120" style="border-radius: 24px"/>

# 💸 CashFlow

### *Your Smart Personal Finance Tracker*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Hive](https://img.shields.io/badge/Hive-Local%20DB-FF7043?style=for-the-badge&logo=hive&logoColor=white)](https://pub.dev/packages/hive)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
[![Stars](https://img.shields.io/github/stars/krishvekriya12/cashflow?style=for-the-badge&color=yellow)](https://github.com/krishvekriya12/cashflow/stargazers)

**Take control of your money.** CashFlow is a beautifully designed, offline-first personal finance tracker built with Flutter. Track income & expenses, visualize your spending with stunning charts, and get smart reports — all on your device, no login required.

[📱 Download APK](#installation) · [🐛 Report Bug](https://github.com/krishvekriya12/cashflow/issues) · [✨ Request Feature](https://github.com/krishvekriya12/cashflow/issues)

</div>

---

## 📸 Screenshots

<div align="center">
<table>
  <tr>
    <td align="center"><img src="screenshots/splash.png" width="180"/><br/><sub><b>Splash Screen</b></sub></td>
    <td align="center"><img src="screenshots/onboarding.png" width="180"/><br/><sub><b>Onboarding</b></sub></td>
    <td align="center"><img src="screenshots/onboarding1.png" width="180"/><br/><sub><b>Onboarding 2</b></sub></td>
    <td align="center"><img src="screenshots/home.png" width="180"/><br/><sub><b>Home</b></sub></td>
  </tr>
  <tr>
    <td align="center"><img src="screenshots/addtransaction.png" width="180"/><br/><sub><b>Add Transaction</b></sub></td>
    <td align="center"><img src="screenshots/addtransaction1.png" width="180"/><br/><sub><b>Transaction Form</b></sub></td>
    <td align="center"><img src="screenshots/analitys.png" width="180"/><br/><sub><b>Analytics</b></sub></td>
    <td align="center"><img src="screenshots/report.png" width="180"/><br/><sub><b>Reports</b></sub></td>
  </tr>
  <tr>
    <td align="center"><img src="screenshots/calander.png" width="180"/><br/><sub><b>Calendar View</b></sub></td>
    <td align="center"><img src="screenshots/profile.png" width="180"/><br/><sub><b>Profile</b></sub></td>
    <td></td>
    <td></td>
  </tr>
</table>
</div>

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🏠 **Dashboard** | Overview of total balance, income & expenses at a glance |
| ➕ **Add Transactions** | Quickly log income or expenses with category & notes |
| 📊 **Analytics** | Beautiful charts powered by `fl_chart` to visualize spending patterns |
| 📅 **Calendar View** | Browse transactions by date with an intuitive calendar |
| 📄 **Reports** | Detailed monthly & category-wise financial reports |
| 👤 **Profile** | Personalized user profile management |
| 🌙 **Dark Mode** | Full dark mode support for comfortable night-time use |
| 📴 **Offline First** | All data stored locally with Hive — works without internet |
| 🎨 **Beautiful UI** | Material 3 design with Google Fonts & smooth animations |

---

## 🛠️ Tech Stack

```
📱 Framework   →  Flutter 3.x (Dart 3.x)
🗄️ Database    →  Hive CE (Fast local NoSQL)
📦 State Mgmt  →  Provider
📊 Charts      →  FL Chart
🔤 Fonts       →  Google Fonts
🌍 i18n        →  Intl (Date & Currency Formatting)
💾 Prefs       →  Shared Preferences
```

---

## 🚀 Getting Started

### Prerequisites

Make sure you have the following installed:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) `>= 3.x`
- [Dart SDK](https://dart.dev/get-dart) `>= 3.x`  
- Android Studio / VS Code with Flutter extension

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/krishvekriya12/cashflow.git
   cd cashflow
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

4. **Build APK** *(optional)*
   ```bash
   flutter build apk --release
   ```

---

## 📁 Project Structure

```
cashflow/
├── lib/
│   ├── core/              # App-wide theme, constants, utilities
│   ├── features/
│   │   ├── splash/        # Splash screen
│   │   ├── onboarding/    # Onboarding flow
│   │   ├── home/          # Dashboard & balance overview
│   │   ├── add_expense/   # Add income/expense screen
│   │   ├── analytics/     # Charts & spending analytics
│   │   ├── reports/       # Financial reports
│   │   └── profile/       # User profile
│   ├── shared/            # Reusable widgets & models
│   └── main.dart          # App entry point
├── screenshots/           # App screenshots
└── pubspec.yaml           # Dependencies
```

---

## 🧩 Dependencies

```yaml
hive_ce_flutter: ^2.3.4       # Lightning-fast local database
provider: ^6.1.5              # State management
fl_chart: ^1.2.0              # Beautiful charts
google_fonts: ^8.0.2          # Premium typography
intl: ^0.20.2                 # Date & number formatting
shared_preferences: ^2.5.5    # Lightweight key-value storage
```

---

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place! Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 License

Distributed under the MIT License. See [`LICENSE`](LICENSE) for more information.

---

## 👨‍💻 Author

**Krish Vekriya**

[![GitHub](https://img.shields.io/badge/GitHub-krishvekriya12-181717?style=for-the-badge&logo=github)](https://github.com/krishvekriya12)

---

<div align="center">

### ⭐ If you found this project helpful, please give it a star!

*It motivates me to build more awesome projects.*

**Made with ❤️ and Flutter**

</div>
