# AtheneNFT Kanban — Debug Board

Cards: `ATH-###` · severity: `crash` `security` `bug` `concurrency` `quality` `test` `build`
Every card cites a verified `file:line` (paths relative to `AtheneNFT/AtheneNFT/`). Files marked **[orphan]** exist on disk but are **not in the Xcode target** (see ATH-060) — their bugs don't ship, but they're still in the repo.

Columns: **Backlog** (open) · **In Progress** · **Done** (with resolution note).

---

## Backlog

### Security / configuration

- [ ] **ATH-021** `security` Services/NFTService.swift — share links still point at placeholder domain `your-app.com` (now centralized in `NetworkConfig.shareBaseURL` and documented); pick and register a real domain before launch

### Missing states / unwired UI

- [ ] **ATH-057** `quality` Core/Discover/DiscoverView.swift — SearchView has loading/no-results states but no error state (mock search cannot fail until a backend exists; add alongside real API)
- [ ] **ATH-060** `bug` project — 11 Swift files on disk are **not in the build target**: UIImageExtensions, FontUtility, NFTCardView, NFTArtCard, ForYouView + the 7-file MetaMaskLoginApp stub module; decide adopt-or-delete for each (type collisions now defused, see ATH-061/062 in Done)
- [ ] **ATH-063** `quality` Core/Profile/ProfileView.swift — profile hardcodes "ben_parker53"/"Ben Parker"/bio; not driven by the `User` model (needs a current-user data source decision)

### Dead code / duplication

- [ ] **ATH-086** `quality` AtheneNFTApp.swift:77-83 — every `Font.custom("Noto Sans", …)` call app-wide silently falls back to system font because Noto Sans is not bundled; bundle + register the typeface (fallback behavior is now documented in FontManager)
- [ ] **ATH-087** `quality` three duplicate gradient-placeholder implementations: UIImageExtensions:127/160 [orphan], UIKitImageView:57, FallbackAsyncImage:141
- [ ] **ATH-089** `quality` press-bounce animation pattern still duplicated 6× (now via `withAnimation completion:` instead of `asyncAfter`): MainTabView, HomeView, DiscoverView ×2, ProfileView — extract a shared `.pressBounce` modifier
- [ ] **ATH-091** `quality` four separate mock-data factories: NFTService, HomeView, SampleNFTData (DiscoverView), ForYouView [orphan]
- [ ] **ATH-092** `quality` overlapping item models: `NFTItem` (Models/NFT.swift), `NFTItemData` (DiscoverView), `NFTPost` (ForYouView) [orphan]
- [ ] **ATH-094** `quality` duplicate font systems: `FontManager` (AtheneNFTApp:68) vs `FontUtility` [orphan]; only FontManager is compiled, FontUtility is dead
- [ ] **ATH-095** `quality` Utils/UIImageExtensions.swift:208-211 — failable `Image.init?(uiImage: UIImage?)` shadows the standard SwiftUI initializer [orphan]
- [ ] **ATH-096** `quality` Core/Share/ForYouView.swift:92-113 — fake in-app status bar ("Carrier", wifi, battery icons) drawn inside the view, left over from a design mock [orphan]
- [ ] **ATH-097** `quality` Core/Share/ForYouView.swift:110,183 — hardcoded 343pt frames/offsets; not responsive [orphan]
- [ ] **ATH-098** `quality` Core/Discover/NFTCardView.swift:28 — hardcoded 343×343 card frame; rest of app uses DynamicSizing [orphan]
- [ ] **ATH-099** `quality` Core/Share/WalletTransferView.swift:47-111 — hardcoded `Color.white` panels in a forced-dark-mode app; visually inconsistent with every other screen

### God files (split without behavior change)

