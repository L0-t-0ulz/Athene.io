# CLAUDE.md

Guidance for Claude Code (and other agents/developers) working in this repository.

## What this is

**AtheneNFT** — a SwiftUI iOS app for discovering, sharing, and collecting NFTs. Social-feed style UI: Home feed, Discover (categories + search), Share (create/transfer NFTs, camera), Notifications, and Profile tabs.

- **Status**: UI prototype. All data comes from mocks in `NFTService` with artificial delays; there is **no real backend integration yet**.
- **Platform**: iOS 17.0+, iPhone and iPad, Swift 5 / SwiftUI, forced dark mode.
- **Bundle ID**: `com.zayankhan12.AtheneNFT` (automatic signing, team `3MJ9PBQK7G`).
- **Dependencies**: none — pure SwiftUI + Combine + UIKit interop. No SPM packages, no CocoaPods.

## Repository layout

```
AtheneNFT/
├── AtheneNFT.xcodeproj
├── build.swift              # lists project Swift files (sanity helper, not a real build)
├── clean_build.sh           # wipes DerivedData + build/ and runs xcodebuild clean
└── AtheneNFT/               # app sources
    ├── AtheneNFTApp.swift   # entry point; dark-mode + memory-warning setup
    ├── Core/
    │   ├── MainTabView.swift        # 5-tab root navigation
    │   ├── Home/HomeView.swift      # NFT feed (posts, likes, captions)
    │   ├── Discover/                # DiscoverView, NFTCardView, NFTArtCard (categories, search)
    │   ├── Share/                   # ShareView, ShareViewModel, CameraView, WalletTransferView,
    │   │                            #   NFTTransferDetailView, ForYouView
    │   ├── Notifications/NotificationsView.swift
    │   └── Profile/                 # ProfileView, NFTDetailView
    ├── Models/NFT.swift             # NFT, User, Notification, Collection, BlockchainType
    ├── Services/NFTService.swift    # @MainActor singleton; mock API + (unwired) URLSession layer
    └── Utils/                       # FontUtility, UIImageExtensions, UIKitImageView
generate_app_icons.sh        # regenerates AppIcon set from a 1024px source via sips
```

## Build, run, verify

```bash
# Build (mirrors CI):
cd AtheneNFT
xcodebuild -project AtheneNFT.xcodeproj -scheme AtheneNFT \
  -destination 'platform=iOS Simulator,name=iPhone 16' clean build analyze

# Run ALL tests (unit + UI smoke; boots the simulator):
xcodebuild -project AtheneNFT.xcodeproj -scheme AtheneNFT \
  -destination 'platform=iOS Simulator,name=iPhone 16' test

# Reset a wedged build:
./clean_build.sh

# Run in simulator:
xcrun simctl boot "iPhone 16" && open -a Simulator
xcrun simctl install booted <path-to-AtheneNFT.app>
xcrun simctl launch booted com.zayankhan12.AtheneNFT
```

Tests live in `AtheneNFT/AtheneNFTTests` (unit: models, ShareViewModel, NFTService — mocks are deterministic on purpose, keep them that way) and `AtheneNFT/AtheneNFTUITests` (XCUITest smoke suite driving all 5 tabs, search, and the wallet sheet). The shared scheme `AtheneNFT` runs both. CI: `.github/workflows/ios.yml` runs build+analyze and the full test suite on pushes/PRs to `keys`.

## Conventions

- **State**: plain SwiftUI (`@State` / `@StateObject` / `@Published` + Combine). No MVVM framework.
- **Responsive sizing**: `DynamicSizing` (in `Utils/`) scales layouts from a 390pt-wide baseline — use it instead of hard-coded frame sizes.
- **Images**: `FallbackAsyncImage` loads bundled assets and falls back to gradient placeholders; don't add third-party image libraries.
- **Haptics**: UI interactions trigger `UIImpactFeedbackGenerator` feedback — keep new interactive elements consistent.
- **Logging**: use `os.Logger` (subsystem `com.zayankhan12.AtheneNFT`), not `print`.

## Gotchas

- **The default branch is `keys`** — not `main`. CI only triggers on `keys`.
- `NetworkConfig.baseURL` is a placeholder and the URLSession layer in `NFTService` is unwired; every public service method returns mock data with 0.5–2s simulated delays. Don't "fix" a network bug by editing the request layer — nothing calls it yet.
- `MetaMaskLoginApp/README.md` under the app sources is reference material for a future web3 login (React/Node) — it is not part of the iOS build.
- Icon asset names expected by `ImageLoader`/`FallbackAsyncImage`: Profile, New, Trending, Cards, Doge, Gifs, Celebrities.
- macOS case-insensitive filesystem: don't create files/folders differing only by case.

## Issue tracking

Known bugs and cleanup work live on the kanban board in **`KANBAN.md`** (cards `ATH-###`, tagged by severity). When you fix a card, move it to the Done column with a one-line resolution note; add new cards for anything you find.
