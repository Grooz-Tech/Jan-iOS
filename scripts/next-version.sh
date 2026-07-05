#!/bin/sh
# Determine the release version and the next develop version.
#
# Usage: scripts/next-version.sh [VERSION]
#   VERSION  optional override (X.Y.Z). If omitted, reads MARKETING_VERSION
#            from Version.xcconfig.
#
# Prints two lines:
#   version=<X.Y.Z>      the version to release
#   next=<X.(Y+1).0>     the next minor for develop
#
# When GITHUB_OUTPUT is set (in CI), also appends them there.
set -eu

version="${1:-}"

if [ -z "$version" ]; then
	version="$(dirname "$0")/read-version.sh"
	version="$("$version")"
elif ! echo "$version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
	echo "Invalid version '$version' (expected X.Y.Z)" >&2
	exit 1
fi

major="${version%%.*}"
minor="$(echo "$version" | cut -d. -f2)"
next="${major}.$((minor + 1)).0"

echo "version=$version"
echo "next=$next"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
	{
		echo "version=$version"
		echo "next=$next"
	} >> "$GITHUB_OUTPUT"
fi
