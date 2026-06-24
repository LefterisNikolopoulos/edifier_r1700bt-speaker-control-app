# Edifier Speaker Control App

A high-performance, custom-built Flutter companion application designed to manage Edifier speaker functions (Power, Volume, Mute, Bluetooth/AUX inputs) via **Home Assistant**. 

The app interacts with an ESP32-based Infrared (IR) blaster configured in Home Assistant to transmit physical remote signals to Edifier speakers. It also features full Android Home Screen Widget integration for instant control.

---

## 🛠️ Technical Features & Implementation

*   **Custom Gestural Remote UI**: A responsive, modern Material 3 dark-themed user interface optimized for single-handed control.
*   **Haptic Feedback Integration**: Implements physical device vibration (haptic feedback) on key presses to simulate tactile button interactions.
*   **Interactive Home Screen Widgets**: Complete integration of the `home_widget` package, enabling widgets on the Android launcher screen. Users can toggle power, mute, or adjust volume directly from the home screen via interactive background service callbacks.
*   **Debounced Continuous Press Volume Control**: Implements a custom timer mechanism (`Timer.periodic`) to handle volume up/down repeating commands on hold, mimicking a physical remote control button hold.
*   **Home Assistant REST API Integration**: Communicates securely with Home Assistant using Long-Lived Access Tokens (JWT) and HTTP POST requests to trigger button entity services (`button.press`).
*   **Background Callback Handler**: Includes an entry-point compilation pragma (`@pragma("vm:entry-point")`) to process background service actions when triggered from the Android system widgets.

---

## ⚙️ Configuration & Setup

To connect the application to your Home Assistant instance, modify the configuration variables in [lib/main.dart](file:///c:/Users/lefte/Desktop/esp_speaker_control/lib/main.dart):

1.  **Home Assistant Connection**:
    *   Set `homeAssistantUrl` to your local or public Home Assistant address:
        ```dart
        const String homeAssistantUrl = 'http://YOUR_HA_IP:8123';
        ```
    *   Set `accessToken` to your Long-Lived Access Token:
        ```dart
        const String accessToken = 'YOUR_LONG_LIVED_ACCESS_TOKEN';
        ```
        *(To generate a token: Home Assistant -> Profile -> Long-Lived Access Tokens -> Create Token)*

2.  **Entity IDs**:
    Verify that the entity IDs in `lib/main.dart` match your ESP32 IR buttons in Home Assistant:
    *   Power Button: `button.esp32_ir_remote_control_edifier_power`
    *   Mute Button: `button.esp32_ir_remote_control_edifier_mute`
    *   Volume Up: `button.esp32_ir_remote_control_edifier_volume_up`
    *   Volume Down: `button.esp32_ir_remote_control_edifier_volume_down`
    *   Bluetooth Input: `button.esp32_ir_remote_control_edifier_bluetooth`
    *   AUX Input: `button.esp32_ir_remote_control_edifier_aux_line_in`

---

## 📦 Build Instructions

### Prerequisites
*   Flutter SDK installed (v3.0.0 or higher)
*   Android SDK / Android Studio configured

### Step-by-Step Build
1.  Navigate to the project root directory:
    ```bash
    cd esp_speaker_control
    ```
2.  Fetch packages and dependencies:
    ```bash
    flutter pub get
    ```
3.  Compile and build the release APK:
    ```bash
    flutter build apk --release
    ```
4.  The compiled package will be located at:
    `build/app/outputs/flutter-apk/app-release.apk`