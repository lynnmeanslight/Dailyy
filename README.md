# Dailyy — macOS Productivity App

> *Keep it cozy ✨* — A calm, beautifully designed personal productivity companion for Apple Silicon Macs.

---

## Overview

**Dailyy** is a native macOS application built with SwiftUI and CoreData, targeting macOS 14.0+ on Apple Silicon (`arm64`). It brings together five personal productivity domains — budgeting, journaling, friend management, life-span awareness, and app customisation — in a single cohesive interface with a warm, Duolingo-inspired colour palette.

The app stores all data locally on-device (no cloud, no accounts), runs with a hidden title bar for a clean full-window feel, and supports **English and Myanmar (Burmese)** with instant runtime language switching.

---

## Screenshots at a Glance

| Section | What you see |
|---|---|
| Dashboard | Greeting, daily spending, upcoming birthdays, 50/30/20 summary, today's journal entry |
| Budget | Income vs. expenses, category breakdown, 7-day bar chart, transaction list with Add sheet |
| Diary | Searchable entry list, rich text editor, mood picker (8 moods), word count |
| Friends | Birthday countdown cards, search, add/edit/delete with avatar picker |
| Life Span | Week-grid visualisation, progress bar, inspirational counters |
| Settings | Appearance, language, profile (birthday + life expectancy), budget rule, notifications, export |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift 5.9 |
| UI Framework | SwiftUI (declarative, no AppKit UI code) |
| Data persistence | CoreData (on-device SQLite) |
| Architecture | MVVM — `ObservableObject` view-models, `@EnvironmentObject` for shared state, `@StateObject` / `@ObservedObject` ownership |
| Charts | SwiftUI Charts framework (budget bar chart, category pie) |
| Localization | Custom `LocalizationManager` with runtime `Bundle` switching |
| Platform | macOS 14.0+, Apple Silicon (`arm64`) |
| Build | Xcode, `xcodebuild` — no SPM dependencies |

---

## Project Structure

```
Dailyy/
├── App/
│   ├── DailyyApp.swift          # @main entry point, SceneGroup, env injection
│   └── ContentView.swift           # Sidebar + main-content router
│
├── CoreData/
│   ├── PersistenceController.swift # NSPersistentContainer setup + preview context
│   └── Dailyy.xcdatamodeld      # Entity definitions
│
├── ViewModels/
│   ├── AppViewModel.swift          # SettingsViewModel + AppSection enum
│   ├── BudgetViewModel.swift       # Income, expenses, 50/30/20 logic
│   ├── DiaryViewModel.swift        # Entries, mood enum, today's entry
│   └── FriendsViewModel.swift      # Friends CRUD, birthday countdown sorting
│
├── Views/
│   ├── Components/
│   │   ├── SidebarView.swift       # Fixed-width sidebar nav with animated items
│   │   └── SharedComponents.swift  # StatCard, SectionHeader, BucketRow, etc.
│   ├── Dashboard/
│   │   └── DashboardView.swift
│   ├── Budget/
│   │   └── BudgetView.swift
│   ├── Diary/
│   │   └── DiaryView.swift
│   ├── Friends/
│   │   └── FriendsView.swift
│   ├── LifeSpan/
│   │   └── LifeSpanView.swift
│   └── Settings/
│       └── SettingsView.swift
│
├── Extensions/
│   ├── DesignSystem.swift          # Colour palette, typography, AppStyle constants
│   ├── Extensions.swift            # Date helpers, Double.currencyString, etc.
│   └── LocalizationManager.swift   # Runtime language switching + L() helpers
│
└── Resources/
    ├── Info.plist
    ├── en.lproj/Localizable.strings
    └── my.lproj/Localizable.strings
```

---

## Features

### 🌤 Dashboard
- Time-aware greeting (morning / afternoon / evening)
- Three stat cards: today's spending, monthly balance, upcoming birthdays
- Inline 50/30/20 budget overview with colour-coded bucket rows
- Today's diary entry preview (if written)
- Horizontal birthday mini-card strip for friends with upcoming birthdays

### 🌿 Budget
- Record **income** or **expense** transactions with category, amount, note, and date
- Monthly summary: total income, total expenses, running balance
- **50/30/20 rule** overlay — Needs / Wants / Savings targets vs. actual spend
- 7-day bar chart (SwiftUI Charts) and category donut chart
- Full transaction list with swipe-to-delete
- Add Transaction sheet with validation

### 📖 Diary
- Search across all entries by title or body
- Rich text editor with live **word count**
- **8 moods**: Happy 😊, Excited 🎉, Calm 😌, Neutral 😐, Tired 😴, Sad 😢, Stressed 😤, Loved 🥰
- Date-stamped entries stored in CoreData
- Side-by-side list + editor layout

### 👥 Friends
- Friend cards with emoji avatar, name, location, notes, and birthday
- Upcoming birthdays section (within 30 days), sorted by proximity
- "Birthday today" 🎉 highlight
- Add / Edit / Delete with confirmation menu
- Searchable friend list

### ⏳ Life Span
- Set your **birthday** and **life expectancy** in Settings → Profile
- **Week grid** — one square per week of your life, rendered with SwiftUI `Canvas` for performance:
  - 🟩 Duolingo green = weeks already lived
  - 🔵 Sky blue = current week
  - ⬜ Light grey = future weeks
  - Year labels every 10 rows
- Animated **progress bar** showing weeks lived / total
- **Stats**: Age · Weeks Lived · Weeks Remaining · Percentage of life used
- **Inspiration cards**: days remaining, hours remaining, seasons remaining
- Motivational quote banner
- Graceful empty state if birthday is not yet set

### ⚙️ Settings

