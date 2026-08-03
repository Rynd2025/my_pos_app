# 🛒 Mobile POS & Billing App

A high-performance offline-first Point of Sale (POS) and billing application built with **Flutter**. Designed for seamless retail checkout operations, featuring camera-based barcode scanning, Bluetooth thermal receipt printing, and robust local data persistence.

---

## 🚀 Key Features

* **📦 Product Management:** Complete CRUD operations for inventory items with integrated barcode/QR code support.
* **⚡ Smart Checkout System:** Rapid cart building via device camera scanning or manual entry, with instant tax and total calculation.
* **🖨️ Thermal Printing:** Direct integration with Bluetooth thermal POS printers for immediate itemized receipt generation.
* **⚙️ Shop Settings:** Centrally managed shop details and configurations printed dynamically on receipts.
* **🔒 Offline-First Architecture:** Powered by **Hive** (NoSQL local database) for lightning-fast localized storage—no active internet connection required.

---

## 🛠️ Tech Stack & Architecture

This project is built using industry-standard architectural principles to ensure scalability, testability, and clean separation of concerns:

* **Framework:** Flutter (Dart)
* **Architecture:** Clean Architecture & Feature-Driven Design (`core` + `features`)
* **State Management:** `flutter_bloc`
* **Dependency Injection:** `get_it`
* **Routing:** `go_router`
* **Local Database:** `hive` & `hive_flutter`
* **Functional Programming:** `fpdart` (for robust Either-based error handling)
* **Hardware Integrations:** `mobile_scanner`, `print_bluetooth_thermal`

---

## 📁 Project Structure

```text
lib/
├── core/                       # Shared utilities, themes, and global components
│   ├── data/                   # Global data sources (Hive setup)
│   ├── error/                  # Failure and exception models
│   ├── theme/                  # Typography and styling
│   ├── utils/                  # Helpers and formatters
│   └── service_locator.dart    # Dependency injection setup
│
└── features/                   # Independent feature modules
    ├── billing/                # Cart, checkout, and invoice generation
    ├── product/                # Inventory management and barcode scanning
    ├── settings/               # App configuration and printer pairing
    └── shop/                   # Shop details configuration
🚀 Getting Started
Prerequisites
Flutter SDK installed on your machine.

Android Studio / VS Code with Flutter extensions.

Installation & Setup
Clone the repository:

Bash
git clone [https://github.com/Rynd2025/my_pos_app.git](https://github.com/Rynd2025/my_pos_app.git)
cd my_pos_app
Install dependencies:

Bash
flutter pub get
Run code generation (Required for Hive adapters & JSON serialization):

Bash
dart run build_runner build --delete-conflicting-outputs
Run the app:

Bash
flutter run
👩‍💻 Author
Rahma Ben Seghaier

Full-stack Software Engineer & Mobile Developer

GitHub: Rynd2025