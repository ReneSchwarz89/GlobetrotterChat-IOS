# GlobetrotterChat

## Projektbeschreibung
GlobetrotterChat ist eine iOS-Anwendung, die es Benutzern ermöglicht, in verschiedenen Sprachen zu kommunizieren. Die App bietet Funktionen wie Echtzeit-Übersetzungen, Profilverwaltung, Bild-Uploads, einen Kontaktmanager mit QR-Code-Abfrage und Gruppenchats.


## Hauptfunktionen
- **Echtzeit-Übersetzungen**: Nachrichten werden automatisch in die Muttersprache des Empfängers übersetzt.
- **Profilverwaltung**: Benutzer können ihre Profile erstellen und bearbeiten.
- **Bild-Uploads**: Benutzer können Profilbilder hochladen und anzeigen.
- **Kontaktmanager**: Kontakte können über QR-Code oder einzigartigen Token hinzugefügt werden.
- **Gruppenchats**: Benutzer können Gruppenchats erstellen und daran teilnehmen.


## Technologien
- **Programmiersprache**: Swift
- **Architektur**: MVVM (Model-View-ViewModel)
- **Backend**: Firebase Firestore, Firebase Auth, Firebase Storage
- **Übersetzungs-API**: ([DeepL Translation API](https://support.deepl.com/hc/de/articles/360019358899-Zugriff-auf-die-DeepL-API))
- **Bibliotheken**: ([Combine](https://developer.apple.com/documentation/combine)), Firebase


## Installation
### Voraussetzungen
- Xcode installiert ([Tutorial](https://www.youtube.com/watch?v=8Xcq4yRQ0pU))
- DeepL API Konto ([Tutorial](https://support.deepl.com/hc/de/articles/360019358899-Zugriff-auf-die-DeepL-API))
- Firebase Projekt eingerichtet ([Tutorial](https://www.youtube.com/watch?v=khgQQTwpvxk))

### Schritte
1. **Repository klonen**:
    ```bash
    git clone https://github.com/dein-repo/globetrotterchat-ios.git
    ```
2. **Projekt in Xcode öffnen**:
    - Öffne Xcode.
    - Wähle `File > Open` und navigiere zum geklonten Repository.

3. **Abhängigkeiten installieren**:
    - Öffne dein Projekt in Xcode.
    - Wähle `File > Add Packages...`.
    - Füge die URLs der benötigten Pakete hinzu (z.B. `https://github.com/firebase/firebase-ios-sdk` für Firebase).
    - Wähle die gewünschte Version und füge das Paket zu deinem Projekt hinzu.

4. **DeepL Translation API einrichten**:
    - Erstelle ein DeepL API Konto ([Tutorial](https://support.deepl.com/hc/de/articles/360019358899-Zugriff-auf-die-DeepL-API)).
    - Erstelle einen API-Schlüssel.
    - Füge den API-Schlüssel in deiner `Info.plist` Datei oder in einer separaten Konfigurationsdatei hinzu.

5. **Firebase einrichten**:
    - Erstelle ein Firebase-Projekt ([Tutorial](https://www.youtube.com/watch?v=khgQQTwpvxk)).
    - Füge deine iOS-App zu Firebase hinzu und binde die `GoogleService-Info.plist` Datei in dein Projekt ein.
    - Aktiviere Firebase Auth, Firestore und Storage in der Firebase-Konsole.

## Verwendung
1. **Registrierung und Anmeldung**:
    - Benutzer können sich mit ihrer E-Mail-Adresse und einem Passwort registrieren und anmelden.

2. **Profilverwaltung**:
    - Benutzer können ihr Profil erstellen und bearbeiten, einschließlich des Hochladens eines Profilbildes.

3. **Nachrichten senden und empfangen**:
    - Benutzer können Nachrichten in Echtzeit senden und empfangen.
    - Nachrichten werden automatisch in die Muttersprache des Empfängers übersetzt.

4. **Kontaktmanager**:
    - Benutzer können Kontakte über QR-Code-Abfrage oder einen einzigartigen Token hinzufügen, der beim Erstellen des Accounts generiert wird.

5. **Gruppenchats**:
    - Benutzer können Gruppenchats erstellen und daran teilnehmen.


## Mitwirkende
- **René Schwarz** - ([GitHub-Profil](https://github.com/ReneSchwarz89))

## Lizenz
Dieses Projekt steht unter der MIT-Lizenz. Weitere Informationen findest du in der ([LICENSE](https://github.com/ReneSchwarz89/GlobetrotterChat-IOS/blob/main/LICENSE)) Datei.
