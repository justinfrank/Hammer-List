# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Hammer List** is a native iOS/macOS hierarchical todo list app built with SwiftUI and SwiftData. It features hand-drawn UI aesthetics, nested lists (items can own sub-lists), and a design token system with dark/light themes.

## Build & Test Commands

This is an Xcode project with no custom build scripts. Use standard `xcodebuild` commands:

```bash
# Build
xcodebuild -scheme "Hammer List" -configuration Debug build

# Run unit tests
xcodebuild test -scheme "Hammer List" -destination 'platform=iOS Simulator,name=iPhone 16'

# Run a single test class
xcodebuild test -scheme "Hammer List" -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:"Hammer ListTests/ClassName"
```

No external dependencies — pure SwiftUI + SwiftData with no package manager.

## Architecture

**Pattern**: MVVM + Manager layer

### Data Layer (SwiftData)

Two core models with a bidirectional recursive relationship:

- **`Item`** (`Models/Item.swift`): A todo item with `status: TodoStatus` (notStarted/inProgress/completed), `order: Int`, and `childLists: [ItemList]` — items can contain sub-lists.
- **`ItemList`** (`Models/ItemList.swift`): A list container with `items: [Item]` and an optional `parentItem: Item?`. Lists with no `parentItem` are root lists (`isRoot == true`).

Both use `deleteRule: .cascade` on their relationships. SwiftData persistence flows through `ModelContext` injected via the SwiftUI environment.

### Manager Layer

- **`ItemManager`** (`Managers/ItemManager.swift`): Static methods for all item CRUD (add, delete, reorder, toggle status). Call these instead of mutating models directly.
- **`ThemeManager`** (`Managers/ThemeManager.swift`): `@Observable` class managing theme override with `AppStorage` persistence. Injected via `@EnvironmentObject` app-wide.
- **`TestDataManager`** (`Managers/TestDataManager.swift`): Seeds test data on demand.

### Design System (`DesignSystem/`)

**Tokens** (`DesignSystem/Tokens/`):
- `Primitives.swift`: 100-level color scales (blue100–blue900, etc.)
- `AppTheme.swift`: Theme protocol — all components reference theme properties (brand, neutral, background, surface, text, accent, destructive)
- `Light/LightTheme.swift` & `Dark/DarkTheme.swift`: Concrete theme implementations
- `AppTokens.swift`: Spacing (4/8/16/24/32/48), typography, corner radius constants

**Components** are generic and protocol-driven: `TodoItemRow<T: ListItemProtocol>` accepts any type conforming to `ListItemProtocol`, enabling reuse across different item contexts.

**Effects** (`DesignSystem/Effects/`): `HandDrawnStroke.swift` implements the sketchy hand-drawn visual style using custom SwiftUI shapes with seeded RNG wobble — used on checkboxes and other UI elements.

### View Hierarchy

```
Hammer_ListApp
└── ContentView              ← NavigationStack root
    ├── ListOverview         ← Root list of all ItemLists
    ├── TodoListView         ← Single list detail
    │   └── ItemChildListsView  ← Nested sub-lists for an item
    ├── SettingsView         ← Theme switching (sheet)
    └── AboutView            ← About screen (sheet)
```

Navigation uses `navigationDestination(for: ItemList.self)` for deep linking into nested lists.

## Key Conventions

- **Theme access**: Always use `ThemeManager` / `AppTheme` properties for colors — never hardcode colors.
- **Spacing**: Use `AppTokens` spacing constants, not magic numbers.
- **Data mutations**: Go through `ItemManager` static methods; call `modelContext.save()` after mutations.
- **Generic components**: New list-related components should conform to `ListItemProtocol` for reuse.
- **Hand-drawn style**: UI intentionally uses `HandDrawnStroke` effects — preserve this aesthetic in new components.
