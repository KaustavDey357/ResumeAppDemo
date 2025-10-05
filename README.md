# ResumeAppDemo

A simple Flutter application that displays a generated resume and shows the user’s current geographic coordinates (latitude & longitude) in the AppBar.

This project uses **Riverpod** for state management, a `GetLocation` widget for obtaining the user’s location, and a `resumeProvider` to fetch user data.

---

### Notes:
- All **Dart source files** (e.g., `main.dart`, `location.dart`, your screens, models, and providers) must be placed inside the **lib/** folder.  
- The **`pubspec.yaml`** file must be placed **outside** the lib folder, at the root of the project (alongside the `android/` and `ios/` directories).

---

## 🚀 Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/KaustavDey357/ResumeAppDemo.git
   cd ResumeAppDemo

2. **Install dependencies:**

   ```bash
   flutter pub get
   ```

3. **Run the app:**

   ```bash
   flutter run
   ```

Make sure you have location services enabled on your device or emulator.

---

## 📦 Dependencies

This app relies on the following packages:

* `flutter_riverpod` — state management
* `hive` — user configuration storage
* `location` — to access device GPS coordinates
* `app_settings` — to open device settings when permissions or services are disabled
* (plus standard Flutter SDK dependencies)

---

## ⚙️ Android Permissions

The file `location.dart` (which contains the `GetLocation` widget) requires **location permissions** to function.
Add the following lines inside your `android/app/src/main/AndroidManifest.xml` file:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

If you ever plan to use background location updates, you may also include:

```xml
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
```

*(Note: Background location requires additional justification in the Google Play Console.)*

---

## 🧭 How It Works

* The main screen is defined in `screens/resume_screen.dart`.
* The AppBar displays the app title **and** a small widget (`GetLocation`) that shows the user’s current latitude and longitude.
* The `GetLocation` widget:

  1. Checks whether location services are enabled.
  2. Requests runtime permissions if necessary.
  3. Listens to location changes.
  4. Displays coordinates or “Locating…” while awaiting data.
* The `resumeProvider` (in `providers.dart`) fetches a `User` model (defined in `models/user.dart`).
* The `CustomizationControls` widget allows adjusting font size, color, and background color using Riverpod providers.

---

## 📌 Notes & Caveats

* On Android, users must **grant location permission** and **enable location services** for coordinates to appear.
* If permissions are denied or permanently denied, a dialog prompts the user to open settings.
* Continuous location updates may slightly affect battery usage.
* The width of the `GetLocation` widget can be adjusted (it’s currently constrained to 220px) to ensure it fits well in the AppBar.

---

## 🧑‍💻 Author

**Kaustav Dey**

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

```
