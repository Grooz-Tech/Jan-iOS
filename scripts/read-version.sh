#!/bin/sh
# Read the current MARKETING_VERSION from Version.xcconfig and validate it.
# Prints the version (X.Y.Z) to stdout.
set -eu

xcconfig="Version.xcconfig"
version="$(sed -n 's/^MARKETING_VERSION = //p' "$xcconfig" | tr -d '[:space:]')"

if ! echo "$version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
	echo "Invalid version '$version' in $xcconfig (expected X.Y.Z)" >&2
	exit 1
fi

echo "$version"
