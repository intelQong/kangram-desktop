# PROJECT CONTEXT: Kangram Desktop

> **Note for AI Agents & Developers**: This document provides immediate context, architectural history, component mappings, and operational guidelines for **Kangram Desktop**. Always update this file when modifying core features, adding patches, or changing build pipelines.

---

## 1. Project Overview & Identity

* **Project Name**: Kangram Desktop
* **Repository**: `intelQong/kangram-desktop` (Private)
* **Base Codebase**: [AyuGramDesktop](https://github.com/AyuGram/AyuGramDesktop) (C++20 / Qt6 fork of Telegram Desktop)
* **Reference & Feature Origin**: [Telegraher](https://github.com/nikitasius/Telegraher) (Android fork by Nikita S. / nikitasius)
* **License**: GNU General Public License v3.0 (GPL-3.0)
* **Target Platforms & Packages**:
  * **Linux**: Debian / Ubuntu standalone package (`.deb`) and portable tarball (`.tar.xz`).
  * **Windows**: Standalone portable executable (`Kangram.exe` / `.zip`) and Inno Setup installer (`KangramSetup.exe`).

---

## 2. Core Philosophy & Value Proposition

Kangram Desktop restores **total local control, sovereignty, and privacy** to the user on desktop devices:
1. **No remote deletions**: Messages deleted or edited by other participants remain intact in local storage with clear visual indicators and timestamps.
2. **No arbitrary restrictions**: `noforwards`, `restrict_saving_content`, and TTL timers cannot block saving media, copying text, or forwarding.
3. **Plausible deniability & duress protection**: A secondary Duress Passcode or repeated failed unlock attempts triggers an immediate recursive wipe of local data ("KABOOM") and process termination.
4. **No surveillance or advertisements**: Stripped of telemetry, trackers, and sponsored channel ads.
5. **Multi-account scale**: Supports up to 100 simultaneous accounts with client/device spoofing.

---

## 3. Directory Layout & Architecture Map

```
/
├── .github/
│   ├── workflows/
│   │   ├── build_linux_deb.yml   # CI/CD: Packages .deb binary
│   │   ├── build_windows_exe.yml # CI/CD: Packages .exe installer & .zip
│   │   └── release.yml           # CI/CD: Publishes release assets on git tags
│   └── art/                      # Branding assets
├── debian/
│   ├── control                   # Debian package metadata and dependencies
│   ├── kangram.desktop           # Freedesktop system application launcher
│   ├── kangram.png               # High-resolution application icon
│   └── build_deb.sh              # Automated .deb generation script
├── Telegram/
│   ├── CMakeLists.txt            # Main CMake target definitions
│   ├── Resources/
│   │   └── art/kangram.png       # Core application branding asset
│   ├── SourceFiles/
│   │   ├── core/
│   │   │   └── version.h         # AppName = "Kangram Desktop", AppFile = "Kangram", Version 7.0.9
│   │   ├── ayu/                  # Kangram / Ayu custom subsystem
│   │   │   ├── ayu_settings.h    # Settings state, duress methods & panic wipe
│   │   │   ├── ayu_settings.cpp  # JSON persistence and panic execution
│   │   │   ├── data/             # SQLite database layer for anti-recall
│   │   │   └── ui/settings/      # Custom Kangram Settings UI panels
│   │   ├── data/
│   │   │   ├── data_channel.cpp  # allowsForwarding() -> true (restriction bypass)
│   │   │   ├── data_chat.cpp     # allowsForwarding() -> true
│   │   │   ├── data_user.cpp     # allowsForwarding() -> true
│   │   │   └── data_story.cpp    # forbidsForward() -> false
│   │   ├── history/
│   │   │   ├── history_item.cpp  # forbidsForward() -> false
│   │   │   └── history.cpp       # Deletion hook & message retention
│   │   ├── window/
│   │   │   ├── window_lock_widgets.cpp # Duress Passcode & bad tries panic hook
│   │   │   └── window_main_menu.cpp    # Drawer menus & Kangram links
│   │   └── boxes/
│   │       └── about_box.cpp     # About Kangram dialog
│   └── build/
│       └── setup.iss             # Inno Setup Windows installer script
└── docs/
    ├── ARCHITECTURE.md           # Deep technical subsystem specifications
    └── BRAINSTORM_SUPERPOWERS.md # Future superpowers roadmap
```

---

## 4. Telegraher -> Kangram Desktop Patch Matrix

| Telegraher Feature (Android/Java) | Kangram Desktop Implementation (C++20/Qt) | Status | Key Files |
| :--- | :--- | :--- | :--- |
| **Duress Passcode / KABOOM** | `AyuSettings::isDuressPasscode()`, `PasscodeLockWidget::submit()` panic hook | ✅ Active | `window_lock_widgets.cpp`, `ayu_settings.cpp` |
| **Fail-Safe Bad Tries Wipe** | `cPasscodeBadTries()` >= 10 -> `AyuSettings::executePanicWipe()` | ✅ Active | `window_lock_widgets.cpp` |
| **Anti-Recall (Deleted Messages)** | Intercept delete updates -> SQLite persistent message storage | ✅ Active | `ayu/data/ayu_database.cpp`, `history.cpp` |
| **No-Forwards Bypass** | Unconditional `true` in `allowsForwarding()` across all peer types | ✅ Active | `data_channel.cpp`, `data_chat.cpp`, `data_user.cpp` |
| **Protected Story Saving** | `Story::forbidsForward()` returns `false` | ✅ Active | `data_story.cpp` |
| **No Advertisements** | `Data::Session::sponsoredMessages()` returns empty list | ✅ Active | `ayu_settings.cpp`, `data_session.cpp` |
| **Ghost Mode** | Suppress read receipts, typing packets, and online presence | ✅ Active | `ayu_settings.cpp`, `data_send_action_manager.cpp` |
| **100+ Accounts Support** | `Main::Domain::kMaxAccounts = 100` | ✅ Active | `main_domain.h`, `main_domain.cpp` |

---

## 5. Build, Package & Release Commands

### Packaging Debian (`.deb`) Locally:
```bash
./debian/build_deb.sh "7.0.9" "amd64" "out/Release/Telegram" "."
sudo dpkg -i kangram-desktop_7.0.9_amd64.deb
```

### Packaging AppImage Locally:
```bash
./scripts/build_appimage.sh "7.0.9" "arm64" "out/Release/Telegram" "."
./scripts/build_appimage.sh "7.0.9" "x86_64" "out/Release/Telegram" "."
```

### Packaging Portable Tarball (`.tar.xz`) Locally:
```bash
./scripts/build_portable.sh "7.0.9" "arm64" "out/Release/Telegram" "."
./scripts/build_portable.sh "7.0.9" "x86_64" "out/Release/Telegram" "."
```

### Triggering Cloud Builds (GitHub Actions):
* **Linux DEB (amd64)**: [GitHub Actions Linux Workflow](https://github.com/intelQong/kangram-desktop/actions/workflows/build_linux_deb.yml)
* **Linux Flatpak (arm64)**: [GitHub Actions Flatpak ARM64 Workflow](https://github.com/intelQong/kangram-desktop/actions/workflows/build_flatpak_arm64.yml)
* **Windows EXE**: [GitHub Actions Windows Workflow](https://github.com/intelQong/kangram-desktop/actions/workflows/build_windows_exe.yml)

### Installing Flatpak Bundle Locally:
```bash
flatpak install --user kangram-desktop-arm64.flatpak
```

### Creating a Tagged Release:
```bash
git tag v7.0.9
git push origin v7.0.9
```
This triggers `.github/workflows/release.yml` which compiles and publishes `.deb` and `.exe` assets directly to GitHub Releases.
