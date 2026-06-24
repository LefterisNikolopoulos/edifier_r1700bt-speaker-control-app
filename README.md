# Edifier Speaker Control App

Μια προσαρμοσμένη και υψηλής απόδοσης εφαρμογή (companion app) σε **Flutter**, σχεδιασμένη για τον απομακρυσμένο έλεγχο των λειτουργιών των ηχείων Edifier (Power, Volume, Mute, Bluetooth/AUX inputs) μέσω του **Home Assistant**.

Η εφαρμογή επικοινωνεί με μια συσκευή ESP32 (IR blaster) που είναι ενσωματωμένη στο Home Assistant, η οποία αναπαράγει και εκπέμπει τα υπέρυθρα σήματα (IR) του φυσικού τηλεκοντρόλ Edifier. Περιλαμβάνει επίσης πλήρη υποστήριξη Android Home Screen Widgets για άμεσο έλεγχο από την αρχική οθόνη.

---

## 🛠️ Τεχνικά Χαρακτηριστικά & Υλοποίηση

*   **Προσαρμοσμένο UI Τηλεκοντρόλ**: Σχεδίαση ενός σύγχρονου και εύχρηστου γραφικού περιβάλλοντος σε σκοτεινό θέμα (Dark Theme) με Material 3, βελτιστοποιημένου για χρήση με το ένα χέρι.
*   **Ενσωμάτωση Απτικής Ανάδρασης (Haptic Feedback)**: Υλοποίηση δόνησης κατά το πάτημα των πλήκτρων για την προσομοίωση της φυσικής αίσθησης ενός τηλεκοντρόλ.
*   **Διαδραστικά Widgets Αρχικής Οθόνης**: Πλήρης ενσωμάτωση του πακέτου `home_widget` για την υποστήριξη widget στην αρχική οθόνη του Android. Επιτρέπει τον έλεγχο της τροφοδοσίας, της σίγασης και της έντασης χωρίς να απαιτείται το άνοιγμα της εφαρμογής, μέσω background callbacks.
*   **Συνεχόμενη Ρύθμιση Έντασης με Παρατεταμένο Πάτημα**: Υλοποίηση μηχανισμού χρονοδιακόπτη (`Timer.periodic`) για την επαναλαμβανόμενη αποστολή εντολών έντασης (Volume Up/Down) όσο ο χρήστης κρατάει πατημένο το πλήκτρο, εξομοιώνοντας τη λειτουργία του φυσικού τηλεκοντρόλ.
*   **Ασφαλής Επικοινωνία με Home Assistant API**: Σύνδεση με το Home Assistant μέσω REST API, κάνοντας χρήση Long-Lived Access Tokens (JWT) και HTTP POST requests για την ενεργοποίηση των button entities (`button.press`).
*   **Διαχείριση Εργασιών στο Παρασκήνιο (Background Callback Handler)**: Κατανομή και εκτέλεση εντολών μέσω background service (`@pragma("vm:entry-point")`) όταν ο χρήστης αλληλεπιδρά με τα widgets της αρχικής οθόνης.

---

## 🔌 Ρύθμιση & Παραμετροποίηση

Για να συνδέσετε την εφαρμογή με το δικό σας Home Assistant, τροποποιήστε τις μεταβλητές στο αρχείο [lib/main.dart](file:///c:/Users/lefte/Desktop/esp_speaker_control/lib/main.dart):

1.  **Στοιχεία Σύνδεσης**:
    *   Ορίστε το `homeAssistantUrl` στη διεύθυνση του δικού σας Home Assistant:
        ```dart
        const String homeAssistantUrl = 'http://YOUR_HA_IP:8123';
        ```
    *   Ορίστε το `accessToken` στο δικό σας Long-Lived Access Token:
        ```dart
        const String accessToken = 'YOUR_LONG_LIVED_ACCESS_TOKEN';
        ```
        *(Για τη δημιουργία του: Home Assistant -> Profile -> Long-Lived Access Tokens -> Create Token)*

2.  **Entity IDs**:
    Βεβαιωθείτε ότι τα entity IDs στο `lib/main.dart` αντιστοιχούν στα δικά σας buttons στο Home Assistant:
    *   Power: `button.esp32_ir_remote_control_edifier_power`
    *   Mute: `button.esp32_ir_remote_control_edifier_mute`
    *   Volume Up: `button.esp32_ir_remote_control_edifier_volume_up`
    *   Volume Down: `button.esp32_ir_remote_control_edifier_volume_down`
    *   Bluetooth: `button.esp32_ir_remote_control_edifier_bluetooth`
    *   AUX: `button.esp32_ir_remote_control_edifier_aux_line_in`

---

## 📦 Οδηγίες Μεταγλώττισης (Build)

### Προαπαιτούμενα
*   Εγκατεστημένο Flutter SDK (έκδοση v3.0.0 ή νεότερη)
*   Ρυθμισμένο Android SDK / Android Studio

### Διαδικασία Build
1.  Μεταβείτε στον φάκελο του project:
    ```bash
    cd esp_speaker_control
    ```
2.  Λήψη εξαρτήσεων και πακέτων:
    ```bash
    flutter pub get
    ```
3.  Μεταγλώττιση και δημιουργία του release APK:
    ```bash
    flutter build apk --release
    ```
4.  Το παραγόμενο αρχείο θα βρίσκεται στη διαδρομή:
    `build/app/outputs/flutter-apk/app-release.apk`