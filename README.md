# VastHorizon Bank 🏦

A personal finance iOS app built with SwiftUI that gamifies saving money through an RPG-style progression system. Earn XP for every dollar you save, level up, maintain streaks, and unlock achievement badges.

---

## Features

### Banking
- Set an opening balance and manage it across sessions
- Deposit and withdraw funds with real-time balance updates
- Apply a monthly fee 
- Full transaction history with total in / total out summary

### RPG Progression
- **XP System** — earn 1 XP per dollar deposited
- **Leveling** — every 100 XP advances your level; level-up overlay fires on threshold
- **Streak Tracking** — days without a withdrawal build your streak; any withdrawal resets it to zero
- **7 Badges** to unlock across saving milestones, streak goals, and level thresholds

### Badges
| Badge | Condition |
|---|---|
| ⭐ First Deposit | Make your first deposit |
| 🔥 Iron Discipline | 7-day no-withdrawal streak |
| 🛡️ Emergency Fund | Reach a $1,000 balance |
| ⚡ Rising Saver | Reach Level 5 |
| 👑 Wealth Builder | Reach Level 10 |
| 🏅 Centurion | Deposit $1,000 in total |
| 🔒 Iron Will | 30-day no-withdrawal streak |

---

## Architecture

This project follows **MVVM** with a clean separation of concerns across 8 files.

```
VastHorizon/
├── VastHorizonApp.swift      # App entry point
├── Models.swift              # Transaction, PlayerProfile, Badge, BankAction
├── AccountViewModel.swift    # @Observable ViewModel — all business logic & RPG engine
├── ContentView.swift         # Main dashboard (pure UI layer)
├── HistoryView.swift         # Transaction history sheet
├── BadgesView.swift          # Achievement grid
├── ViewComponents.swift      # Reusable components: XPBar, StreakChip, BalanceMeter, etc.
└── Extensions.swift          # Color(hex:), Double.currency, Date helpers
```

### Key Design Decisions

**`@Observable` ViewModel** — All state and logic lives in `AccountViewModel`. `ContentView` only holds ephemeral text field strings and delegates everything else to `vm`.

**Badge queue** — Multiple badges earned in a single transaction are shown sequentially via a `pendingBadges` array, preventing overlapping overlays.

**`BalanceMeter`** — A custom 270° arc component that sweeps from red to green as balance grows toward a $10,000 ceiling. Animates with `spring` on every balance change.

---

## Requirements

- iOS 17+
- Xcode 15+
- Swift 5.9+

---

## Getting Started

```bash
git clone https://github.com/blakeach/VastHorizon.git
cd VastHorizon
open VastHorizon.xcodeproj
```

Select a simulator or device and press **Run** (`⌘R`).

---

## Roadmap

- [ ] SwiftData migration for robust persistence
- [ ] iCloud sync via CloudKit
- [ ] Savings goals with progress tracking
- [ ] Spending categories and budget limits
- [ ] Unit tests for `AccountViewModel` transaction logic
- [ ] Widget showing current level and streak

---