| Section | Controls |
|---|---|
| Profile | Birthday DatePicker, Life Expectancy stepper (50–120 yrs) |
| Appearance | System / Light / Dark segmented picker |
| Language | English 🇬🇧 / Myanmar 🇲🇲 menu picker (takes effect instantly) |
| Budget | Enable 50/30/20 toggle, Monthly Income field with 50/30/20 preview pills |
| Notifications | Birthday notification toggle |
| Data | Export button (NSSavePanel integration point) |
| About | App name, tagline, version |

---

## Design System

### Colour Palette (Duolingo-inspired)

| Token | Hex | Usage |
|---|---|---|
| `accentPrimary` | `#58CC02` | Primary action buttons, lived weeks, progress bar start |
| `accentSecondary` | `#1CB0F6` | Current week highlight, progress bar end, links |
| `pastelGreen` | `#CFF7B1` | Budget & dashboard cards |
| `pastelBlue` | `#B8E7FF` | Diary cards |
| `pastelPink` | `#FFC7E3` | Friends & birthday cards |
| `pastelPurple` | `#E6D6FF` | Life Span & misc cards |
| `pastelPeach` | `#FFE8A3` | Spending & expense cards |

### Typography

All fonts use the **rounded** design variant for a friendly, approachable feel:

| Token | Size | Weight |
|---|---|---|
| `appTitle` | 24 pt | Bold |
| `appHeading` | 18 pt | Semibold |
| `appBody` | 14 pt | Regular |
| `appCaption` | 12 pt | Regular |
| `appMono` | 13 pt | Medium, Monospaced |

### Layout Constants (`AppStyle`)

- Card corner radius: **20 pt**
- Shadow: `black @ 8% opacity`, radius 8, y-offset 4
- Window minimum size: **900 × 600 pt**
- Sidebar width: **180 pt** (fixed)

---

## Localisation

Dailyy supports **English** and **Myanmar (Burmese)** with no app restart required.

### Architecture

```
LocalizationManager (singleton ObservableObject)
  ├── @Published language: AppLanguage   ← drives view updates
  ├── bundle: Bundle                      ← language-specific .lproj bundle
  ├── func setLanguage(_:)               ← called by language picker in Settings
  └── func string(_:) / string(_:args:)  ← typed string lookup
```

Global shorthand functions `L("key")` and `L("key", arg1, arg2, ...)` are available throughout the codebase for concise string access.

The `LocalizationManager` is injected at the root via `.environmentObject(localization)` on `ContentView`, and every view that displays text declares `@EnvironmentObject var localization: LocalizationManager`.

### Coverage

All user-visible strings (~120 keys) are localised across both languages, including:
- Section names, tab labels
- Greeting messages, date formats
- Budget categories and rule labels
- Mood names, diary prompts
- Friend form fields, birthday countdown text
- Life Span stats, grid legend, inspirational quote
- Settings labels and alerts

---

## Data Model (CoreData)

All data is stored locally in a CoreData SQLite store. Three entities are defined:

| Entity | Key Attributes |
|---|---|
| `ExpenseEntry` | `id`, `amount`, `category`, `note`, `date`, `type` (income/expense) |
| `DiaryEntry` | `id`, `title`, `body`, `mood`, `date` |
| `Friend` | `id`, `name`, `avatarEmoji`, `location`, `notes`, `birthday`, `hasBirthday` |

User preferences (income, appearance, language, birthday, life expectancy) are persisted in **UserDefaults**.

---

## Architecture Notes

### MVVM Pattern

```
View  ──observes──►  ViewModel  ──reads/writes──►  CoreData / UserDefaults
 │                       │
 └── @EnvironmentObject   └── @Published properties trigger SwiftUI re-renders
```

- **`ContentView`** is the root router; it owns all view-model `@StateObject` instances and passes them down as `@ObservedObject`.
- **`SettingsViewModel`** is shared between `SettingsView` and `LifeSpanView` (passed as `@ObservedObject`) so birthday/life-expectancy changes reflect immediately in the Life Span tab.
- **`LocalizationManager`** is a singleton injected as an `@EnvironmentObject` at the app root.

### Navigation

A custom `SidebarView` (180 pt wide, fixed) drives navigation via a `@Binding<AppSection>` selection. Section switching uses an `asymmetric` SwiftUI transition (slide in from trailing edge, slide out to leading edge) with a spring animation.

### Performance

- The Life Span week grid (up to 52 × 120 = 6,240 cells) is rendered using SwiftUI `Canvas` with direct `CGPath` drawing for smooth, zero-lag performance.
- `LazyVGrid` is used for all multi-column stat card layouts.

---

## Building & Running

### Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 15.0 or later
- Apple Silicon Mac (`arm64`)

### Build

```bash
# Open in Xcode
open Dailyy.xcodeproj

# Or build from the command line
xcodebuild \
  -project Dailyy.xcodeproj \
  -scheme Dailyy \
  -destination 'platform=macOS,arch=arm64' \
  build
```

No external dependencies or package managers are required. The project builds cleanly with zero warnings.

---

## Roadmap / Extension Points

| Area | Idea |
|---|---|
| Data export | Wire the Export button to `NSSavePanel` to produce a JSON file |
| Notifications | Implement `UNUserNotificationCenter` birthday reminders (permission is already requested at launch) |
| iCloud sync | Add `NSPersistentCloudKitContainer` for cross-device CoreData sync |
| Widgets | Expose today's spending and next birthday via WidgetKit |
| Charts | Add monthly trend line chart to Budget |
| Life Span | Add a "decade view" grid mode alongside the week grid |
| Languages | Add additional `xx.lproj/Localizable.strings` files; `LocalizationManager` picks them up automatically |

---

## License

Private project. All rights reserved.
