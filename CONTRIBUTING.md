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
# Do not stage *.g.dart / *.config.dart. lib/l10n/app_localizations*.dart
# are still tracked — include them if gen-l10n changed them.
flutter gen-l10n
dart run build_runner build

# 4. Verify setup (matches ci.yml — see docs/testing/CI.md)
flutter analyze
dart run tool/check_domain_fence.dart
dart format --set-exit-if-changed lib/ test/ integration_test/
flutter test --exclude-tags stress
flutter test test/performance/ --no-pub --reporter compact

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

- [ ] `flutter analyze` passes with no errors
- [ ] `dart run tool/check_domain_fence.dart` passes with no expired or unallowlisted violations
- [ ] `dart format --set-exit-if-changed lib/ test/ integration_test/` passes
- [ ] `flutter test --exclude-tags stress` passes
- [ ] `flutter test test/performance/ --no-pub --reporter compact` passes
- [ ] Code generation is up to date (`flutter gen-l10n`, `build_runner build`)
- [ ] No generated files (`*.g.dart`, `*.config.dart`) staged in git
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
- Prefer image widgets from `lib/core/image/` (`UnifiedImageWidget`, `ImageSkeleton`, `ImageErrorPlaceholder`) for all product/user image display
- Prefer theme tokens from `lib/core/theme/` over ad-hoc colors, radius, or padding
- Use `colorScheme.*` (e.g., `colorScheme.primary`, `colorScheme.error`) instead of `Colors.*` — never hardcode Material colors in feature code
- Use `AppColors` tokens from `lib/core/theme/app_colors.dart` for status/warning/success/error colors instead of `Colors.green`, `Colors.red`, etc.
- Use `AppSnackBar.info/success/error` for all snackbars — never raw `ScaffoldMessenger.showSnackBar`
- Use `BlocSelector` (not `BlocBuilder`) when a widget only needs a slice of BLoC state (e.g., single category in product tiles)
- Use shared navigation helpers from `product_navigation.dart` (`showProductEditPage`, `showProductPreviewPage`, `confirmDeleteProduct`) — never duplicate `_showEdit`/`_showPreview` in tiles or pages
- Use `ProductCardShell` for product card containers — flat `Container` + `BoxDecoration` (no `Card` elevation) for clean `Dismissible` integration
- Keep primary actions touch-friendly and reachable on compact mobile screens
- Test constrained layouts such as bottom sheets, cart panels, and forms with the keyboard open
- Verify light, dark, and system theme modes if colors or surfaces changed
- Add widget tests for reusable UI behavior, especially compact/overflow cases

---

## Performance Guidelines

### Before Submitting PR

Performance checklist:
- [ ] No N+1 database query patterns (use batch loading for related data)
- [ ] Heavy widgets use `RepaintBoundary` to prevent unnecessary repaints
- [ ] Use `BlocSelector` instead of `BlocBuilder` when rebuilding on specific state fields
- [ ] Add `const` constructors where possible (use `flutter analyze` to find opportunities)
- [ ] Cache computed values in state classes (avoid repeated fold/map operations)
- [ ] Verify scroll performance (use Flutter DevTools Performance tab)

### Performance Benchmarks

Target metrics:
- Product list load: <100ms (for 100 items)
- Cart update: <5ms (for 20 items)
- Scroll frame time: <16ms (60fps)

See [docs/api/DATABASE_API.md](docs/api/DATABASE_API.md) for query optimization patterns.

---

## E2E Test Requirements

### When to Add Integration Tests

Add E2E tests for:
- User-facing features (flows that users interact with)
- Critical business logic (sales, payments, inventory)
- Data persistence scenarios (cart recovery, draft saves)
- Error handling and validation flows

### Running E2E Tests

Needs a device/emulator. Main CI does **not** run these; trust does on tags / money-path PRs (`--flavor dev`). See [`docs/testing/CI.md`](docs/testing/CI.md).

```bash
flutter analyze integration_test/
flutter test integration_test/all_tests.dart --flavor dev -t lib/main_dev.dart
```

### E2E Test Coverage Checklist

- [ ] Happy path scenario (normal user flow)
- [ ] Error handling (validation errors, business rule violations)
- [ ] Edge cases (empty states, maximum values, zero quantities)
- [ ] State consistency (database and UI stay in sync)
- [ ] Offline behavior (if applicable)

### Writing E2E Tests

Use Robot pattern for maintainable tests:

```dart
testWidgets('User can complete a sale', (tester) async {
  await tester.pumpWidget(createTestApp());
  
  final saleRobot = SaleRobot(tester);
  final checkoutRobot = CheckoutRobot(tester);
  
  await saleRobot.openSalePage();
  await saleRobot.addProductToCart('Coffee');
  await saleRobot.proceedToCheckout();
  await checkoutRobot.selectPaymentMethod('cash');
  await checkoutRobot.completeSale();
  
  saleRobot.verifyCartIsEmpty();
});
```

See [docs/testing/E2E_TEST_GUIDE.md](docs/testing/E2E_TEST_GUIDE.md) for detailed guide.

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

The project has **automated tests** (run `flutter test --exclude-tags stress`; count drifts with the suite). All must pass before submitting a PR.

