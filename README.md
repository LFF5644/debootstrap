# Debian Debootstrap System Builder

Ein modulares Bash-System zum automatisierten Aufbau einer eigenen Debian-Installation auf Basis von `debootstrap`.

Das Projekt baut zunächst ein minimales Debian-System auf und erweitert dieses anschließend Schritt für Schritt über konfigurierbare Installationsmodule. Dadurch lassen sich unterschiedliche Installationen aus derselben Basis reproduzierbar aufbauen – von einer schlanken CLI-Installation bis zu einem Desktop-System.

## ✨ Eigenschaften

- Debian-Basis mit `debootstrap --variant=minbase`
- modularer Installationsablauf über `INSTALL_STEPS`
- Installation und Konfiguration innerhalb eines Chroots
- frei konfigurierbare Paketlisten
- optionaler GRUB-Bootloader für BIOS oder UEFI
- optionale MATE-Desktop-Umgebung
- Benutzeranlage und Gruppenverwaltung
- optionales automatisches Login über LightDM
- zusätzliche Installer für ausgewählte Desktop-Anwendungen
- optionaler Folding@Home-Client
- Unterstützung für eigene Erweiterungsmodule
- Hilfsskripte für weitere Installations-/Image-Workflows

## 🧩 Wie funktioniert es?

Der grundlegende Ablauf sieht vereinfacht so aus:

```text
Host
 │
 ├─ debootstrap
 │      │
 │      ▼
 │   minimale Debian-Basis
 │      │
 │      ▼
 │   /debootstrap/install.sh
 │      │
 │      ├─ base
 │      ├─ Netzwerk / System
 │      ├─ Desktop
 │      ├─ Benutzer
 │      ├─ Bootloader
 │      └─ weitere Module
 │
 ▼
fertig konfiguriertes Debian-System
```

Der eigentliche modulare Teil befindet sich unter:

```text
template/debootstrap/
```

`template/debootstrap/install.sh` liest `INSTALL_STEPS` aus der Konfiguration. Für jeden angegebenen Step werden die vorhandenen Shell-Skripte aus dem entsprechenden Verzeichnis in Dateinamen-Reihenfolge ausgeführt.

Beispiel:

```bash
INSTALL_STEPS=base,pkg-foldingAtHome,desktop,user,bootloader
```

Damit entscheidet die Konfiguration, welche Teile des Systems aufgebaut werden.

---

## 🚀 Schnellstart

### Voraussetzungen

Auf dem Host werden unter anderem benötigt:

- Debian/Linux
- Root-Rechte bzw. `sudo`
- Internetzugang
- `debootstrap`
- ein geeignetes Ziel für die Installation

Debootstrap kann beispielsweise über APT installiert werden:

```bash
sudo apt install debootstrap
```

### Repository klonen

```bash
git clone https://github.com/LFF5644/debootstrap.git
cd debootstrap
```

### Konfiguration anpassen

Die zentrale Konfiguration befindet sich in:

```text
config.env
```

Dort werden unter anderem Installationsschritte, Zielpfade, Bootloader und Benutzeroptionen festgelegt.

Danach kann der Builder gestartet werden:

```bash
sudo ./debootstrap.sh
```

**Wichtig:** Das Skript kann abhängig von der Konfiguration auf reale Zielgeräte bzw. Dateisysteme zugreifen. Prüfe `config.env` daher vor dem Start sorgfältig.

---

## ⚙️ Konfiguration

Die wichtigste Datei ist:

```text
config.env
```

Ein zentraler Schalter ist `INSTALL_STEPS`.

Beispiel:

```bash
INSTALL_STEPS=base,desktop,user,bootloader
```

Dadurch können Installationsprofile zusammengestellt werden, ohne den eigentlichen Installer umzuschreiben.

Weitere Konfigurationsbereiche umfassen unter anderem:

| Bereich | Beispiele |
|---|---|
| Zielsystem | Arbeits-/Installationspfade |
| Installation | `INSTALL_STEPS`, Chroot-Modus |
| Bootloader | `none`, `grub-efi`, `grub-pc` |
| Hostname | neuer System-Hostname |
| Benutzer | Benutzername, Gruppen |
| Root | optionales Root-Passwort |
| Desktop | MATE / Desktop-Pakete |
| Autologin | LightDM-Autologin |
| Folding@Home | Client, Autostart, Konfiguration |

Die konkrete Konfiguration kann sich mit der Weiterentwicklung des Projekts ändern. Maßgeblich ist daher immer die aktuelle `config.env`.

---

## 🏗️ Projektstruktur

Die wichtigsten Bestandteile:

