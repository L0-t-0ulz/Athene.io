<div align="center">

<img src="AtheneNFT/AtheneNFT/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png" width="120" alt="Athene.io app icon — stylized owl emblem on a dark gradient">

# Athene.io — AtheneNFT

**A SwiftUI iOS app for discovering, sharing, and collecting NFTs.**

[![Xcode - Build and Analyze](https://github.com/L0-t-0ulz/Athene.io/actions/workflows/objective-c-xcode.yml/badge.svg)](https://github.com/L0-t-0ulz/Athene.io/actions/workflows/objective-c-xcode.yml)
[![Kanban](https://img.shields.io/badge/kanban-secure--backend%20backlog-blue)](https://github.com/orgs/L0-t-0ulz/projects/2)
[![Platform](https://img.shields.io/badge/platform-iOS%2017%2B-lightgrey)](#building--running)

</div>

---

## Table of contents

1. [About](#about)
2. [Current status](#current-status)
3. [Feature tour](#feature-tour)
4. [Visual gallery — all app artwork](#visual-gallery--all-app-artwork)
5. [Architecture](#architecture)
6. [API contract](#api-contract)
7. [Roadmap & issue tracker](#roadmap--issue-tracker)
8. [Building & running](#building--running)
9. [Contributing](#contributing)
10. [Copyright & legal notice](#copyright--legal-notice)

---

## About

**AtheneNFT** is a social-feed style NFT marketplace app for iPhone and iPad, built entirely
with native SwiftUI (no third-party dependencies — no SPM packages, no CocoaPods). It presents
NFTs the way a social app presents posts: a trending home feed, category-driven discovery with
search, an upload/share flow with camera capture, wallet-to-wallet NFT transfer, notifications,
and a collector profile.

- **Platform:** iOS 17.0+, iPhone & iPad, Swift 5 / SwiftUI, forced dark mode
- **Stack:** SwiftUI + Combine + UIKit interop only
- **Bundle ID:** `com.zayankhan12.AtheneNFT`

## Current status

> **UI prototype.** Every screen is fully built, but all data comes from mock generators inside
> `NFTService` with artificial network delays — there is **no real backend yet**. The base URL in
> `AtheneNFT/AtheneNFT/Services/NFTService.swift` is a placeholder and the Authorization header is
> a dummy token. Building the real, secure backend is the focus of the
> [120-issue secure-backend backlog](https://github.com/orgs/L0-t-0ulz/projects/2) (see
> [Roadmap](#roadmap--issue-tracker)).

## Feature tour

| Tab | What it does |
|---|---|
| **Home** | Trending NFT feed in a social-post layout: artwork, creator, like counts, price. Pull-based refresh against the (mocked) `/nfts/trending` endpoint. |
| **Discover** | Category chips (Trending, New, Cards, Celebrities, Doge, GIFs), a searchable NFT grid, and rich NFT cards. Search hits the (mocked) `/nfts/search` endpoint. |
| **Share** | Create a new NFT: pick or capture an image (AVFoundation camera), set title/description/price, and upload (currently simulated). Also hosts the **wallet transfer** flow for sending an NFT to another wallet address. |
| **Notifications** | Likes, follows, sales, and transfer alerts from the (mocked) `/notifications` endpoint, with per-item read state. |
| **Profile** | Collector profile with stats (items, followers, following), owned-NFT grid, shimmer loading states, settings, and NFT detail views with properties. |

## Visual gallery — all app artwork

Every image asset shipped in the app (`AtheneNFT/AtheneNFT/Assets.xcassets/`), in detail.

### App icon

The Athene owl emblem, provided in all 13 iOS icon resolutions (20pt → 1024pt marketing).

| | |
|:---:|:---|
| <img src="AtheneNFT/AtheneNFT/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png" width="140"> | **`AppIcon-1024.png`** — 1024×1024 App Store marketing icon. The same artwork backs `AppIcon-180/167/152/120/87/80/76/60/58/40/29/20.png` for home screen, Spotlight, and Settings on iPhone and iPad. |

### Trending — home-feed artwork (`Trending.imageset`)

Feature artwork used by the Home tab's trending feed cards.

| <img src="AtheneNFT/AtheneNFT/Assets.xcassets/Trending.imageset/Image@19.png" width="220"> | <img src="AtheneNFT/AtheneNFT/Assets.xcassets/Trending.imageset/Image@20.png" width="220"> | <img src="AtheneNFT/AtheneNFT/Assets.xcassets/Trending.imageset/Image@21.png" width="220"> |
|:---:|:---:|:---:|
| `Image@19.png` — trending drop #1 | `Image@20.png` — trending drop #2 | `Image@21.png` — trending drop #3 |

### Cards — collectible card art (`Cards.imageset`)

Artwork for the "Cards" discovery category — trading-card style collectibles.

| <img src="AtheneNFT/AtheneNFT/Assets.xcassets/Cards.imageset/Image@9.png" width="220"> | <img src="AtheneNFT/AtheneNFT/Assets.xcassets/Cards.imageset/Image@10.png" width="220"> | <img src="AtheneNFT/AtheneNFT/Assets.xcassets/Cards.imageset/Image@12.png" width="220"> |
|:---:|:---:|:---:|
| `Image@9.png` — card series art #1 | `Image@10.png` — card series art #2 | `Image@12.png` — card series art #3 |

### Celebrities — celebrity category art (`Celebrities.imageset`)

Photographic artwork backing the "Celebrities" discovery category.

| <img src="AtheneNFT/AtheneNFT/Assets.xcassets/Celebrities.imageset/Image@2.jpg" width="220"> | <img src="AtheneNFT/AtheneNFT/Assets.xcassets/Celebrities.imageset/Image@4.jpg" width="220"> | <img src="AtheneNFT/AtheneNFT/Assets.xcassets/Celebrities.imageset/Image@5.jpg" width="220"> |
|:---:|:---:|:---:|
| `Image@2.jpg` — celebrity collection #1 | `Image@4.jpg` — celebrity collection #2 | `Image@5.jpg` — celebrity collection #3 |

### Doge — meme collection art (`Doge.imageset`)

The doge-themed meme NFT collection shown in Discover.

| <img src="AtheneNFT/AtheneNFT/Assets.xcassets/Doge.imageset/Image@15.png" width="220"> | <img src="AtheneNFT/AtheneNFT/Assets.xcassets/Doge.imageset/Image@16.png" width="220"> | <img src="AtheneNFT/AtheneNFT/Assets.xcassets/Doge.imageset/Image@17.png" width="220"> |
|:---:|:---:|:---:|
| `Image@15.png` — doge #1 | `Image@16.png` — doge #2 | `Image@17.png` — doge #3 |

### GIFs — animated category art (`Gifs.imageset`)

Artwork for the "GIFs" discovery category (stored as stills).

| <img src="AtheneNFT/AtheneNFT/Assets.xcassets/Gifs.imageset/Image@1.png" width="220"> | <img src="AtheneNFT/AtheneNFT/Assets.xcassets/Gifs.imageset/Image@3.png" width="220"> | <img src="AtheneNFT/AtheneNFT/Assets.xcassets/Gifs.imageset/Image@6.png" width="220"> |
|:---:|:---:|:---:|
| `Image@1.png` — animated series #1 | `Image@3.png` — animated series #2 | `Image@6.png` — animated series #3 |

### New drops & profile

| <img src="AtheneNFT/AtheneNFT/Assets.xcassets/New.imageset/Image@24.png" width="220"> | <img src="AtheneNFT/AtheneNFT/Assets.xcassets/Profile.imageset/profile@image.png" width="220"> |
|:---:|:---:|
| `New.imageset/Image@24.png` — "New" category hero artwork | `Profile.imageset/profile@image.png` — default profile avatar |

## Architecture

```
AtheneNFT/
├── AtheneNFT.xcodeproj
├── build.swift                  # lists project Swift files (sanity helper)
├── clean_build.sh               # wipes DerivedData + build/ and runs xcodebuild clean
└── AtheneNFT/
    ├── AtheneNFTApp.swift       # entry point, forced dark mode, FontManager
    ├── Core/                    # feature screens
    │   ├── MainTabView.swift    # 5-tab shell
    │   ├── Home/                # trending feed
    │   ├── Discover/            # categories, search, NFT cards
    │   ├── Share/               # create NFT, camera, wallet transfer
    │   ├── Notifications/
    │   └── Profile/
    ├── Models/NFT.swift         # NFT, User, Collection, Notification models
    ├── Services/NFTService.swift# API client layer (all endpoints currently mocked)
    ├── Utils/                   # image loading, fonts, UIKit interop
    └── Assets.xcassets/         # all artwork shown in the gallery above
```

- **Pattern:** Model–View with `ObservableObject` view models and Combine publishers.
- **Networking:** `URLSession` + Combine in `NFTService`; every endpoint currently short-circuits
  to deterministic mock data behind an artificial delay.
- **Planned backend:** Node.js/Express + MongoDB implementing the contract below, with
  MetaMask / Sign-In-With-Ethereum authentication — tracked issue-by-issue on the
  [project board](https://github.com/orgs/L0-t-0ulz/projects/2).

## API contract

The client defines this 10-endpoint contract (see `Services/NFTService.swift`); the real server
must implement it:

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/nfts/trending` | Trending feed |
| GET | `/nfts/user/{userId}` | NFTs owned by a user |
| GET | `/nfts/search` | Search NFTs |
| POST | `/nfts/create` | Mint/upload a new NFT |
| POST | `/nfts/{id}/like` | Like an NFT |
| POST | `/nfts/{id}/unlike` | Remove a like |
| POST | `/users/{id}/follow` | Follow a user |
| POST | `/users/{id}/unfollow` | Unfollow a user |
| GET | `/notifications` | Notification feed |
| POST | `/notifications/{id}/read` | Mark notification read |

## Roadmap & issue tracker

All engineering work is tracked on the
**[Athene.io kanban board](https://github.com/orgs/L0-t-0ulz/projects/2)** — a
**120-issue secure-backend backlog** (10 epics `#111–#120`, 110 fix issues `#1–#110`) focused on
building and hardening the backend. No frontend tickets by design.

| Prefix | Track | Issues |
|---|---|---|
| `TEST` | Sandbox & test infrastructure (root prerequisite: [`TEST-001` #1](https://github.com/L0-t-0ulz/Athene.io/issues/1)) | 10 |
| `AUTH` | Authentication, Keychain, sessions, SIWE wallet login | 14 |
| `NET` | Transport security: ATS/TLS, pinning, signing, replay protection | 10 |
| `API` | API-client hardening in `NFTService` | 14 |
| `SRV` | Backend server build & security (authz/IDOR, rate limiting, injection, secrets) | 20 |
| `VAL` | Input validation & data handling | 12 |
| `CFG` | Secrets & configuration | 8 |
| `LOG` | Error handling & logging hygiene | 7 |
| `HYG` | Dead code & repository hygiene | 8 |
| `CI` | CI/CD security & enforcement | 7 |

**Sandbox approval gate:** every ticket carries a mandatory
*"Approval gate — sandbox verification"* section — no ticket may be approved or closed without
sandbox test evidence attached (reproduced before the fix, verified after it). The sandbox itself
is defined by [`TEST-001`](https://github.com/L0-t-0ulz/Athene.io/issues/1).

The historical single-file debug board lives in [`KANBAN.md`](KANBAN.md) (`ATH-###` cards);
agent/developer conventions live in [`CLAUDE.md`](CLAUDE.md).

## Building & running

```bash
git clone https://github.com/L0-t-0ulz/Athene.io.git
cd Athene.io/AtheneNFT
open AtheneNFT.xcodeproj
```

1. Requires **Xcode 15+** and an **iOS 17** simulator or device.
2. Select the `AtheneNFT` scheme and run (`⌘R`). No dependency installation is needed.
3. To reset a broken build: `./clean_build.sh`.

CI builds and analyzes the app on every push and pull request via
[`objective-c-xcode.yml`](.github/workflows/objective-c-xcode.yml).

## Contributing

1. Pick a ticket from the [kanban board](https://github.com/orgs/L0-t-0ulz/projects/2)
   (`Todo` column) and move it to `In Progress`.
2. Branch from the default branch; keep changes scoped to the ticket.
3. **Sandbox evidence is mandatory:** before a ticket can be approved, attach sandbox run
   output/test evidence to the issue — reproduce the problem in the sandbox first, then show it
   fixed. Tickets without evidence will not be merged.
4. Open a PR referencing the issue (`Fixes #NN`); it must pass the CI build.

## Copyright & legal notice

**Copyright © 2026 L0-t-0ulz. All rights reserved.**

This repository — including all source code, application design, artwork, images, icons, brand
assets, and documentation contained herein — is the proprietary property of **L0-t-0ulz** and its
contributors. It is published for reference and collaboration within this project only.

**No license is granted.** Unless you have received prior written permission from the copyright
holder, you may **not** copy, reproduce, modify, redistribute, sublicense, sell, or use any part
of this repository or its assets in your own projects, products, or services, whether commercial
or non-commercial.

**Unauthorized copying, reproduction, distribution, or commercial exploitation of this software
or its artwork is strictly prohibited and will result in legal action.**

The "Athene.io" / "AtheneNFT" names, the owl emblem, and all NFT artwork shown in the
[gallery](#visual-gallery--all-app-artwork) are protected works. Third-party trademarks referenced
in this repository (Apple, Xcode, MetaMask, GitHub, etc.) remain the property of their respective
owners.

For licensing inquiries or permission requests, open an issue on this repository or contact the
repository owner via GitHub ([@L0-t-0ulz](https://github.com/L0-t-0ulz)).
