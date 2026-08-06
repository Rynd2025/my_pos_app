# 🛒 Mobile POS & Billing App (Clean Architecture)

A high-performance offline-first Point of Sale (POS) and billing application built with **Flutter**. Designed for Tunisian retail operations, featuring advanced barcode scanning, Bluetooth thermal printing, and comprehensive sales tracking.

---

## 🚀 Key Features

* **📦 Shop Catalog & Live Dashboard:** Intuitive category-based browsing with a prominent real-time "TOTAL CART" display on the home screen.
* **⚡ Smart Scanning System:** Robust camera-based scanning with 1.5s re-scan cooldown, consecutive frame verification, and automatic quantity incrementing.
* **📈 Sales History:** Persistent local record of all transactions. Shop owners can inspect past sales, review itemized details, and track performance.
* **🛠️ Inventory Management:** Full CRUD operations for products including category assignment, barcode integration, and camera-based image picking.
* **🖨️ Thermal Printing:** Direct integration with Bluetooth thermal printers for generating itemized receipts formatted in **TND** (Tunisian Dinars).
* **🔒 Offline-First:** Powered by **Hive** (NoSQL local database) for lightning-fast localized storage—no internet connection required.

---

## 🛠️ Tech Stack & Architecture

Built using industry-standard Clean Architecture principles to ensure scalability and strict separation of concerns:

* **Framework:** Flutter (Dart)
* **Architecture:** Clean Architecture (Entities, Use Cases, Repositories, Data Sources)
* **State Management:** `flutter_bloc`
* **Dependency Injection:** `get_it`
* **Routing:** `go_router`
* **Local Database:** `hive` & `hive_flutter`
* **Currency:** Tunisian Dinar (TND) with 3-decimal precision
* **Hardware:** `mobile_scanner`, `print_bluetooth_thermal`, `image_picker`

---

## 📁 Project Structure

```text
lib/
├── config/                     # App-wide configuration (Routes)
├── core/                       # Shared logic and global infrastructure
│   ├── data/                   # Global data sources (Hive initialization)
│   ├── error/                  # Failure and exception models
│   ├── theme/                  # Material 3 typography and styling
│   ├── usecase/                # Base UseCase definitions
│   └── utils/                  # Helpers (Printer, Validators, Formatters)
│
└── features/                   # Feature-driven modules
    ├── billing/                # Cart logic and POS scanning interface
    ├── product/                # Inventory/Product CRUD and data models
    ├── sales/                  # Transaction persistence and history tracking
    ├── settings/               # Printer pairing and app preferences
    └── shop/                   # Catalog UI and shop profile configuration
```

---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (Latest Stable)
* Android Studio / VS Code with Flutter extensions
* A Bluetooth Thermal Printer (optional, for printing features)

### Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Rynd2025/my_pos_app.git
   cd my_pos_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate Hive Adapters:**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

---

## 👥 Authors

**Rahma Ben Seghaier**  
*Full-stack Software Engineer & Mobile Developer*  
GitHub: [Rynd2025](https://github.com/Rynd2025)

**Mohamed Iyed Tahri**  
*Data Scientist & Full Stack AI Engineer*  
GitHub: [MohamedIyedTahri](https://github.com/MohamedIyedTahri)
