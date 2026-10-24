# DataNaija — Flutter Mobile Application

A production-quality Flutter frontend implementation of the DataNaija prototype — a Nigerian VTU (data/airtime) mobile app.

## Overview

This is a **frontend-only** Flutter application that faithfully reproduces the DataNaija design prototype (all ~18 screens). No backend, database, payment gateway, or external services are integrated. All data is locally simulated for demonstration purposes.

## Project Structure

```
lib/
├── core/
│   ├── constants/     # Design tokens (colors, spacing, typography, routes)
│   ├── theme/         # ThemeData built from prototype design system
│   └── utils/         # Currency formatter, phone validator, storage service,
│                      # Auto-Buy schedule engine and time-zone helpers
├── data/
│   ├── models/        # Data models (Transaction, Network, DataPlan, Auto-Buy, …)
│   ├── mock/          # Local mock data (no backend)
│   └── repositories/  # AppRepository — single source of truth for frontend state
│                      # AutoBuyRepository — the Auto-Buy rules and runner
├── assets/images/     # Brand artwork (app mark + full lockup)
└── presentation/
    ├── routes/        # Named route constants
    ├── screens/       # All app screens
    └── widgets/       # Reusable UI components (buttons, inputs, cards, etc.)
```

## Screens Implemented

| # | Screen | Route |
|---|--------|-------|
| 1 | Splash | `/` |
| 2 | Onboarding (2 slides) | `/onboarding` |
| 3 | Sign In | `/signin` |
| 4 | Sign Up | `/signup` |
| 5 | KYC (BVN/NIN verification) | `/kyc` |
| 6 | Home | `/home` |
| 7 | Buy Data (network + phone) | `/buy` |
| 8 | Select Data Bundle | `/bundle` |
| 9 | Review Purchase | `/review` |
| 10 | Processing | `/proc` |
| 11 | Purchase Success | `/ok` |
| 12 | Wallet | `/wallet` |
| 13 | Fund Wallet | `/fund` |
| 14 | Transactions (search + filters) | `/hist` |
| 15 | Transaction Details | `/detail` |
| 16 | Notifications | `/notif` |
| 17 | Profile | `/prof` |
| 18 | Help & Support (FAQs + contact) | `/help` |
| 19 | Security (fingerprint + passcode) | `/sec` |
| 20 | Referral (campaign + friends) | `/ref` |
| 21 | Auto-Buy (manage rules) | `/autobuy/list` |
| 22 | New / Edit Auto-Buy | `/autobuy/new` |
| 23 | Auto-Buy details + history | `/autobuy/detail` |

## Auto-Buy

Customers can create a rule that buys a data bundle automatically, on the
schedule they choose. The **server** owns the schedule so it keeps working
when the phone is off — see `datanaija-backend/src/lib/auto_buy/runner.ts`.

**Screens**

- `AutoBuySetupScreen` — network, number, bundle, frequency, weekdays, time
  and a live summary. Activation is confirmed in a sheet that requires the
  customer to tick the consent box.
- `AutoBuyListScreen` — every rule with its status, schedule and next
  purchase, plus pause / resume / edit / delete.
- `AutoBuyDetailScreen` — the full rule and the history of every automatic
  purchase (successful, failed, skipped).

**Frequencies** — every 2/4/6/12 hours, every day, every 2/3 days, every
week, every 2 weeks, every month and a custom interval (1–365 hours, days,
weeks or months). Weekly rules let the customer pick the weekdays.

**Safety** — the app mirrors the backend rules exactly:

| Rule | Where |
|---|---|
| One attempt per (rule, slot) | `AutoBuyRepository._executeSlot` |
| The bundle price and availability are re-checked before buying | `AutoBuyRepository._findPlan` |
| The wallet is never allowed to go negative | `AppRepository.purchaseDataAutoBuy` |
| A slot that was missed is skipped, not charged | `AutoBuyRepository.graceMinutes` |
| A failed attempt is retried, then the rule is paused | `AutoBuyRepository._fail` |

The schedule maths lives in `lib/core/utils/auto_buy_schedule_engine.dart`
and is the Dart twin of the backend's `schedule.ts`; both are covered by the
same set of expectations so the preview and the server agree.

## Design System

Colors, typography, spacing, and components replicate the prototype's design:
- **Primary accent:** `#0A7A4C` (green, themeable)
- **Typography:** Plus Jakarta Sans (500/600/700/800)
- **Currency:** Nigerian Naira (₦), `en-NG` locale
- **Phone validation:** Nigerian mobile format `/^0[789][01]\d{8}$/`
- **Brand artwork:** `assets/images/app_mark.png` (app mark) and
  `assets/images/app_logo.png` (mark + wordmark), used through the
  `AppLogo` widget

## Dependencies (minimal)

- `shared_preferences` — local persistence (onboarding, theme, KYC, auth state)
- `google_fonts` — Plus Jakarta Sans typeface
- `intl` — Naira currency formatting

No backend, payment, or analytics dependencies.

## Getting Started

### Prerequisites

- Flutter SDK (3.x+)
- Android Studio / Xcode or a connected Android/iOS device

### Run

```bash
cd data_naija_app
flutter pub get
flutter run
```

### Build APK

```bash
flutter build apk --debug
```

## Architecture Notes

- **State management:** `ChangeNotifier`-based `AppStore` singleton — no external state package
- **Data layer:** `AppRepository` wraps local `MockData`; easily swappable for a real API
- **Navigation:** Named routes via `MaterialApp.routes`
- **Theme:** Built from prototype design constants; accent color is overridable

## Simulated Functionality

The following are simulated locally (no backend):
- Sign in / sign up
- KYC verification
- Data purchase (deducts balance, creates transaction)
- Wallet funding (bank transfer, card/USSD, quick amounts)
- Referral bonus tracking
- Fingerprint toggle

These are clearly marked as demo-only and ready for backend integration.

## Testing

```bash
flutter analyze
flutter test
flutter build apk --debug
```

## License

MIT