Match [`.github/workflows/ci.yml`](.github/workflows/ci.yml). Map: [`docs/testing/CI.md`](docs/testing/CI.md).

```bash
flutter gen-l10n && dart run build_runner build
flutter analyze
flutter test --coverage --exclude-tags stress
flutter test test/performance/ --no-pub --reporter compact
dart format --set-exit-if-changed lib/ test/ integration_test/
flutter analyze integration_test/
dart run tool/check_path_coverage.dart --lcov coverage/lcov.info --fail --min-global=60 --min-sale-logic=80
dart run tool/check_outdated.dart

# Money-path / tag also runs the host list in release-trust.yml
# Device (emulator, not every PR):
# flutter test integration_test/all_tests.dart --flavor dev -t lib/main_dev.dart
```

Main CI does **not** run device E2E. Tags `v*` and money-path PRs **block** on the emulator job (`--flavor dev`).

### Test layers

| Layer | Technique | Location |
|-------|-----------|----------|
| **Domain** | Unit test (pure Dart) | `test/features/*/domain/` |
| **BLoC / Cubit** | `bloc_test` + mocked use cases | `test/features/*/presentation/bloc/` |
| **Repository** | `mocktail` mocked datasources | `test/features/*/data/repositories/` |
| **Datasource** | In-memory Drift DB (`sqlcipher_flutter_libs (production) / in-memory Drift for tests`) | `test/features/*/data/datasources/` |
| **Widget** | `pumpApp` helper + `MockBloc` | `test/features/*/presentation/pages/` |
| **Services** | Unit test (real DB) | `test/features/*/data/services/` |
| **Integration** | End-to-end data layer | `test/integration/` |
| **Stress** | `@Tags(['stress'])` — excluded from default run | `test/tool/` |
| **L10n parity** | Direct class instantiation | `test/l10n/` |

### Writing tests

Tests live in `test/` mirroring the `lib/` structure:

```
test/
├── helpers/
│   ├── mocks.dart              # Shared mocks (repos, datasources, BLoCs, Cubits)
│   ├── fixtures.dart           # Test entity fixtures
│   ├── pump_app.dart           # pumpApp extension for widget tests
│   └── fake_database.dart      # In-memory Drift DB factory
├── features/
│   ├── sale/
│   │   ├── domain/usecases/
│   │   ├── data/repositories/
│   │   ├── data/datasources/
│   │   └── presentation/
│   ├── product/
│   ├── customer/
│   ├── promotion/
│   ├── home/
│   ├── history/
│   ├── inventory/
│   ├── daily_close/
│   ├── onboarding/
│   ├── receipt/
│   ├── report/
│   ├── restaurant_table/
│   └── settings/
├── integration/
│   ├── backup_money_continuity_test.dart
│   ├── checkout_flow_test.dart
│   ├── multi_tender_daily_close_test.dart
│   ├── onboarding_first_sale_test.dart
│   └── sale_integrity_test.dart
├── tool/
│   └── seed_integration_test.dart  # Stress (@Tags(['stress']))
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

Read `CODEBASE.md` for module/file reference. See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for deep technical details (C4 diagrams, data flows, transaction boundaries, DI graph, ADRs). For version history, see [`CHANGELOG.md`](CHANGELOG.md) (current release notes v0.9.2; disk/pubspec remains 0.9.1+1 until the version bump) and [`docs/changelog/`](docs/changelog/) (archived v0.1.x–v0.8.x).

**Key files:**
- `lib/core/di/injection_container.dart` — `injectable` + `get_it` registrations (generated config in `injection_container.config.dart`)
- `lib/core/extensions/l10n_extension.dart` — `context.l10n` helper
- `lib/core/utils/payment_method_helper.dart` — payment method normalization
- `lib/core/widgets/` — shared UI widgets (`AppEmptyState`, `MoneyText`, `SectionCard`, breakpoints, `ImageViewerDialog`, `BarcodeScannerDialog`, `showImageSourceSheet`, `OverlayToast`)
- `lib/core/utils/ean13_generator.dart` — `@injectable` EAN-13 barcode generator with Luhn check digit; injected into `GenerateBarcode`, `BatchGenerateBarcodes`, `SettingsCubit`
- `lib/core/image/` — unified image system (`UnifiedImageWidget`, `ImageSkeleton`, `ImageErrorPlaceholder`, `ImageCacheService`)
- `lib/core/database/app_database.dart` — Drift schema and DAOs
- `lib/main.dart` — shared app entry (`runPromsellApp`), `SettingsCubit` provider, 5-tab shell
- `lib/main_dev.dart` / `lib/main_prod.dart` — flavor-specific entry points (v0.8.3+)

---

## Reporting issues

- **Bugs:** [Open a bug report](https://github.com/teeprakorn1/promsell-pos-ce/issues/new) with steps to reproduce, device info, and Flutter version
- **Features:** [Open a feature request](https://github.com/teeprakorn1/promsell-pos-ce/issues/new) with use case description
- **Security:** See [SECURITY.md](SECURITY.md) — do **not** file public issues for security vulnerabilities

---

## Questions?

Open a [GitHub Discussion](https://github.com/teeprakorn1/promsell-pos-ce/discussions) or ask in the issue tracker.

Thank you for contributing! 🙏