```text
.
├── debootstrap.sh
├── config.env
├── copy_to_real.sh
├── squashfs.sh
├── prompt.sh
├── packages-include.txt
├── packages-exclude.txt
├── IDEAS.md
│
└── template/
    └── debootstrap/
        ├── install.sh
        ├── base/
        ├── bootloader/
        ├── desktop/
        ├── user/
        ├── pkg-foldingAtHome/
        └── ...
```

### `debootstrap.sh`

Der Einstiegspunkt auf dem Host.

Er bereitet die Debian-Basis vor, verarbeitet die Paketlisten und startet anschließend den eigentlichen Installationsablauf im vorbereiteten System.

### `config.env`

Zentrale Konfiguration des Builders.

### `template/debootstrap/install.sh`

Der zentrale Dispatcher innerhalb des Chroots.

Er liest `INSTALL_STEPS` und führt die zugehörigen Module aus.

### `template/debootstrap/`

Hier liegen die eigentlichen Installationsmodule.

Neue Funktionen können dadurch als eigene Steps ergänzt werden.

### `copy_to_real.sh`

Hilfsskript für das Übertragen bzw. Weiterverarbeiten des erzeugten Systems auf ein reales Ziel.

### `squashfs.sh`

Zusätzliches Hilfsskript für einen SquashFS-/Live-System-orientierten Workflow.

### Paketlisten

Paketlisten liegen sowohl im Projektroot als auch innerhalb der jeweiligen Module.

Beispiele:

```text
packages-include.txt
packages-exclude.txt
template/debootstrap/base/
template/debootstrap/desktop/
```

Dadurch können Basispakete und optionale Komponenten getrennt gepflegt werden.

---

## 📦 Paketverwaltung

Das Projekt verwendet mehrere Paketlisten, statt sämtliche Pakete direkt in die Bash-Skripte zu schreiben.

Dadurch können Installationen relativ einfach angepasst werden.

Beispielsweise gibt es Listen für:

- Basis-Pakete
- CLI-/Systemwerkzeuge
- Netzwerkwerkzeuge
- Desktop-/MATE-Pakete
- GTK-Anwendungen
- GRUB BIOS
- GRUB EFI
- optionale Zusatzsoftware

Einige Pakete sind bewusst auskommentiert und können bei Bedarf aktiviert werden.

Zusätzlich können mit den globalen Include-/Exclude-Listen Pakete zur Installation hinzugefügt oder ausgeschlossen werden.

---

## 🖥️ Desktop

Das Projekt kann optional eine MATE-Umgebung aufbauen.

Dazu gehören unter anderem:

- MATE Desktop
- LightDM
- Xorg
- MATE Panel
- MATE Terminal
- MATE System Monitor
- MATE Power Management
- passende Themes/Icon-Pakete

Zusätzliche Desktop-Anwendungen werden über eigene Module installiert.

Beispiele im Projekt sind:

- Firefox ESR
- VLC
- Audacity
- Git
- GParted
- Remmina
- Mixxx
- Discord
- Signal Desktop
- Spotify
- Sublime Text
- Redshift

Nicht jede Anwendung ist standardmäßig aktiviert. Welche Komponenten tatsächlich installiert werden, hängt von der Konfiguration und den Paketlisten ab.

---

## 👤 Benutzer

Das Benutzer-Modul kann einen normalen Benutzer anlegen und ihn mehreren konfigurierten Gruppen hinzufügen.

Zusätzlich kann optional:

- ein Root-Passwort gesetzt werden
- ein automatisches Login über LightDM eingerichtet werden

Das Autologin-Modul verwendet dafür eine LightDM-Konfiguration und setzt die MATE-Session als Sitzung.

---

## 🔧 Bootloader

Unterstützt werden konfigurierbar:

```text
none
grub-pc
grub-efi
```

Damit kann der Builder sowohl für klassische BIOS-Systeme als auch für UEFI-Installationen verwendet werden.

Die genaue Partitionierung und die verwendeten Geräte hängen von der jeweiligen `config.env` und dem Zielsystem ab.

**Achtung:** Bootloader- und Partitionsoperationen sind potentiell destruktiv. Vor einer Installation unbedingt die Zielgeräte und Konfiguration kontrollieren.

---

## 🧱 Erweiterbarkeit

Eine der wichtigsten Eigenschaften des Projekts ist die modulare Struktur.

Ein neuer Installationsschritt kann grundsätzlich als eigenes Verzeichnis unter:

```text
template/debootstrap/
```

angelegt werden.

Beispiel:

```text
template/debootstrap/
└── my-feature/
    ├── 00-install.sh
    ├── 10-config.sh
    └── 20-service.sh
```

Anschließend wird der Step in `INSTALL_STEPS` aufgenommen:

```bash
INSTALL_STEPS=base,my-feature,user,bootloader
```

Die Nummerierung der Dateien kann genutzt werden, um die Reihenfolge innerhalb eines Moduls festzulegen.

