#!/bin/sh
# Set MARKETING_VERSION in Version.xcconfig.
# Usage: scripts/set-version.sh X.Y.Z
#
# Portable across BSD (macOS) and GNU sed: writes to a temp file, then moves.
set -eu

version="${1:?usage: set-version.sh X.Y.Z}"
xcconfig="Version.xcconfig"

if ! echo "$version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
	echo "Invalid version '$version' (expected X.Y.Z)" >&2
	exit 1
fi

tmp="$(mktemp)"
sed "s/^MARKETING_VERSION = .*/MARKETING_VERSION = $version/" "$xcconfig" > "$tmp"
mv "$tmp" "$xcconfig"

echo "Set MARKETING_VERSION = $version"
