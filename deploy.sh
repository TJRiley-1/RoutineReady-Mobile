#!/bin/bash
set -e

# ─────────────────────────────────────────────────────────────
# deploy.sh — Build and deploy to Vercel
#
# Architecture:
#   /         → Static HTML landing page (public/)
#                Sanity.io visual editing works here (real DOM)
#   /app      → Flutter web app (build/web/)
#                Classroom display + admin tool
#
# Usage:
#   ./deploy.sh              # Build + deploy to production
#   ./deploy.sh preview      # Build + deploy preview
#   ./deploy.sh --skip-build # Deploy existing build only
#
# Uses --prebuilt to bypass Vercel's server-side build.
# vercel.json buildCommand is only for git-triggered builds.
# ─────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build/web"
OUTPUT_DIR="$SCRIPT_DIR/.vercel-output"
VERCEL_PROJECT_ID="prj_uAioRkBl0YuBeALuGUZxhfWKkqQn"
VERCEL_ORG_ID="team_6raNlT6BAxVble9TbFtjuMB7"
VERCEL_PROJECT_NAME="routine-ready-co-uk-web"

TARGET="--prod"
SKIP_BUILD=false

for arg in "$@"; do
  case "$arg" in
    preview) TARGET="" ;;
    --skip-build) SKIP_BUILD=true ;;
  esac
done

# ── Build Flutter ──
if [ "$SKIP_BUILD" = false ]; then
  echo "==> Building Flutter web..."
  cd "$SCRIPT_DIR"
  flutter build web --release --base-href "/app/"
  echo ""
fi

# ── Package Vercel output ──
echo "==> Packaging for Vercel..."
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/.vercel/output/static/app"

# Vercel project link
cat > "$OUTPUT_DIR/.vercel/project.json" <<EOF
{"projectId":"$VERCEL_PROJECT_ID","orgId":"$VERCEL_ORG_ID","projectName":"$VERCEL_PROJECT_NAME"}
EOF

# Routing config
cat > "$OUTPUT_DIR/.vercel/output/config.json" <<'EOF'
{
  "version": 3,
  "routes": [
    { "handle": "filesystem" },
    { "src": "/app/(.*)", "dest": "/app/index.html" },
    { "src": "/(.*)", "dest": "/index.html" }
  ]
}
EOF

# Landing page → root
cp "$SCRIPT_DIR/public/"* "$OUTPUT_DIR/.vercel/output/static/" 2>/dev/null || true

# Flutter app → /app/
rsync -a "$BUILD_DIR/" "$OUTPUT_DIR/.vercel/output/static/app/" --exclude='.vercel'

# ── Deploy ──
echo "==> Deploying to Vercel${TARGET:+ (production)}..."
cd "$OUTPUT_DIR"
vercel deploy --prebuilt $TARGET

# ── Cleanup ──
rm -rf "$OUTPUT_DIR"

echo ""
echo "Done."
