# Kangram Desktop

Privacy and control oriented Telegram Desktop fork with Anti-Recall, Duress Panic Wipe, Ghost Mode, and Restriction Bypasses.

## Features

- **Anti-Recall (Message History)**: View deleted and edited messages with timestamps and history.
- **Duress Passcode / Panic Wipe**: Wipe all local session data, encryption keys, and SQLite storage upon entering a configured duress code.
- **Bypass Restrictions**: Save images/videos and forward messages from protected channels/chats (`noforwards` bypass).
- **TTL Media Persistence**: Prevent automatic self-destruction of view-once photos/videos until explicitly dismissed.
- **Flexible Ghost Mode**: Hide online presence, read receipts, and typing indicators.
- **No Advertisements**: Remove all sponsored messages in channels.
- **Unlimited Multi-Account**: Support for 100+ accounts with device spoofing options.

---

## Distributions & Packaging

### Linux (.deb Package)
To package a `.deb` package on Debian / Ubuntu:
```bash
./debian/build_deb.sh "1.0.0" "amd64" "path/to/Telegram" "."
sudo dpkg -i kangram-desktop_1.0.0_amd64.deb
```

### Windows (.exe Installer & Portable)
Windows standalone executable (`Kangram.exe`) and Inno Setup installer (`KangramSetup.exe`) are automatically built via GitHub Actions.

---

## License
Licensed under the GNU General Public License v3.0 (GPL-3.0).
