# Contributing to Promsell POS CE

Thank you for your interest in contributing to Promsell! This guide covers everything you need to get started.

---

## Quick start

```bash
# 1. Fork & clone
git clone https://github.com/YOUR_USERNAME/promsell-pos-ce.git
cd promsell-pos-ce

# 2. Install dependencies
flutter pub get

# 3. Generate code
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs

# 4. Verify setup
flutter analyze lib test
flutter test

# 5. Create a branch
git checkout -b feat/your-feature
```

---

## Development workflow

### 1. Fork → Branch → PR

1. **Fork** the repository on GitHub
2. **Create a branch** from `main`:
   - `feat/scope` — new features
   - `fix/scope` — bug fixes
   - `refactor/scope` — code refactoring
   - `docs/scope` — documentation only
   - `test/scope` — adding or updating tests
   - `chore/scope` — build, CI, tooling
3. **Make changes** (keep PRs focused — one concern per PR)
4. **Write tests** for your changes
5. **Submit a Pull Request** against `main`

### 2. Commit messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description

feat(sale): add discount input on cart
fix(report): correct date range filter for top products
docs(readme): add screenshots section
test(product): add unit test for product form validation
refactor(settings): extract theme tile to separate widget
chore(deps): bump flutter_bloc to 9.2.0
```

**Types:** `feat`, `fix`, `docs`, `test`, `refactor`, `chore`, `perf`

**Rules:**
- Use imperative mood (`add` not `added`)
- No period at the end
- Body (optional): explain WHY, not WHAT
- Breaking changes: `feat(scope)!: description` + `BREAKING CHANGE:` in body

### 3. Pull request checklist

Before submitting, verify:

- [ ] `flutter analyze lib test` passes with no errors
- [ ] `flutter test` passes
- [ ] Code generation is up to date (`flutter gen-l10n`, `build_runner build`)
- [ ] Commit messages follow Conventional Commits format
- [ ] PR description explains the change and motivation
- [ ] New strings added to both `app_th.arb` and `app_en.arb`
- [ ] UI changes checked on compact and expanded layouts
- [ ] Shared UI widgets or theme tokens reused before adding new one-off styling
- [ ] One concern per PR — no unrelated changes

---

## Code style

### Dart / Flutter

- **2-space indentation** — enforced by `dart format`
- **Single quotes** — for string literals
- **No unused imports** — remove before submitting
- **No `print()`** — use proper error handling; `debugPrint` only during development
- **No over-engineering** — keep it simple, direct, self-documenting
- **No unnecessary comments** — code should explain itself; comments for WHY, not WHAT
- **`const` constructors** — use wherever possible for performance
- **`context.l10n`** — never hardcode user-facing strings; always use localization

### Clean Architecture rules

- **Domain has zero Flutter/external imports** — pure Dart only in `domain/`
- **No cross-feature imports** — features must not import from each other
- **Repository pattern** — always use abstract interfaces in domain, inject implementations
- **No business logic in widgets** — delegate to BLoC/Cubit via events/methods

### Localization

When adding any user-facing string:

1. Add Thai key+value to `lib/l10n/app_th.arb`
2. Add same key+English value to `lib/l10n/app_en.arb`
3. Run `flutter gen-l10n`
4. Use via `context.l10n.yourKey`

Never hardcode Thai or English strings in widget code.

### UI / UX changes

When working on presentation code:

- Prefer shared primitives from `lib/core/widgets/` before creating feature-local duplicates
- Prefer theme tokens from `lib/core/theme/` over ad-hoc colors, radius, or padding
- Keep primary actions touch-friendly and reachable on compact mobile screens
- Test constrained layouts such as bottom sheets, cart panels, and forms with the keyboard open
- Verify light, dark, and system theme modes if colors or surfaces changed
- Add widget tests for reusable UI behavior, especially compact/overflow cases

---

## Testing

### Required tests

| Change type | Test required |
|-------------|---------------|
| Bug fix | Regression test that fails before fix |
| New feature | Unit test for domain logic + widget test if UI |
| New use case | Unit test with mock repository |
| Security fix | Test covering the specific vulnerability |
| Refactor | Existing tests must still pass |

### Running tests

The project has **187 automated tests**. All must pass before submitting a PR.

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run a single test file
flutter test test/integration/checkout_flow_test.dart

# Analyze only our code (ignore other workspace projects)
flutter analyze lib test

# Dart format check
dart format --output=none --set-exit-if-changed lib test
```

### Test layers

| Layer | Technique | Location |
|-------|-----------|----------|
| **Domain** | Unit test (pure Dart) | `test/features/*/domain/` |
| **BLoC / Cubit** | `bloc_test` + mocked use cases | `test/features/*/presentation/bloc/` |
| **Repository** | `mocktail` mocked datasources | `test/features/*/data/repositories/` |
| **Datasource** | In-memory Drift DB (`sqlite3_flutter_libs`) | `test/features/*/data/datasources/` |
| **Widget** | `pumpApp` helper + `MockBloc` | `test/features/*/presentation/pages/` |
| **Services** | Unit test (real DB) | `test/features/*/data/services/` |
| **Integration** | End-to-end data layer | `test/integration/` |
| **L10n parity** | Direct class instantiation | `test/l10n/` |

### Writing tests

Tests live in `test/` mirroring the `lib/` structure:

```
test/
├── helpers/
│   ├── mocks.dart              # Shared mocks (repos, datasources, BLoCs, Cubits)
│   ├── pump_app.dart           # pumpApp extension for widget tests
│   └── fake_database.dart      # In-memory Drift DB factory
├── features/
│   ├── sale/
│   │   ├── domain/usecases/
│   │   ├── data/repositories/
│   │   ├── data/datasources/
│   │   └── presentation/
│   ├── product/
│   ├── history/
│   └── settings/
├── integration/
│   ├── checkout_flow_test.dart
│   └── sale_integrity_test.dart
├── l10n/
│   └── l10n_parity_test.dart
└── core/
    └── utils/
```

Follow **AAA pattern**:

```dart
test('description of what is tested', () {
  // Arrange
  final repo = MockSettingsRepository();
  final cubit = SettingsCubit(repo);

  // Act
  cubit.load();

  // Assert
  expect(cubit.state.settings.locale, 'th');
});
```

---

## Project architecture

Read `CODEBASE.md` for module/file reference. See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for deep technical details (C4 diagrams, data flows, transaction boundaries, DI graph, ADRs).

**Key files:**
- `lib/core/di/injection_container.dart` — service locator registrations
- `lib/core/extensions/l10n_extension.dart` — `context.l10n` helper
- `lib/core/utils/payment_method_helper.dart` — payment method normalization
- `lib/core/widgets/` — shared UI widgets (`AppEmptyState`, `MoneyText`, `SectionCard`, breakpoints)
- `lib/core/database/app_database.dart` — Drift schema and DAOs
- `lib/main.dart` — app entry, `SettingsCubit` provider, 5-tab shell

---

## Reporting issues

- **Bugs:** [Open a bug report](https://github.com/teeprakorn1/promsell-pos-ce/issues/new) with steps to reproduce, device info, and Flutter version
- **Features:** [Open a feature request](https://github.com/teeprakorn1/promsell-pos-ce/issues/new) with use case description
- **Security:** See [SECURITY.md](SECURITY.md) — do **not** file public issues for security vulnerabilities

---

## Questions?

Open a [GitHub Discussion](https://github.com/teeprakorn1/promsell-pos-ce/discussions) or ask in the issue tracker.

Thank you for contributing! 🙏
