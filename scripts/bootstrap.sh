#!/bin/sh
# One-time template bootstrap: fill in project values, rename the app
# directory/targets, create the certs repo, generate the project, then remove
# this script (TEMPLATE.md is kept as the setup guide).
#
# Run once, from the repo root, right after creating a repo from the template.
set -eu

if [ ! -f Project.swift ] || ! grep -q "__APP_NAME__" Project.swift; then
	echo "Run from the repo root of a fresh template checkout (Project.swift with __APP_NAME__ not found)." >&2
	exit 1
fi

prompt() { # prompt VAR "Question" [validate-regex]
	_var="$1"; _q="$2"; _re="${3:-}"
	while :; do
		printf "%s: " "$_q"
		read -r _val
		[ -n "$_val" ] || { echo "  required."; continue; }
		if [ -n "$_re" ] && ! printf '%s' "$_val" | grep -Eq "$_re"; then
			echo "  invalid format."; continue
		fi
		eval "$_var=\$_val"
		break
	done
}

echo "== Configure your app =="
prompt APP_NAME     "App name (letters/numbers, no spaces)"        '^[A-Za-z][A-Za-z0-9]*$'
prompt BUNDLE_ID    "Bundle identifier (e.g. com.acme.app)"        '^[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+$'
prompt TEAM_ID      "Apple Developer Team ID (10 chars)"           '^[A-Z0-9]{10}$'
prompt APPLE_ID     "Apple ID email"                               '^[^@]+@[^@]+$'
prompt ASC_KEY_ID   "App Store Connect API Key ID"                 '^[A-Z0-9]+$'
prompt ASC_ISSUER   "App Store Connect Issuer ID (UUID)"           '^[0-9a-fA-F-]{36}$'
prompt ORG          "GitHub org / owner"                           '^[A-Za-z0-9._-]+$'

# Certs repo follows the convention <ORG>/<AppName>-iOS-Certificates.
CERTS_URL="https://github.com/$ORG/$APP_NAME-iOS-Certificates.git"

echo
echo "match certificates repo: $CERTS_URL"
echo
echo "== Applying =="

# Replace tokens in all text files (skip .git, generated, binaries).
# The while runs in a subshell (piped); mark failures via a file so they
# surface after the loop instead of being silently swallowed.
fail_marker="$(mktemp)"
find . -type f \
	-not -path './.git/*' \
	-not -path './Tuist/.build/*' \
	-not -path './Derived/*' \
	-not -name '*.png' -not -name '*.p12' -not -name '*.cer' \
	-print0 | while IFS= read -r -d '' f; do
	tmp="$(mktemp)"
	if sed \
		-e "s|__APP_NAME__|$APP_NAME|g" \
		-e "s|__BUNDLE_ID__|$BUNDLE_ID|g" \
		-e "s|__TEAM_ID__|$TEAM_ID|g" \
		-e "s|__APPLE_ID__|$APPLE_ID|g" \
		-e "s|__ASC_KEY_ID__|$ASC_KEY_ID|g" \
		-e "s|__ASC_ISSUER_ID__|$ASC_ISSUER|g" \
		-e "s|__CERTS_REPO_URL__|$CERTS_URL|g" \
		-e "s|__ORG__|$ORG|g" \
		"$f" > "$tmp"; then
		mv "$tmp" "$f" || echo "$f" >> "$fail_marker"
	else
		rm -f "$tmp"; echo "$f" >> "$fail_marker"
	fi
done
if [ -s "$fail_marker" ]; then
	echo "Token replacement failed for:" >&2
	cat "$fail_marker" >&2
	rm -f "$fail_marker"
	exit 1
fi
rm -f "$fail_marker"

# Rename token-named files and the app directory.
mv "__APP_NAME__/Sources/__APP_NAME__App.swift" "__APP_NAME__/Sources/${APP_NAME}App.swift"
mv "__APP_NAME__/Tests/__APP_NAME__Tests.swift" "__APP_NAME__/Tests/${APP_NAME}Tests.swift"
mv "__APP_NAME__" "$APP_NAME"

echo "Placeholders replaced; app directory renamed to $APP_NAME/."

# Create the private match certificates repo (best-effort; skip on any problem).
certs_repo="$ORG/$APP_NAME-iOS-Certificates"
if command -v gh >/dev/null && gh auth status >/dev/null 2>&1; then
	if gh repo view "$certs_repo" >/dev/null 2>&1; then
		echo "Certs repo $certs_repo already exists — skipping creation."
	elif gh repo create "$certs_repo" --private >/dev/null 2>&1; then
		echo "Created private certs repo: $certs_repo"
	else
		echo "Could not create $certs_repo — create it manually (see TEMPLATE.md)."
	fi
else
	echo "gh not available/authenticated — create the certs repo $certs_repo manually (see TEMPLATE.md)."
fi

# Generate the Xcode project as a sanity check.
if command -v tuist >/dev/null; then
	tuist install
	tuist generate --no-open
fi

# Remove the bootstrap script itself (TEMPLATE.md is kept as the setup guide).
rm -f "$0"

echo
echo "Done. Next: complete the GitHub / App Store Connect setup (see TEMPLATE.md),"
echo "then create fastlane/.env with MATCH_PASSWORD and the ASC key."
