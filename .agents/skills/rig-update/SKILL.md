---
name: rig-update
description: Update the Rig kit installed in this repository to the latest upstream version and merge its staged changes. Use when the user asks to update, upgrade, or check Rig.
---

# Update Rig

Work inside the repository to update, starting from a clean working tree. An update is a semantic merge: the installer stages conflicting files, and you reconcile them with the project's own rules.

1. Run `.rig/check-update` when it exists.
   - Exit 0 with no `.rig/merge/`: report the kit as current and finish. Reinstall only on the user's explicit request.
   - Exit 0 with `.rig/merge/` candidates: go to step 4 and resolve them.
   - Exit 1: an update is available, so continue.
   - Exit 2 or a missing checker: the installation is older or its revision is unknown, so continue.
2. Read the latest Rig README (https://github.com/DragonL57/rig) and this repository's current `AGENTS.md`, agent definitions, and `.rig/models.json`.
3. Re-run the latest installer, selecting the editors this repository already uses:

   ```bash
   curl -fsSL https://raw.githubusercontent.com/DragonL57/rig/main/install.sh | bash -s -- .
   ```

   Without a terminal the installer preselects the editors installed on this machine; pass `--no-input` when the repository uses pi only.
4. Merge every candidate in `.rig/merge/` into the corresponding existing file. Keep the project's product, security, build, and team rules, and take Rig's updated generic workflow where the two do not conflict.
5. Delete `.rig/merge/` after resolving it.
6. Inspect the complete diff yourself. Verify that all seven helpers are available in each selected editor, the six specialists keep explicit model pins, `fallback-runner` has no model pin, no agent pins `max_turns`, and the repository's normal checks pass.
7. Keep this update separate from feature work. Launch `implementer` or any reviewer only on the user's explicit request. Bring an update conflict that affects product behavior, security, or team workflow to the user for approval.
8. Report what was added, updated, preserved, or left unresolved. Commit or push only on the user's request.
