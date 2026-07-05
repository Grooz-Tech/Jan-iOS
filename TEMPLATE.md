# iOS App Template — Setup

Tuist + fastlane iOS template: GitFlow, match signing, CI/CD (PR checks,
TestFlight, App Store) preconfigured.

## Step 0 — Bootstrap

From a fresh checkout of this template, run:

```bash
./scripts/bootstrap.sh
```

It prompts for app name, bundle id, team id, Apple ID, ASC key id/issuer, certs
repo URL, and org; replaces the `__PLACEHOLDER__` tokens; renames the app
directory/targets; generates the Xcode project; and removes itself. This file
(TEMPLATE.md) stays as your setup guide.

Then complete the one-time setup below — per-project secrets and GitHub state a
template can't include.

## 1. App Store Connect

- [ ] Create a **Team API key** (Users and Access → Integrations), App Manager

## 1. App Store Connect

- [ ] Create a **Team API key** (Users and Access → Integrations), App Manager
      role. Note the **Key ID** and **Issuer ID** (used at bootstrap), download
      the `.p8` (once).
- [ ] Register the App ID / App Store record: `fastlane register_app`
      (needs `fastlane/.env` — see step 3).

## 2. Certificates repo (match)

Bootstrap uses the convention `https://github.com/<ORG>/<AppName>-iOS-Certificates.git`
and, if `gh` is installed and authenticated, **creates that private repo for you**.

- [ ] If bootstrap couldn't create it (no `gh`), create the **private** repo
      `<ORG>/<AppName>-iOS-Certificates` manually.
- [ ] First run (someone with the ASC key): `fastlane certificates_update`
      to create + store certs/profiles.

## 3. Local secrets — `fastlane/.env` (gitignored)

```bash
cat > fastlane/.env <<EOF
MATCH_PASSWORD=<choose a strong passphrase, save it>
APP_STORE_CONNECT_API_KEY_KEY=$(base64 -i /path/to/AuthKey_XXХ.p8)
EOF
```

## 4. GitHub secrets (repo → Settings → Secrets → Actions)

- [ ] `MATCH_PASSWORD`
- [ ] `ASC_API_KEY_ADMIN_B64` — `base64` of the `.p8`
- [ ] `GIT_AUTH_TOKEN` — PAT (Contents: read) for the certs repo + private SPM
      packages. Needs write + branch-protection bypass for the release-cut and
      tag/back-merge workflows.

## 5. Environments (repo → Settings → Environments)

- [ ] `testflight`
- [ ] `appstore` — add required reviewer + restrict to `main`.

## 6. Branches & protection

- [ ] Create `develop` from `main`.
- [ ] Protect `main` and `develop`: require PR + status checks (`test`, `build`),
      squash-only merges.
- [ ] Enable squash-only merges repo-wide; enable auto-delete merged branches.

## 7. Runner

- [ ] Ensure the self-hosted runner label in the workflows (`runs-on: tartelet`)
      matches your runner, with Tuist + fastlane + an iOS 18 simulator installed.

## 8. Git hooks (each developer)

```bash
git config core.hooksPath .githooks
```
