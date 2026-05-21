# 📋 Task Management App

Aplikasi **Task Management** yang dibangun menggunakan **Flutter** dan **SQLite** untuk membantu pengguna mengelola tugas harian dengan lebih terorganisir.
Aplikasi ini mendukung fitur pengelompokan prioritas, tracking progres tugas, pencarian tugas, kalender, serta **Dark/Light Mode** dengan tampilan modern dan responsif.

---

## ✨ Features

*  Tambah, edit, dan hapus task
* Kalender untuk melihat jadwal tugas
*  Search & filter task
*  Kategori prioritas task
*  Dark Mode & Light Mode
*  Penyimpanan lokal menggunakan SQLite
*  Offline-first application
*  UI responsif dan clean design

---

#  Project Structure

Proyek menggunakan **Layered Architecture** agar kode lebih terstruktur, scalable, dan mudah dipelihara.

```plaintext
lib/
├── style/            # Tema, konfigurasi global, dan utilitas
├── data/            # Database helper & repositories
├── models/          # Struktur data (TaskModel, UserModel)
├── ui/              # Tampilan aplikasi
│   ├── auth/
│   ├── home/
│   └── task/
└── main.dart        # Entry point aplikasi
```

---

# Alasan Pemilihan Struktur

## Separation of Concerns

Setiap layer memiliki tanggung jawab masing-masing sehingga:

* UI fokus pada tampilan
* Repository fokus pada pengelolaan data
* Model fokus pada struktur data

Supaya aplikasi:

* lebih mudah di-maintain
* lebih mudah diuji (testable)
* lebih mudah dikembangkan

---

# 🚀 Scalability

Aplikasi dirancang agar siap untuk integrasi API di masa depan menggunakan **Repository Pattern**.

### Saat Ini

Repository mengambil data dari SQLite:

```dart
TaskRepository -> SQLite Database
```

### Jika Menggunakan API

Cukup membuat repository baru:

```dart
ApiTaskRepository -> REST API
```

Karena UI hanya bergantung pada `TaskModel`, maka:

*  UI tidak perlu diubah
*  Model tidak perlu diubah
*  Logic tampilan tetap berjalan

Yang berubah hanya layer `data/repositories`.

---

# Design Decisions

##  Local-First Approach

Menggunakan `sqflite` karena:

* akses data sangat cepat
* dapat digunakan tanpa internet
* cocok untuk aplikasi task management personal

---

### Trade-off

* lebih sederhana
* development lebih cepat
* cocok untuk skala aplikasi saat ini

# 📌 Assumptions

* Aplikasi digunakan sebagai **single-user app**
* Data disimpan secara lokal di perangkat
* Validasi dilakukan di sisi client untuk memberikan feedback instan

---


# Setup Instructions

## Prerequisites

Pastikan sudah menginstall:

* Flutter SDK `3.0+`
* Android Studio / VS Code
* Android Emulator / 

---

# ▶️ Installation

## 1. Clone Repository

```bash
git clone [URL_GITHUB_KAMU]
cd task_management_app
```

---

## 2. Install Dependencies

```bash
flutter pub get
```

---

## 3. Clean & Build

```bash
flutter clean
flutter pub get
```

---

## 4. Run Project

```bash
flutter run
```

---
