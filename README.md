# GitHub Reusable Workflows

This repo contains reusable GitHub Actions workflows.

## Workflow: Cloudflare Pages – attach custom domain + redirect pages.dev

**File:** `.github/workflows/cloudflare-pages-subdomain-setup.yml`

### What it does

Given an existing Cloudflare Pages project (already connected to a Git repo manually), this workflow:

1) Creates/updates a **proxied CNAME** in your zone:
- `CUSTOM_DOMAIN` → `PAGES_DEV_HOSTNAME`

2) Adds `CUSTOM_DOMAIN` to the **Pages project** (so Cloudflare issues TLS + serves it)

3) Creates a **Bulk Redirect list** + item:
- `https://PAGES_DEV_HOSTNAME/*` → `https://CUSTOM_DOMAIN/*` (301 by default)
- Preserves path + query string
- Subpath matching enabled

4) Ensures a **Bulk Redirect rule** exists in the account entrypoint ruleset (`http_request_redirect`)
so the list is actually applied.

### Why this helps

Cloudflare Pages always has a `*.pages.dev` hostname. You cannot truly remove it, but you can make it effectively unusable by forcing it to redirect to your canonical domain using Bulk Redirects.

### Requirements (you do manually)

1) Your domain is already in Cloudflare (zone exists) and DNS is managed by Cloudflare.
2) The Cloudflare Pages project already exists and is already deployed from your Git repo.
3) You created an API token with permissions that cover:
   - Pages Write (to attach domain)
   - Account Filter Lists Edit (to create Bulk Redirect list + items)
   - Account Rulesets Write or Mass URL Redirects Write (to create/update redirect ruleset)
   - Zone DNS Edit (to create/update CNAME)

### Required secrets (in the calling repo)

- `CLOUDFLARE_API_TOKEN`
- `CLOUDFLARE_ACCOUNT_ID`
- `CLOUDFLARE_ZONE_ID`

### Required repository variables (in the calling repo)

- `PAGES_PROJECT_NAME`
- `PAGES_DEV_HOSTNAME` (example: `masage-website.pages.dev`)
- `CUSTOM_DOMAIN` (example: `centrodebienestar.negociosprivadoscr.com`)

Optional repository variables:
- `BULK_REDIRECT_LIST_NAME` (must be identifier-safe; otherwise it’s auto-generated)
- `BULK_REDIRECT_RULE_REF`
- `BULK_REDIRECT_RULESET_NAME`
- `REDIRECT_STATUS_CODE` (301, 302, 307, 308; default 301)

### Example: calling this workflow from another repo

Create a workflow in your site repo, e.g. `.github/workflows/cf-setup.yml`:

~~~yaml
name: "Cloudflare setup"
on:
  workflow_dispatch:

jobs:
  setup:
    uses: mrudinal/github-reusable-workflows/.github/workflows/cloudflare-pages-subdomain-setup.yml@main
    secrets:
      CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
      CLOUDFLARE_ACCOUNT_ID: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
      CLOUDFLARE_ZONE_ID: ${{ secrets.CLOUDFLARE_ZONE_ID }}
~~~

---

## Workflow: Cloudflare Zero Trust Access (One-time PIN gate)

**File:** `.github/workflows/cloudflare-zerotrust-access-otp.yml`

This reusable workflow configures Cloudflare Zero Trust **Access** so your website is protected by an **OTP-to-email (One-time PIN)** login screen.

Docs: `docs/cloudflare-zerotrust-access-otp.md`

### What it does

- Verifies your Cloudflare API token
- Ensures **One-time PIN** identity provider exists
- Creates or updates a **Self-hosted Access application** for your hostname/path
- Creates an **Allow** policy for a list of emails
- Converts that policy to **Reusable** (so it appears under “Reusable policies” in the UI)
- Runs checks after every step and stops on failure

### Requirements (Cloudflare)

1) Cloudflare Zero Trust enabled: you must already have a Zero Trust organization created in your Cloudflare account.
2) API Token: create a Cloudflare API Token with (at minimum):
   - `Access: Apps and Policies Write` (and Read is recommended)
   - `Access: Organizations, Identity Providers, and Groups Write` (needed to create One-time PIN IdP)
3) Your hostname is already working in Cloudflare DNS: Access can only protect hostnames that are served through Cloudflare (your DNS record should be in Cloudflare and proxied where applicable).

### Required secrets (in the calling repo)

- `CF_API_TOKEN`
- `CF_ACCOUNT_ID`

### Required repository variables (in the calling repo)

- `CF_ACCESS_APP_NAME` (e.g. `Centro de Bienestar`)
- `CF_ACCESS_DOMAIN` (e.g. `negociosprivadoscr.com`)
- `CF_ACCESS_SUBDOMAIN` (e.g. `centrodebienestar` or `@` for apex/root)
- `CF_ACCESS_SESSION_DURATION` (e.g. `24h`)

- `CF_ACCESS_POLICY_NAME` (e.g. `Allowed_emails`)
- `CF_ALLOWED_EMAILS` (comma-separated, e.g. `rudin.max87@gmail.com,other@domain.com`)

Optional repository variables:
- `CF_ACCESS_PATH` (optional, e.g. `/centrodebienestar` — leave empty to protect whole hostname)

### How to call it from another repo

~~~yaml
name: Configure Zero Trust Gate

on:
  workflow_dispatch:

jobs:
  gate:
    uses: mrudinal/github-reusable-workflows/.github/workflows/cloudflare-zerotrust-access-otp.yml@main
    secrets:
      CF_API_TOKEN: ${{ secrets.CF_API_TOKEN }}
      CF_ACCOUNT_ID: ${{ secrets.CF_ACCOUNT_ID }}
~~~