Dadurch lässt sich der Builder erweitern, ohne den zentralen Installer mit immer mehr Sonderfällen zu füllen.

---

## 🐧 Folding@Home

Das Projekt enthält außerdem ein optionales Modul für Folding@Home.

Das Modul kann unter anderem:

- den Client nach `/opt/fah-client` installieren
- einen eigenen Systembenutzer anlegen
- einen systemd-Service erzeugen
- den Dienst optional automatisch starten
- die Client-Konfiguration mit Benutzer-/Teamdaten vorbereiten

Die Zugangsdaten bzw. Tokens gehören in die lokale Konfiguration und sollten **niemals in das öffentliche Repository committed werden**.

---

## 🔐 Secrets

Das Projekt verwendet zusätzlich eine lokale `secrets.env`.

Dort können sensible Werte abgelegt werden, die nicht Bestandteil der öffentlichen Projektdateien sein sollten.

**Keine Passwörter, Tokens oder andere Zugangsdaten in Git committen.**

Vor dem Veröffentlichen oder Pushen sollte insbesondere geprüft werden, ob lokale Konfigurationsdateien persönliche oder infrastrukturelle Informationen enthalten.

---

## 🧪 Aktueller Charakter des Projekts

Dieses Repository ist kein universeller Debian-Installer wie der Debian-Installer selbst.

Es ist vielmehr ein **persönlicher, modularer System-Builder**, der darauf ausgelegt ist, eine definierte Debian-Umgebung automatisiert aus einer minimalen Basis aufzubauen.

Der Schwerpunkt liegt auf:

- reproduzierbaren Installationen
- persönlicher Systemkonfiguration
- modularen Bash-Skripten
- schneller Anpassbarkeit
- kleinen/minimalen Debian-Basen
- Experimentieren mit eigenen Installationsworkflows

Einige Hilfsskripte und Module befinden sich entsprechend im Entwicklungs-/Experimentierstadium.

---

## 🛠️ Troubleshooting

### Installation bleibt bei einem Paket hängen

Einige Debian-Pakete können interaktive Konfigurationen auslösen. Besonders bei `keyboard-configuration` oder ähnlichen Paketen kann dies relevant sein.

Prüfe in diesem Fall die Paketinstallation und die verwendeten Debconf-/APT-Einstellungen.

### Bootloader funktioniert nicht

Prüfe:

- korrektes Zielgerät
- BIOS vs. UEFI
- gemountete EFI-Partition bei UEFI
- vorhandene `/dev`, `/proc` und `/sys` Bind-Mounts im Chroot
- verwendete GRUB-Pakete

### Chroot funktioniert nicht

Der Installationsablauf benötigt innerhalb des Chroots Zugriff auf die für die Installation notwendigen virtuellen Dateisysteme.

Der Host-seitige Installer kümmert sich entsprechend um die benötigten Mounts.

---

## 📋 Eigene Installationsprofile

Der modulare Aufbau eignet sich auch dafür, verschiedene Profile zu definieren.

Beispielsweise:

### Minimal

```bash
INSTALL_STEPS=base,user
```

### Desktop

```bash
INSTALL_STEPS=base,desktop,user,bootloader
```

### Desktop + Folding@Home

```bash
INSTALL_STEPS=base,pkg-foldingAtHome,desktop,user,bootloader
```

Welche Kombination sinnvoll ist, hängt vom Zielsystem ab.

---

## 🤝 Eigene Erweiterungen

Wenn du das Projekt erweitern möchtest:

1. vorhandene Module ansehen
2. einen eigenen Step unter `template/debootstrap/` erstellen
3. die Shell-Skripte nummerieren
4. benötigte Pakete in einer Paketliste definieren
5. den neuen Step in `INSTALL_STEPS` aufnehmen
6. auf einer Testinstallation prüfen

Dabei sollten Module möglichst eigenständig bleiben und keine unnötigen Änderungen am zentralen `install.sh` benötigen.

---

## ⚠️ Hinweis

Dieses Projekt arbeitet mit Root-Rechten und kann abhängig von der Konfiguration Dateisysteme, Partitionen, Bootloader und Systemdateien verändern.

**Nicht auf einem produktiven System testen, ohne die Konfiguration und Zielgeräte vorher zu überprüfen.**

Backups wichtiger Daten werden ausdrücklich empfohlen.

---

## 📄 Lizenz

Eine verbindliche Lizenz sollte im Repository separat als `LICENSE` hinterlegt werden. Solange keine entsprechende Lizenzdatei vorhanden ist, gelten die normalen urheberrechtlichen Schutzbestimmungen.

---

## 👨‍💻 Autor

**LFF5644**

Persönlicher Debian-/Linux-System-Builder mit Fokus auf Bash, Automatisierung und modularen Installationsabläufen.

Repository:

https://github.com/LFF5644/debootstrap
