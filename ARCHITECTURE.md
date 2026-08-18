# LifeLink Architecture

## Principles
- Firebase initialization and existing Firebase logic remain unchanged.
- Mobile pages live under `lib/features/mobile/screens`.
- Desktop-only presentation lives under `lib/features/desktop/screens`.
- Responsive decisions live once in `lib/core/responsive` and `lib/features/shared/widgets`.
- Shared Firebase/business widgets are reused; desktop screens do not duplicate data logic.
- All application colors are centralized in `lib/core/theme/app_colors.dart`.
- Global Material styling is centralized in `lib/core/theme/app_theme.dart`.

## Responsive flow
`MaterialApp -> AppResponsiveBuilder -> ResponsiveLayout -> Mobile/Desktop screen`

The responsive decision remains centralized. Mobile layouts stay unchanged below 800px; tablet and desktop use dedicated presentation shells where available. Service and admin detail pages reuse the original Firebase/business widgets and only constrain/arrange their presentation for larger screens.
