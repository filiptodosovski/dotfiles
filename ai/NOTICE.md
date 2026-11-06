# Upstream material

The skill folders under `skills/` are snapshots of installed upstream skills,
including local changes. Their upstream licenses and attribution remain alongside
the files. `skills/sources.json` records the original installation sources and
commits, including skills that were later removed (four generic JS/TS
references on 2026-10-30 and the six `antislop` skills on 2026-11-05). Fetch one
from its recorded repository and commit if you want it back. Impeccable was
updated after the original installation: this snapshot is 4.6.0, not necessarily
the commit in the historical record. Git history is the integrity record for these files.

The React and composition skills are from
[vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills); their
entry files declare MIT and retain Vercel's authorship metadata. The recorded
upstream revision supplies no separate LICENSE file. The remaining MIT skills
retain their `LICENSE.upstream` files from `mattpocock/skills`.

Impeccable is from [pbakaus/impeccable](https://github.com/pbakaus/impeccable),
licensed under Apache-2.0; `LICENSE.apache-2.0` contains that license. Its
platform engine binaries are omitted; the unchanged launcher downloads the
version named in `scripts/VERSION` on first use.

Herdr agent integrations are not vendored. `scripts/ai-setup.py --apply` runs
`herdr integration install` so Herdr writes the version that matches the
installed binary.

The three Pi extension packages are pinned in `pi/settings.json`; Pi installs
them itself. Their source and `node_modules` are not vendored. Installing them
does not grant access to a paid model provider.