- [ ] **ATH-100** `quality` Core/Discover/DiscoverView.swift — 857 lines: split out CategoryChip, NFTGridCard, UserCircleView, NFTImageCard, SearchView, SampleNFTData
- [ ] **ATH-101** `quality` Core/Profile/ProfileView.swift — 757 lines: split out StatView, NFTGridItemView, ShimmerView, SettingsView, NFTDetailView, PropertyView
- [ ] **ATH-102** `quality` Core/Home/HomeView.swift — 422 lines: extract NFTPostView + mock data
- [ ] **ATH-103** `quality` Services/NFTService.swift — 417 lines: extract mock factories into MockNFTData
- [ ] **ATH-104** `quality` Core/Discover/NFTCardView.swift — 421 lines incl. unrelated ScrollableNFTGrid + scroll-tracking machinery [orphan]

### Mock/network layer

- [ ] **ATH-105** `quality` Services/NFTService.swift — every public method returns `Just(...)` mocks that can never fail; add a failure-injection switch when wiring the real API
- [ ] **ATH-107** `quality` Services/NFTService.swift — the real URLSession layer (`makeRequest`/`performRequest`) is unreachable code; nothing calls it
- [ ] **ATH-109** `quality` Utils/UIImageExtensions.swift — `ImageLoadingUtility.loadImage` has no cache, timeout, or retry [orphan]

---

## In Progress

*(empty)*

---

## Done

*All fixed 2026-08-12; build verified green on iPhone 16 simulator.*

### Crash-risk
- [x] **ATH-001** `crash` UIImageExtensions nftPlaceholder CGGradient `!` → optional binding with flat-color fallback
- [x] **ATH-002** `crash` UIImageExtensions profilePlaceholder CGGradient `!` → optional binding with flat-color fallback
- [x] **ATH-003** `crash` UIKitImageView createPlaceholder CGGradient `!` → optional binding with flat-color fallback
- [x] **ATH-004** `crash` NFTService.shareNFT `URL(string:)!` → rebuilt on `URLComponents`, returns `URL?`
- [x] **ATH-005** `crash` CameraModel IUO `preview` property removed entirely — the preview layer now lives in `CameraPreview.PreviewView` (layer-backed, guaranteed type)

### Display/logic bugs
- [x] **ATH-006…ATH-011** `bug` all six `dropFirst(1).prefix(1)` sites → shared `String.avatarInitial` helper (Models/NFT.swift): strips optional "@", falls back to "?", never blank
- [x] **ATH-012** `bug` `User.initials` now splits on whitespace and filters empties; no more blank initials for double-spaced names
- [x] **ATH-013** `bug` `buildCaptionText` splits on `.whitespacesAndNewlines` — hashtags after newlines are styled
- [x] **ATH-014** `bug` share URLs built via `URLComponents` query items; special characters encode correctly
- [x] **ATH-015** `bug` ProfileView wrapped in `NavigationStack` — grid taps now reach NFTDetailView
- [x] **ATH-016** `bug` blank swipe page removed from MainTabView along with its dead `onAppear` hack; Share still opens from the center button
- [x] **ATH-017** `bug` invalid hex mock contracts in HomeView (`0xGHI789`, `0xJKL012`) corrected
- [x] **ATH-018** `bug` upload progress clamped with `min(_, 1.0)` — no more "119%"

### Security / configuration
- [x] **ATH-019** `security` NetworkConfig documented as unwired placeholder; auth token declared as Keychain-sourced `authToken` (nil until a backend exists)
- [x] **ATH-020** `security` fake `Bearer YOUR_API_TOKEN` removed — Authorization header only added when a real token exists
- [x] **ATH-022** `security` full git history (17 commits) audited for keys/secrets/passwords — clean; the `keys` branch name is historical, no credentials found

