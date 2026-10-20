#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN_DIR="$ROOT_DIR/DateHierarchyExport.lrplugin"
DIST_DIR="$ROOT_DIR/dist"

version="$(
	sed -nE \
		's/.*VERSION = \{ major = ([0-9]+), minor = ([0-9]+), revision = ([0-9]+).*/\1.\2.\3/p' \
		"$PLUGIN_DIR/Info.lua"
)"

if [[ -z "$version" ]]; then
	echo "Could not read VERSION from $PLUGIN_DIR/Info.lua" >&2
	exit 1
fi

if [[ "${GITHUB_REF_TYPE:-}" == "tag" ]]; then
	tag_version="${GITHUB_REF_NAME#v}"
	if [[ "$tag_version" != "$version" ]]; then
		echo "Tag $GITHUB_REF_NAME does not match Info.lua version $version" >&2
		exit 1
	fi
fi

archive="$DIST_DIR/DateHierarchyExport-$version.zip"

mkdir -p "$DIST_DIR"
rm -f "$DIST_DIR"/DateHierarchyExport-*.zip

cd "$ROOT_DIR"
zip -r -X "$archive" \
	"DateHierarchyExport.lrplugin" \
	"README.md" \
	"README.zh-CN.md" \
	-x "*.DS_Store" >/dev/null

echo "Built: $archive"
if command -v shasum >/dev/null 2>&1; then
	shasum -a 256 "$archive"
else
	sha256sum "$archive"
fi
