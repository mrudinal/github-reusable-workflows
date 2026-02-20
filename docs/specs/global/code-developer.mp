# Global Spec — Code Developer (Spec-Driven Development)

## Purpose
Define non-negotiable coding standards so the codebase stays clean, readable, secure, and consistent.

## Applies to
All JavaScript/TypeScript code in this repository (frontend, backend, scripts, tests).

This repository also contains GitHub Actions workflows (YAML) used as reusable workflows.

---

## GitHub Actions workflows (YAML) — repo rules (must)

### Workflow interface (must)
* Reusable workflows that are intended to be called from other repositories must get non-secret configuration from **caller repository variables** (`vars.*`) where possible.
  * If caller variables are not feasible for a workflow, declare non-secret parameters under `on.workflow_call.inputs`.
* Sensitive values (tokens/credentials) must be declared under `on.workflow_call.secrets` and passed via `jobs.<job_id>.secrets` from the caller.

### Safety and logging (must)
* Never echo or print sensitive inputs (tokens, credentials) to logs.
* Validate required inputs up-front and hard-fail if any are missing.

---

## Spec-Driven Development loop (how we work)
1) **Read**: Read the relevant feature specs first (if they exist) and this global spec.
2) **Plan**: Write a short plan (what files change, what functions you’ll add, what tests you’ll run).
3) **Implement**: Make the smallest correct change that meets the spec.
4) **Verify**: Run lint + tests + build, and do a quick manual sanity check when applicable.
5) **Document**: Update spec/tasks (if any) and ensure code comments match behavior.

---

## 1) Code quality and readability (must)
### 1.1 Make code “look good” and understandable
- Follow a well-known JS/TS style guide consistently (repo standard is **Airbnb JS** style).
- Prefer clarity over cleverness.
- Prefer small, composable functions.
- Prefer explicit variable/function names over abbreviations.
- Keep modules cohesive: one file = one main responsibility.
- Use `const` by default; use `let` only when reassignment is required; avoid `var`.

### 1.2 Formatting and consistency
- Code must be consistently formatted (Prettier/ESLint rules if present).
- Imports must be ordered consistently.
- Avoid deep nesting: use early returns, guard clauses, and helper functions.

---

## 2) Naming (must)
### 2.1 Functions and methods must describe what they do
- Names must clearly communicate intent (verb + object):
  - ✅ `createAppointmentSlots`, `validateBookingRequest`, `loadAvailableDays`
  - ❌ `doThing`, `handle`, `process`, `run`, `q`, `fn1`

### 2.2 No single-letter identifiers anywhere
- **Do not use single letters** like `i`, `a`, `b`, `e`, etc. (including loops and callbacks).
- Use meaningful names:
  - Loop indexes: `index`, `dayIndex`, `slotIndex`, `hourIndex`
  - Iteration values: `day`, `hour`, `appointment`, `user`, `request`
  - Callback args: `error`, `event`, `response`, `document`

### 2.3 Consistent casing
- Use `camelCase` for variables/functions.
- Use `PascalCase` for classes/components.
- Use `UPPER_SNAKE_CASE` for constants only when truly constant and shared.

---

## 3) Comments and documentation (must)
### 3.1 Every function/method must have a short doc comment
- Place a doc comment **immediately above** each function/method.
- Keep it **one brief sentence** describing what it does.
- Use a JSDoc-style block for function docs.

**Example**
```js
/**
 * Seeds availability documents for the next 6 months starting today.
 */
async function seedAvailabilityWindow() {
  // ...
}
```

### 3.2 Use inline comments to explain “chunks”

* Before each non-trivial block/chunk, add a short comment explaining the purpose.
* Use `//` single-line comments for chunk explanations.
* Do not comment obvious code; comment intent and reasoning.

**Example**

```js
// Build the rolling 6-month date window in Costa Rica time.
const dateWindow = buildDateWindowInCostaRicaTime();
```

---

## 4) Security: dependencies and packages (must)

### 4.1 Avoid vulnerable packages

* Do not add packages with known active vulnerabilities.
* Prefer:

  * Built-in Node/standard APIs
  * Popular, maintained libraries with frequent releases and good security posture
* Before merging any dependency change:

  * Run `npm audit`
  * Address vulnerabilities (update, replace, or remove the dependency)

### 4.2 Required dependency hygiene

* Keep dependencies minimal (each new dependency must be justified).
* Pin and maintain lockfiles (`package-lock.json` / pnpm lock / yarn lock).
* Do not add packages that are deprecated or unmaintained if an alternative exists.

---

## 5) SonarQube-aligned rules (must) — except max function length

We follow common SonarQube “clean code” guidance. **We do NOT enforce a hard max function length**, but we still prefer small, readable functions.

### 5.1 Examples we enforce

* Use **strict equality** (`===` / `!==`) instead of `==` / `!=` (except safe `null` checks).
* Do not import a module into itself.
* Avoid absolute import paths.
* Use `Number.isNaN()` for `NaN` checks.
* Prefer spread syntax over redundant `.apply()`.
* Prefer object spread syntax over `Object.assign()` when appropriate.
* Ensure function/method names comply with naming conventions.

### 5.2 General quality expectations

* No unused variables, unused assignments, or dead code.
* Handle errors intentionally (don’t swallow exceptions).
* Avoid duplicated logic (see DRY rule below).
* Prefer predictable control flow (avoid “spooky action” / hidden side effects).

---

## 6) DRY: avoid repetition (must)

* If logic is needed in **more than one place**, extract it into a function/module.
* Prefer:

  * `utils/` for general-purpose helpers
  * `lib/` for domain-specific shared logic
* Add at least minimal tests for shared utilities.

---

## Definition of Done (for any change)

* [ ] Naming is descriptive; **no single-letter identifiers**
* [ ] Every function/method has a 1-sentence doc comment
* [ ] Chunk-level comments exist where logic is non-trivial
* [ ] No new vulnerable dependencies; `npm audit` clean or addressed
* [ ] SonarQube-style issues avoided (except max function length rule)
* [ ] No duplicated logic; shared logic extracted into reusable functions
* [ ] Lint/tests/build pass
* [ ] Always run `npm audit` to check vulnerabilities after all changes are implemented
* [ ] Always test that the localhost website is working, and each of its pages

