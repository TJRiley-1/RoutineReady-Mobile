#!/bin/bash
set -e

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

# Build web
flutter build web --release --base-href "/"
