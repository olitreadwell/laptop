# Global Claude Code Configuration

## Branch naming

Default pattern (when no clearer upstream/repo convention is evident):
`<type>/<app-or-domain>/<snake_case_description>/<issue_or_ticket_id>`

- `<type>`: a Conventional Commits type (`feat`, `fix`, `chore`, `refactor`,
  `docs`, `test`, `perf`, `build`, `ci`, `style`).
- Slashes separate segments (app/domain, then type, then description) —
  mirrors real-world patterns like `website/test/scaffold-vitest-...`.
- The descriptive phrase itself uses snake_case, not kebab-case.
- The issue or ticket ID (e.g. a GitHub issue number, Jira key) goes LAST,
  as its own segment, when one exists. Omit this segment if there's
  genuinely no issue/ticket to reference — don't invent one.

**Before defaulting to this pattern on a fork/contribution PR**: check
whether the target repo (or its org) has an evident branch-naming
convention of its own (grep recent merged PRs' `headRefName`s via
`gh pr list --state merged --json headRefName`). If a clear, consistent
pattern exists upstream, match THAT instead — the goal is a PR that reads
as native to that repo's maintainers, not enforcing a personal habit onto
someone else's project. Fall back to the default pattern above only when
no clear upstream convention is evident.

## Code discoverability for agents

Coding agents (including future Claude sessions) navigate repos mainly by
grep/text search, not semantic analysis. Generic names and vague comments
cost real accuracy — misleading identifiers measurably increase wrong
answers, and a name like `create()` returns hundreds of unrelated hits
where `createStripeClient()` returns the one you want. This applies
whenever writing or renaming code in any repo, not just this one.

- Use 2-3 word, domain-prefixed names for exports (`getUserProfileById`,
  not `get` or `getProfile`). One-word exports are ambiguous under grep;
  three words (one a domain word) is roughly where a name stops being
  ambiguous and starts working as an address.
- Pick one spelling per concept and use it everywhere (`orgId`, not
  `organizations` in one place and `customers` in another) — agents
  navigate synonyms worse than humans do, they don't build up immunity
  to a codebase's inconsistencies the way a long-tenured human does.
- Avoid `any`/untyped escape hatches. A precise type signature lets an
  agent (or a human) reason from the signature instead of reading the
  implementation.
- Put explanatory comments directly above the definition they explain —
  that's where a grep for the symbol lands.
- Organize by concept, not by file size. Split large files into
  concept-named modules; the filename itself becomes a useful search hit.
- Name test files after their source file (`stripe.test.ts` tests
  `stripe.ts`) so the pairing is discoverable without opening either.
- Mark deprecated code explicitly (`@deprecated` + why) so it doesn't get
  reused as a pattern by a future agent pass.
- If a repo's naming/layout conventions aren't obvious from the code
  itself, check for an `AGENTS.md` (or equivalent) before writing new
  code, and update it when a new convention gets established — don't
  leave it undocumented for the next session to rediscover.
- For TS/JS repos specifically, `npx fallow health` (docs.fallow.tools)
  surfaces dead code, duplication, and architecture drift fast, and is
  agent-callable. Unvetted third-party tool as of 2026-08-13 — fine to
  run ad hoc, run it past the `judge-repo` skill first before adopting it
  in CI or as a standing dependency.

Source: [modem.dev, "How Coding Agents Read Your Code"](https://modem.dev/blog/how-coding-agents-read-your-code).

## Turning repeated opinions into constraints

A vague preference ("make it polished," "be more concise") doesn't
constrain an agent's output — it can be satisfied in incompatible ways.
When Oli repeats the same correction across unrelated tasks, or asks to
turn something into a rule, use the `constraint-capture` skill
(`~/.claude/skills/constraint-capture/`) to rewrite it as a
trigger/rules/checks/pattern, and to decide whether it belongs here, in a
project's own `CLAUDE.md`, or in a dedicated skill file. Don't hunt for
opinions to formalize unprompted — wait for a repeat or an explicit ask.

## App quality baseline (apply to every new app)

When you create a new app or repo, include these pieces by default. They are
the difference between a demo and software that behaves like production.
Skip one only when the user explicitly says so, and say why in your summary.

### The 12-factor core

1. **One codebase, tracked in git** - init git and commit early.
2. **Pinned dependencies** - exact versions, lockfile committed, no floating
   ranges.
3. **Config via environment variables** - no hardcoded secrets or settings;
   read `PORT`, DSNs, and feature flags from the environment.
4. **Stateless processes** - no in-process state that must survive a
   restart; put state in a backing service (database, cache, queue).
5. **Logs as event streams** - structured logs to stdout, one line per
   event, timestamped and level-tagged.
6. **Port binding** - the app is self-contained and serves HTTP on a port.
7. **Disposability** - fast startup, graceful shutdown, and a clean crash
   path (log + report + non-zero exit).

### The modern quality layer

8. **Health check** - `GET /health` answers 200; load balancers and
   orchestrators poll it.
9. **API documentation** - an OpenAPI spec, Swagger UI at `/docs`, and a
   contract test that keeps the spec and the running server in agreement.
10. **Observability** - structured logging, error tracking (e.g. Sentry)
    gated by an env var so it is off by default, and metrics for services.
11. **Centralized error handling** - log, report, and answer a clean JSON
    error; never crash on bad input.
12. **Input validation at the boundary** - reject bad input with 4xx before
    it reaches business logic.
13. **Testing** - unit + integration + smoke at minimum, E2E for UIs, and a
    coverage gate (100% for learning repos).
14. **CI/CD** - a pipeline that runs the same checks on every push.
15. **Security** - a dependency audit command, no secrets in code, and a
    security checklist in the docs.
16. **Containerization** - a Dockerfile where the stack is containerizable.
17. **Code quality** - lint, format, and typecheck/static analysis wired
    into one `check` command.
18. **Documentation** - README (quickstart + commands), architecture, setup,
    and a glossary; add a learning path for teaching repos.
19. **AI-friendliness** - an `AGENTS.md`, 2-3 word domain-prefixed names,
    doc comments on every export, and docs that point at real code.

### How to apply

- Wire everything into one `check` command (or Makefile target): lint +
  format + typecheck + tests + build + smoke.
- Keep 100% coverage for learning repos; set a realistic coverage gate for
  real apps.
- Update docs and diagrams in the same change as the behavior they describe.
- For teaching repos, follow the shape of the repos in
  `/Users/olitreadwell/code/learning` (see its `SPEC-TEMPLATE.md`).
