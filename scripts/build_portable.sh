#!/usr/bin/env bash
set -e

VERSION="${1:-1.0.1}"
ARCH="${2:-amd64}"
BINARY_PATH="${3:-out/Release/Kangram}"
OUTPUT_DIR="${4:-.}"

# Normalize architecture naming
case "$ARCH" in
    x86_64|amd64)   ARCH_NAME="x86_64" ;;
    aarch64|arm64)  ARCH_NAME="arm64" ;;
    *)              ARCH_NAME="$ARCH" ;;
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
    DEB_CAND=$(ls -1 kangram-desktop_*_${ARCH}.deb 2>/dev/null | head -n 1 || true)
    if [ -z "$DEB_CAND" ]; then
        if [ "$ARCH_NAME" = "x86_64" ]; then
            DEB_CAND=$(ls -1 kangram-desktop_*_amd64.deb 2>/dev/null | head -n 1 || true)
        elif [ "$ARCH_NAME" = "arm64" ]; then
            DEB_CAND=$(ls -1 kangram-desktop_*_arm64.deb 2>/dev/null | head -n 1 || true)
        fi
    fi
    if [ -n "$DEB_CAND" ] && [ -f "$DEB_CAND" ]; then
        echo "Extracting binary from ${DEB_CAND}..."
        TMP_EXTRACT="/tmp/kangram_deb_${ARCH}_$$"
        mkdir -p "${TMP_EXTRACT}"
        dpkg -x "${DEB_CAND}" "${TMP_EXTRACT}"
        BINARY_PATH="${TMP_EXTRACT}/usr/bin/kangram"
    fi
fi

if [ ! -f "$BINARY_PATH" ]; then
    echo "Error: Binary not found at $BINARY_PATH"
    echo "Usage: ./scripts/build_portable.sh [VERSION] [ARCH] [BINARY_PATH] [OUTPUT_DIR]"
    exit 1
fi

PACKAGE_NAME="Kangram-Portable-${VERSION}-${ARCH_NAME}"
TEMP_DIR="/tmp/${PACKAGE_NAME}_$$"
PORTABLE_DIR="${TEMP_DIR}/Kangram"

echo "==> Creating portable package: ${PACKAGE_NAME}..."

rm -rf "${TEMP_DIR}"
mkdir -p "${PORTABLE_DIR}"
mkdir -p "${PORTABLE_DIR}/TelegramForcePortable"

# Copy application binary
cp "$BINARY_PATH" "${PORTABLE_DIR}/kangram"
chmod 755 "${PORTABLE_DIR}/kangram"

# Copy branding and desktop entries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

if [ -f "${REPO_ROOT}/debian/kangram.desktop" ]; then
    cp "${REPO_ROOT}/debian/kangram.desktop" "${PORTABLE_DIR}/"
    chmod 644 "${PORTABLE_DIR}/kangram.desktop"
fi

if [ -f "${REPO_ROOT}/debian/kangram.png" ]; then
    cp "${REPO_ROOT}/debian/kangram.png" "${PORTABLE_DIR}/"
    chmod 644 "${PORTABLE_DIR}/kangram.png"
fi

# Create launcher script
cat << 'EOF' > "${PORTABLE_DIR}/Kangram.sh"
#!/usr/bin/env bash
set -e
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "${HERE}/TelegramForcePortable"
exec "${HERE}/kangram" -workdir "${HERE}/TelegramForcePortable" "$@"
EOF
chmod 755 "${PORTABLE_DIR}/Kangram.sh"

# Create README with usage instructions
cat << EOF > "${PORTABLE_DIR}/README.txt"
========================================================================
                     Kangram Desktop - Portable Edition
========================================================================

Version: ${VERSION} (${ARCH_NAME})

HOW TO RUN:
-----------
Run either of the following commands:
    ./Kangram.sh
or
    ./kangram

PORTABLE STORAGE:
-----------------
All user profiles, chats, anti-recall database (SQLite), settings, and
cached data are stored strictly inside the "TelegramForcePortable" folder.
No data is written to ~/.local/share or ~/.config.

To move your entire Kangram installation, copy the "Kangram" folder
to a USB flash drive or another directory.

DURESS / PANIC WIPE:
--------------------
If the duress passcode or fail-safe wipe is triggered, all data inside
the "TelegramForcePortable" folder is completely and recursively wiped,
and the process immediately terminates.
========================================================================
EOF

mkdir -p "${OUTPUT_DIR}"
FINAL_ARCHIVE="$(cd "${OUTPUT_DIR}" && pwd)/${PACKAGE_NAME}.tar.xz"

echo "==> Compressing to ${FINAL_ARCHIVE}..."
tar -cf - -C "${TEMP_DIR}" Kangram | xz -T0 -3 > "${FINAL_ARCHIVE}"

echo "==> Successfully created: ${FINAL_ARCHIVE}"
rm -rf "${TEMP_DIR}"
[ -n "${TMP_EXTRACT}" ] && rm -rf "${TMP_EXTRACT}"
