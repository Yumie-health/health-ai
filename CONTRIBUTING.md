# Contributing to Yumie Health AI

Thank you for contributing. This document defines the conventions every contributor must follow so we keep history clean, reviews predictable, and CI reliable.

## Branch naming

Create branches from the default branch using one of these prefixes plus a short kebab-case slug:

| Prefix      | Use for                                      |
|-------------|----------------------------------------------|
| `feat/`     | New user-facing features                     |
| `fix/`      | Bug fixes                                    |
| `chore/`    | Tooling, governance, non-product maintenance |
| `ci/`       | CI/CD pipeline changes                       |
| `refactor/` | Code restructuring without behavior change   |
| `docs/`     | Documentation-only changes                   |

**Examples:** `feat/workout-programming`, `fix/app-check-token`, `chore/project-governance`

## Commit messages

We use [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<optional scope>): <short description>

[optional body]

[optional footer(s)]
```

Common types: `feat`, `fix`, `chore`, `ci`, `refactor`, `docs`, `test`, `perf`, `build`.

**Examples:**

- `feat(ai): add Remote Config model selection`
- `fix(android): bump targetSdk to 35`
- `chore: add CONTRIBUTING and PR template`

## Pull requests

- **One issue per PR.** Each PR should address a single tracked issue (or a tightly scoped sub-task of an epic). Do not bundle unrelated changes.
- **Link the issue** in the PR description using `Closes #<number>` (or `Fixes #<number>`).
- **Squash merge only.** PRs are squash-merged into the target branch to keep a linear, readable history.
- **CI gate is mandatory.** Every PR must pass all required status checks before it can merge. Do not merge with failing or skipped checks.

### PR checklist (summary)

1. Branch name follows the convention above.
2. Commits follow Conventional Commits.
3. Linked issue is referenced with `Closes #`.
4. Test plan is filled out in the PR template.
5. All CI checks are green.

## Code review

- Request review from code owners (see `.github/CODEOWNERS`).
- Address review feedback with new commits on the same branch; they will be squashed on merge.
- Prefer small, reviewable PRs over large dumps of changes.

## Local development

See the project README for Flutter/Firebase setup. Before opening a PR, run:

```bash
flutter analyze
dart format --set-exit-if-changed .
flutter test
```

CI enforces the same checks on every pull request.