### Dead / stub interactions (all wired with real behavior)
- [x] **ATH-023** post options → Menu with Share (share sheet), Copy Link, Like
- [x] **ATH-024** comment button → "coming soon" alert instead of silent no-op
- [x] **ATH-025** post share button → real `ShareLink` with the NFT's share URL
- [x] **ATH-026** "View All" → opens full category grid sheet (`CategoryAllView`)
- [x] **ATH-027/028** Discover header chevron + filter icon → category filter Menu (with checkmarks; filter icon fills when active)
- [x] **ATH-029** profile share → `ShareLink` sharing the profile
- [x] **ATH-030** message button → "coming soon" alert
- [x] **ATH-031** more-options → Menu (Share Profile / Copy Username)
- [x] **ATH-032** grid heart → toggles favorited state with animation
- [x] **ATH-033** Buy Now → confirmation dialog → "Purchased" state (mock purchase, clearly marked)
- [x] **ATH-034** notifications Follow button → actually toggles Follow/Following
- [x] **ATH-035** "Show More Options" → reveals the 4 hidden wallet rows
- [x] **ATH-036…ATH-039** same treatment in orphaned NFTCardView/ForYouView (share Menu, comments alert, ShareLink)

### Error handling
- [x] **ATH-040** memory warning now actually clears `URLCache` via an `onReceive` publisher (no leaked observer) and logs through `os.Logger`
- [x] **ATH-041** camera setup errors surface as an alert (`CameraModel.errorMessage`); the never-displayed permission-denied alert is now shown too
- [x] **ATH-042** photo-capture errors surface to the user instead of silent return
- [x] **ATH-043** NFTService decoding errors → `os.Logger`
- [x] **ATH-044** `saveImage` logs each failure path via `os.Logger`
- [x] **ATH-045** `ImageLoadingUtility` download failures logged
- [x] **ATH-046** photo-picker failures set `errorMessage` shown in ShareView (no more `try?` swallow)

### Memory / lifecycle / concurrency
- [x] **ATH-047** leaked NotificationCenter observer replaced by SwiftUI `onReceive`
- [x] **ATH-048** upload timer cancelled in `completeUpload` (`cancellables.removeAll()`)
- [x] **ATH-049** `[weak self]` in camera `requestAccess` closure
- [x] **ATH-050** HomeView haptic generator `@State` → `let`
- [x] **ATH-051** `configureSession` starts the session off the main actor *before* publishing it; ordering coherent
- [x] **ATH-052** `CameraPreview.updateUIView` reattaches the configured session — live preview no longer stays black
- [x] **ATH-053** unused `@StateObject var nftService` removed from DiscoverView

### Missing states / validation
- [x] **ATH-058** ShareViewModel errors now name the exact missing field (image / title / description / price)
- [x] **ATH-060 (partial)** duplicate-type collision documented; orphan adoption decisions remain in Backlog as ATH-060
- [x] **ATH-065** price must parse AND be > 0
- [x] **ATH-066** description now validated before upload, matching the service contract
- [x] **ATH-067** `createNFT` rejects images over 10 MB before base64 encoding
- [x] **ATH-068** recipient address validated as `0x` + 40 hex chars, with inline hint; transfer button gated on it

### Dead code / build scripts
- [x] **ATH-082/083** unused `featuredCategoriesView` + `categorySection` deleted (~70 lines)
- [x] **ATH-084** discarded `CreateNFTRequest` construction removed
- [x] **ATH-085** 22-line commented-out service call deleted
- [x] **ATH-110** `clean_build.sh`: `set -euo pipefail`, cd-to-script-dir, explicit error on failed clean

### Found while fixing (new cards, fixed immediately)
- [x] **ATH-122** `bug` DiscoverView category chips set `selectedCategory` but nothing read it — the filter did nothing; the feed now filters by the selected category (chips, chevron menu, and filter menu all drive it)
- [x] **ATH-123** `bug` CameraModel set `alert = true` on denied permission but no alert was ever attached to the view — now presented with guidance to Settings

---

## Done — Round 2 (2026-08-12, verified by the new test suites)

