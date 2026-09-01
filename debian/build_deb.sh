#!/usr/bin/env bash
set -e

VERSION="${1:-1.0.0}"
ARCH="${2:-amd64}"
BINARY_PATH="${3:-../out/Release/Telegram}"
OUTPUT_DIR="${4:-.}"

if [ ! -f "$BINARY_PATH" ]; then
    echo "Error: Binary not found at $BINARY_PATH"
    echo "Usage: ./build_deb.sh [VERSION] [ARCH] [BINARY_PATH] [OUTPUT_DIR]"
    exit 1
fi

PKG_NAME="kangram-desktop_${VERSION}_${ARCH}"
PKG_DIR="/tmp/${PKG_NAME}"

echo "==> Packaging ${PKG_NAME}.deb..."

rm -rf "${PKG_DIR}"
mkdir -p "${PKG_DIR}/DEBIAN"
mkdir -p "${PKG_DIR}/usr/bin"
mkdir -p "${PKG_DIR}/usr/share/applications"
mkdir -p "${PKG_DIR}/usr/share/icons/hicolor/512x512/apps"

# Install binary
cp "$BINARY_PATH" "${PKG_DIR}/usr/bin/kangram"
chmod 755 "${PKG_DIR}/usr/bin/kangram"

# Install desktop entry
cp "$(dirname "$0")/kangram.desktop" "${PKG_DIR}/usr/share/applications/kangram.desktop"
chmod 644 "${PKG_DIR}/usr/share/applications/kangram.desktop"

# Install icon
if [ -f "$(dirname "$0")/kangram.png" ]; then
    cp "$(dirname "$0")/kangram.png" "${PKG_DIR}/usr/share/icons/hicolor/512x512/apps/kangram.png"
    chmod 644 "${PKG_DIR}/usr/share/icons/hicolor/512x512/apps/kangram.png"
fi

# Generate control file
cat <<EOF > "${PKG_DIR}/DEBIAN/control"
Package: kangram-desktop
Version: ${VERSION}
Architecture: ${ARCH}
Maintainer: Md Mahmudul Hoque Khan <117527321+intelQong@users.noreply.github.com>
Section: net
Priority: optional
Homepage: https://github.com/intelQong/kangram-desktop
Description: Kangram Desktop Messaging Client
 Kangram Desktop is a privacy and control oriented desktop client
 for Telegram with anti-recall message history, ghost mode, restriction
 bypasses, duress wipe, and multi-account support.
EOF

dpkg-deb --build "${PKG_DIR}" "${OUTPUT_DIR}/${PKG_NAME}.deb"
echo "==> Successfully generated: ${OUTPUT_DIR}/${PKG_NAME}.deb"
rm -rf "${PKG_DIR}"
