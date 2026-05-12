#!/usr/bin/env bash
# Bundle the current artifact project into a single self-contained bundle.html.
# Run from the project root (the directory containing index.html).
set -euo pipefail

if [ ! -f "index.html" ]; then
  echo "Error: index.html not found in current directory. Run from project root." >&2
  exit 1
fi

echo "Installing bundling dependencies..."
npm install --silent --no-save \
  parcel@^2.12.0 \
  @parcel/config-default@^2.12.0 \
  parcel-resolver-tspaths@^0.0.9 \
  html-inline@^1.2.0

# Ensure .parcelrc exists with tspaths resolver for @/ alias support.
if [ ! -f ".parcelrc" ]; then
  cat > .parcelrc <<'EOF'
{
  "extends": "@parcel/config-default",
  "resolvers": ["parcel-resolver-tspaths", "..."]
}
EOF
fi

echo "Building with Parcel..."
rm -rf dist .parcel-cache
npx parcel build index.html \
  --dist-dir dist \
  --no-source-maps \
  --public-url ./

echo "Inlining assets into single HTML..."
npx html-inline -i dist/index.html > bundle.html

SIZE=$(wc -c < bundle.html | tr -d ' ')
echo ""
echo "Created bundle.html ($SIZE bytes)"
