#!/usr/bin/env bash
set -e

VERSION="${1:-7.0.9}"
ARCH="${2:-amd64}"
BINARY_PATH="${3:-out/Release/Kangram}"
OUTPUT_DIR="${4:-.}"

# Normalize architecture naming
case "$ARCH" in
    x86_64|amd64)
        APPIMAGE_ARCH="x86_64"
        RUNTIME_ARCH="x86_64"
        DEB_ARCH="amd64"
        ;;
    aarch64|arm64)
        APPIMAGE_ARCH="aarch64"
        RUNTIME_ARCH="aarch64"
        DEB_ARCH="arm64"
        ;;
    *)
        APPIMAGE_ARCH="$ARCH"
        RUNTIME_ARCH="$ARCH"
        DEB_ARCH="$ARCH"
        ;;
esac

if [ ! -f "$BINARY_PATH" ]; then
    for cand in "$BINARY_PATH" "out/Release/Kangram" "out/Release/AyuGram" "out/Release/Telegram" "out/bin/Kangram" "out/bin/AyuGram" "out/bin/Telegram" "out/Kangram" "out/AyuGram" "out/Telegram" "../out/Release/Kangram" "../out/Release/AyuGram" "../out/Release/Telegram"; do
        if [ -f "$cand" ]; then
            BINARY_PATH="$cand"
            break
        fi
    done
fi

# Fallback: check if a .deb exists in current directory for this arch
if [ ! -f "$BINARY_PATH" ]; then
    DEB_CAND=$(ls -1 kangram-desktop_*_${DEB_ARCH}.deb 2>/dev/null | head -n 1 || true)
    if [ -n "$DEB_CAND" ] && [ -f "$DEB_CAND" ]; then
        echo "Extracting binary from ${DEB_CAND}..."
        TMP_EXTRACT="/tmp/kangram_deb_appimage_${APPIMAGE_ARCH}_$$"
        mkdir -p "${TMP_EXTRACT}"
        dpkg -x "${DEB_CAND}" "${TMP_EXTRACT}"
        BINARY_PATH="${TMP_EXTRACT}/usr/bin/kangram"
    fi
fi

if [ ! -f "$BINARY_PATH" ]; then
    echo "Error: Binary not found at $BINARY_PATH"
    echo "Usage: ./scripts/build_appimage.sh [VERSION] [ARCH] [BINARY_PATH] [OUTPUT_DIR]"
    exit 1
fi

APP_DIR="/tmp/Kangram_AppDir_${APPIMAGE_ARCH}_$$"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "==> Preparing AppDir for Kangram (${APPIMAGE_ARCH})..."
rm -rf "${APP_DIR}"
mkdir -p "${APP_DIR}/usr/bin"
mkdir -p "${APP_DIR}/usr/share/applications"
mkdir -p "${APP_DIR}/usr/share/icons/hicolor/512x512/apps"

# Copy binary
cp "$BINARY_PATH" "${APP_DIR}/usr/bin/kangram"
chmod 755 "${APP_DIR}/usr/bin/kangram"

# Copy desktop file and icon
cp "${REPO_ROOT}/debian/kangram.desktop" "${APP_DIR}/"
cp "${REPO_ROOT}/debian/kangram.desktop" "${APP_DIR}/usr/share/applications/"
cp "${REPO_ROOT}/debian/kangram.png" "${APP_DIR}/"
cp "${REPO_ROOT}/debian/kangram.png" "${APP_DIR}/.DirIcon"
cp "${REPO_ROOT}/debian/kangram.png" "${APP_DIR}/usr/share/icons/hicolor/512x512/apps/"

# Create custom AppRun that supports portable mode
cat << 'EOF' > "${APP_DIR}/AppRun"
#!/bin/sh
SELF=$(readlink -f "$0")
HERE=${SELF%/*}

export PATH="${HERE}/usr/bin:${PATH}"
export LD_LIBRARY_PATH="${HERE}/usr/lib:${LD_LIBRARY_PATH}"
export XDG_DATA_DIRS="${HERE}/usr/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"

# Detect if portable data directory exists next to AppImage
if [ -n "$APPIMAGE" ]; then
    APPIMAGE_DIR=$(dirname "$APPIMAGE")
    if [ -d "$APPIMAGE_DIR/TelegramForcePortable" ]; then
        exec "${HERE}/usr/bin/kangram" -workdir "$APPIMAGE_DIR/TelegramForcePortable" "$@"
    elif [ -d "$APPIMAGE_DIR/KangramForcePortable" ]; then
        exec "${HERE}/usr/bin/kangram" -workdir "$APPIMAGE_DIR/KangramForcePortable" "$@"
    elif [ -d "$APPIMAGE_DIR/kangram-data" ]; then
        exec "${HERE}/usr/bin/kangram" -workdir "$APPIMAGE_DIR/kangram-data" "$@"
    fi
fi

exec "${HERE}/usr/bin/kangram" "$@"
EOF
chmod 755 "${APP_DIR}/AppRun"

# Ensure appimagetool and runtime exist
mkdir -p /tmp/appimage_tools
HOST_ARCH=$(uname -m)
if [ ! -f /tmp/appimage_tools/appimagetool ]; then
    echo "Downloading appimagetool for host ${HOST_ARCH}..."
    case "$HOST_ARCH" in
        aarch64|arm64) TOOL_ARCH="aarch64" ;;
        x86_64)        TOOL_ARCH="x86_64" ;;
        *)             TOOL_ARCH="$HOST_ARCH" ;;
    esac
    curl -sL "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-${TOOL_ARCH}.AppImage" -o /tmp/appimage_tools/appimagetool
    chmod +x /tmp/appimage_tools/appimagetool
fi

RUNTIME_FILE="/tmp/appimage_tools/runtime-${RUNTIME_ARCH}"
if [ ! -f "$RUNTIME_FILE" ]; then
    echo "Downloading runtime-${RUNTIME_ARCH}..."
    curl -sL "https://github.com/AppImage/AppImageKit/releases/download/continuous/runtime-${RUNTIME_ARCH}" -o "$RUNTIME_FILE"
    chmod +x "$RUNTIME_FILE"
fi

mkdir -p "${OUTPUT_DIR}"
OUTPUT_FILE="$(cd "${OUTPUT_DIR}" && pwd)/Kangram-${VERSION}-${APPIMAGE_ARCH}.AppImage"

echo "==> Building AppImage: ${OUTPUT_FILE}..."
ARCH="${APPIMAGE_ARCH}" /tmp/appimage_tools/appimagetool \
    --runtime-file "$RUNTIME_FILE" \
    "${APP_DIR}" \
    "${OUTPUT_FILE}"

chmod +x "${OUTPUT_FILE}"
echo "==> Successfully generated: ${OUTPUT_FILE}"

rm -rf "${APP_DIR}"
[ -n "${TMP_EXTRACT}" ] && rm -rf "${TMP_EXTRACT}"
