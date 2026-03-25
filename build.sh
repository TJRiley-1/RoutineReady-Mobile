#!/bin/bash
set -e

# ─────────────────────────────────────────────────────────────
# build.sh — Vercel server-side build (git-triggered deploys)
#
# This script runs on Vercel's build servers when code is pushed.
# It installs Flutter, builds the web app, then combines it with
# the static landing page into the correct output structure.
#
# Output: build/web/
#   /index.html       ← Landing page (from public/)
#   /landing.css       ← Landing page styles
#   /app/index.html   ← Flutter app
#   /app/main.dart.js ← Flutter compiled JS
#   /app/...          ← Flutter assets
# ─────────────────────────────────────────────────────────────

# Install Flutter SDK
FLUTTER_VERSION="3.32.2"
FLUTTER_DIR="$HOME/flutter"

if [ ! -d "$FLUTTER_DIR" ]; then
  echo "Installing Flutter SDK..."
  git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$FLUTTER_DIR"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

# Pre-cache web SDK and suppress analytics
flutter config --no-analytics
flutter precache --web

echo "Flutter version:"
flutter --version

# Build Flutter web app at /app/ base path
flutter build web --release --base-href "/app/"

# Move Flutter output into /app/ subdirectory
mkdir -p build/web-final/app
mv build/web/* build/web-final/app/ 2>/dev/null || true

# Copy landing page to root
cp public/* build/web-final/ 2>/dev/null || true

# Replace build/web with the combined output
rm -rf build/web
mv build/web-final build/web
