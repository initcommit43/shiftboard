# 0019: Public repository, all rights reserved

Status: accepted (2026-10-11)

## Context

The project is a portfolio piece, so the code should be visible. It may also be pitched to an agency one day, so nobody else should be free to use it. A private repository hides the work and, on a free GitHub plan, cannot have branch protection.

## Decision

- The repository is public.
- It is not open source. The `LICENSE` file reserves all rights: the code may be viewed, but not used, copied, modified or distributed without written permission.
- The copyright notice names the repository owner's GitHub handle and the contributors.
- Third-party components keep their own licenses, stored next to the files.

## Consequences

- Anyone can read the code, the issues and the pull requests; nothing that should stay private may be committed or written there.
- GitHub's terms let every user view and fork a public repository on GitHub. A fork grants no right to use the code.
- Contributors keep the copyright in what they write. Rights between the owner and contributors are agreed in writing before someone joins; the license file does not replace that.
- Branch protection and code owner reviews are available on the free plan.
- Outside contributions are not invited.