### Bugs
- [x] **ATH-055** Home feed shows a "No posts yet" empty state
- [x] **ATH-056** NotificationsView rewritten to load from `NFTService.fetchNotifications()` using the `Notification` model — `timeAgo`, unread dots, Today/This Week/Earlier sections, empty state; hardcoded copy deleted
- [x] **ATH-059** `NFTService.isLoading`/`errorMessage` now drive the notifications loading state
- [x] **ATH-061** orphan `NFTItem` in NFTCardView renamed `NFTCardItem` — collision defused
- [x] **ATH-062** orphan `NFTDetailView` in NFTArtCard renamed `NFTArtCardDetailView` — collision defused
- [x] **ATH-064** Profile detail screen now receives the tapped grid item's real image instead of the nonexistent `"nft-image"` asset
- [x] **ATH-069** closed: ATH-068's validation guarantees 42-char addresses, so the `prefix(6)…suffix(4)` preview can no longer overlap
- [x] **ATH-124** `crash` **found by the new unit tests**: `searchNFTs` with an out-of-range page constructed `1960..<10`, trapping (`Range requires lowerBound <= upperBound`) before the safe subscript could clamp — guarded; regression test `testSearchPaginationOutOfRangeIsEmptyNotCrash` locks it in

### Timing / determinism
- [x] **ATH-070–074, 076** all six press-bounce resets converted from `asyncAfter` magic delays to `withAnimation { } completion: { }`
- [x] **ATH-075, 077, 078, 079** mock latencies centralized as named `MockLatency` constants (search/walletConnect/transfer/uploadSettle) — documented simulated networking, no magic numbers
- [x] **ATH-080/081** orphan NFTCardView's racing success-then-error timers replaced with a single loaded-or-error check
- [x] **ATH-106** mock data now uses bundled asset names — no more `picsum.photos`/`i.pravatar.cc` references
- [x] **ATH-108** all mock factories deterministic (index-derived); UI stable across runs, tests can assert on output; per-render `Double.random` bid in NFTImageCard fixed too

### DRY / docs
- [x] **ATH-054** `@MainActor` isolation on NFTService documented with revisit note
- [x] **ATH-088** brown avatar gradient extracted to one constant in HomeView (orphan NFTArtCard copy noted on ATH-060)
- [x] **ATH-090** `DynamicSizing`'s four identical formulas collapsed into one private `scaled()` helper
- [x] **ATH-093** both safe-subscript Array extensions consolidated in NFTService.swift; ProfileView duplicate removed

### Build / CI / assets — zero-warning build
- [x] **ATH-111** `build.swift` now genuinely syntax-checks every file via `swiftc -parse` (exits non-zero on parse failure)
- [x] **ATH-112** CI workflow renamed `ios.yml`, pinned iPhone 16 simulator destination, dropped archived xcpretty, added a test job uploading the xcresult bundle
- [x] **ATH-113** `generate_app_icons.sh` hardened with `set -euo pipefail` (source-existence check already existed — original card overstated)
- [x] **ATH-114** 4 stray unreferenced files deleted from AppIcon.appiconset
- [x] **ATH-115** referenced GIFs converted to PNG via sips, Contents.json updated, 5 unreferenced GIFs removed
- [x] **ATH-116** stray unassigned children removed from Cards + Doge imagesets

### Tests (the sandbox suite)
- [x] **ATH-117** `AtheneNFTTests` (unit) + `AtheneNFTUITests` (UI) targets added to the Xcode project with a shared scheme; `xcodebuild test` runs both
- [x] **ATH-118** NFTServiceTests — mock determinism, asset-name usage, search filtering, pagination bounds, createNFT validation matrix, share-URL encoding (13 tests)
- [x] **ATH-119** ModelTests — avatarInitial, initials, displayUsername, isNew, notification messages, safe subscripts (15 tests)
- [x] **ATH-120** ShareViewModelTests — field-by-field validation errors, upload lifecycle, progress clamp, timer cancellation (9 tests)
- [x] **ATH-121** SmokeTests (XCUITest) — launches the app in the simulator and drives all 5 tabs, wallet sheet incl. "Show More Options", search flow, like toggle (7 tests)
