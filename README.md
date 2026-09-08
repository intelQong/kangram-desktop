# Kangram Desktop

Privacy and control oriented Telegram Desktop fork with Anti-Recall, Duress Panic Wipe, Ghost Mode, and Restriction Bypasses.

---

## Key Features

- **Anti-Recall (Message History)**: View deleted and edited messages with timestamps and history stored safely in a local SQLite database.
- **Duress Passcode / KABOOM Wipe**: Enter a designated Duress Passcode on the lock screen (or exceed 10 failed unlock attempts) to instantly wipe session keys, SQLite databases, and immediately terminate the process.
- **Bypass Restrictions**: Save images/videos and forward messages freely from restricted/protected channels and chats (`noforwards` bypass).
- **TTL Media Persistence**: Prevent automatic self-destruction of view-once photos/videos until you explicitly dismiss them.
- **Flexible Ghost Mode**: Hide online presence, read receipts, and typing indicators.
- **No Advertisements**: Remove all sponsored messages and ads from channels.
- **Unlimited Multi-Account**: Support for up to 100 concurrent accounts.
- **Zero Telemetry**: Crash reporting to third-party endpoints is disabled by default for complete privacy.

---

## Distributions & Packaging

### Linux (.deb Package)
To package a `.deb` package on Debian / Ubuntu:
```bash
./debian/build_deb.sh "7.0.9" "amd64" "out/Release/Telegram" "."
sudo dpkg -i kangram-desktop_7.0.9_amd64.deb
```

### Windows (.exe Installer & Portable)
Windows standalone executable (`Kangram.exe`) and Inno Setup installer (`KangramSetup.exe`) are automatically compiled and packaged via GitHub Actions CI.

---

## Open Source Credits & Acknowledgements

Kangram Desktop is built upon and inspired by the incredible open-source Telegram ecosystem:

1. **[Telegram Desktop](https://github.com/telegramdesktop/tdesktop)** — Official base desktop client and MTProto protocol implementation by Telegram FZ-LLC.
2. **[AyuGram Desktop](https://github.com/AyuGram/AyuGramDesktop)** — Ghost mode mechanics, message filters, and anti-recall SQLite engine by @Radolyn and contributors.
3. **[Telegraher](https://github.com/nikitasius/Telegraher)** — Duress passcode / KABOOM panic wipe routines, emergency drawer exit, 100 accounts expansion, and forwarding bypasses.
4. **[Exteragram](https://github.com/exteragram/exteragram)** — Custom profile badge layout and UI styling improvements.
5. **[Desktop App Toolkit](https://github.com/desktop-app)** — Shared C++ libraries, styles, and UI components (`lib_ui`, `lib_base`, `lib_rpl`, `lib_crl`).

---

## License

Licensed under the [GNU General Public License v3.0 (GPL-3.0)](https://www.gnu.org/licenses/gpl-3.0.en.html).
