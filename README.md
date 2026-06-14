**Projektübersicht**
- **Ziel:** Ein kleines, erweiterbares Debootstrap-basiertes System-Builder-Skript, das aus einer minimalen Basis ein komplettes System mit meinen Einstellungen aufbaut.
- **Architektur (vereinfacht):** tempfs <- debootstrap (--variant=minbase) <- template (Ordner) <- chroot (bash /debootstrap/install.sh) <- Installation & Konfiguration (base, bootloader, desktop, user)

**Schnellstart**
- Voraussetzungen: Root/Sudo, Internetzugang, `debootstrap` auf Host.
- Anpassungen: Editiere [config.env](config.env) (Zielpartitionen, Install-Steps, Variablen).
- Ausführen (aus dem Projektordner):

```bash
cd /media/storage/Dateien/Dokus/Linux/scripts/debootstrap
./debootstrap.sh
```

Hinweis: `debootstrap.sh` mountet/bindet /dev,/proc,/sys und führt `chroot $target_root /debootstrap/install.sh` aus.

**Wichtige Dateien**
- **Konfiguration:** [config.env](config.env)
- **Starter:** [debootstrap.sh](debootstrap.sh)
- **Template (chroot):** [template/debootstrap/install.sh](template/debootstrap/install.sh)
- **Basis-Tasks:** [template/debootstrap/base/](template/debootstrap/base/)
- **Bootloader-Tasks:** [template/debootstrap/bootloader/](template/debootstrap/bootloader/)
- **Desktop-Tasks:** [template/debootstrap/desktop/](template/debootstrap/desktop/)
- **Paketlisten:** `packages-*.txt` im Projektroot und `template/.../*.txt`

**Wichtige Konfig-Variablen (in config.env)**
- `target_root` — Arbeitsverzeichnis / chroot-Ziel
- `INSTALL_STEPS` — Komma-getrennte Steps (z. B. base,bootloader,desktop,user)
- Bootloader:
  - `INSTALL_BOOTLOADER` = none | grub-efi | grub-pc
  - `BOOTLOADER_EFI_PARTITION` (z. B. /dev/sdx3)
  - `BOOTLOADER_BIOS_DEVICE` (z. B. /dev/sdx)
  - `FORMART_EFI_PARTITION` (true/false) — Achtung: Name im Repo steht so
- Fstab-Einträge:
  - `FSTAB_ROOT_DEVICE` (UUID=...)
  - `FSTAB_ROOT_DEVICE_TYPE` (z. B. btrfs)
  - `FSTAB_ROOT_MOUNT_OPTIONS`
  - `FSTAB_BOOT_EFI_DEVICE`, `FSTAB_BOOT_EFI_DEVICE_MOUNTPOINT`
  - `FSTAB_BOOT_BIOS_DEVICE`, `FSTAB_BOOT_BIOS_DEVICE_MOUNTPOINT`
- Logging: `/debootstrap/install.log` (wird vom Skript beschrieben)

**Non-interactive APT (empfohlen für Automatisierung)**
- Setze vor Paketinstallationen im chroot:

```bash
export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical
# debconf-set-selections für keyboard-configuration wenn nötig
```

**Troubleshooting (häufige Fallen)**
- `grub-install`/`grub-probe` meckert wenn `/dev` nicht eingebunden ist — Host muss /dev,/proc,/sys in den Chroot binden.
- Wenn `grub-install` auf UEFI lesen/ schreiben soll: stelle sicher, dass `/boot/efi` gemountet (FAT32) ist.
- Fehlende Tools: `zstd` und `btrfs-progs` werden für `initramfs` und btrfs-Unterstützung benötigt; füge sie zur Kernel-Paketliste hinzu.
- Interaktive Abfragen (z. B. keyboard-configuration) mit `DEBIAN_FRONTEND=noninteractive` + `debconf-set-selections` lösen.

**Erweiterbarkeit**
- Neue Installations-Schritte: leg ein neues Verzeichnis unter `template/debootstrap/` an und füge Shell-Skripte hinzu; setze `INSTALL_STEPS` entsprechend.
- Paketlisten: Ergänze `template/.../*.txt` oder die root `packages-*.txt`.
- Anpassungen: `install.sh` sourced `config.env` und führt die angegebenen Step-Skripte mit `.` aus (Scope bleibt erhalten).

**Kurz:**
Mein kurzes Custom-System-Skript erlaubt es, ein aktuelles System mit meinen Programmen und Einstellungen in wenigen Sekunden automatisiert aufzubauen — modular, erweiterbar und einfach zu pflegen.

---
Wenn du willst, schreibe ich noch eine kurze Checkliste für UEFI vs. BIOS-Installationen oder ein Beispiel `config.env` für eine typische Installation.
