# OpenTofu Provider Install Docs

Documentation for fixing `tofu init` failures when the `hashicorp/aws` provider
cannot be downloaded (GitHub `504 Gateway Timeout`), and for setting up a local
filesystem mirror as a workaround.

## Contents

| File | What it covers |
|------|----------------|
| [01-problem-and-causes.md](01-problem-and-causes.md) | The errors you may see, what causes each one, and how provider downloads work |
| [02-quick-fixes.md](02-quick-fixes.md) | Retry, connectivity tests, DNS, and pinning another provider version |
| [03-filesystem-mirror-setup.md](03-filesystem-mirror-setup.md) | Full step-by-step setup of a local provider mirror with `~/.tofurc` |
| [04-hashicorp-download-and-lockfile.md](04-hashicorp-download-and-lockfile.md) | Downloading from releases.hashicorp.com, verifying it, and lock file behavior |
| [05-troubleshooting-checklist.md](05-troubleshooting-checklist.md) | Symptom → fix table, rollback, and a copy-paste diagnostic script |

## Suggested order

1. Read [01](01-problem-and-causes.md) to match your error.
2. Try [02](02-quick-fixes.md). Many 504s are temporary.
3. If GitHub stays down, follow [03](03-filesystem-mirror-setup.md) and [04](04-hashicorp-download-and-lockfile.md).
4. Use [05](05-troubleshooting-checklist.md) if something still fails.

## Assumptions

- Provider: `hashicorp/aws` version `5.100.0` (adjust to your pinned version)
- Platform: Linux `amd64` (use `arm64` if `uname -m` prints `aarch64`)
- User: `root`, so `$HOME` is `/root` (for a normal user it is `/home/<user>`)
- Project folder: `~/OpenTofu-EC2-Ubuntu-Lab`
