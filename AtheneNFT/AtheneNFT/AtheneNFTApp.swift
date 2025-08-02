import SwiftUI
import Combine

// MARK: - Supporting Classes and Managers

/// Image loading and caching manager
class ImageLoader: ObservableObject {
    static let shared = ImageLoader()
    
    @Published var loadedImages: [String: UIImage] = [:]
    private var cache = NSCache<NSString, UIImage>()
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupCache()
    }
    
    private func setupCache() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    func preloadImages(_ imageNames: [String]) {
        for imageName in imageNames {
            loadImage(named: imageName)
        }
    }
    
    func loadImage(named imageName: String) {
        // Check cache first
        if let cachedImage = cache.object(forKey: imageName as NSString) {
            DispatchQueue.main.async {
                self.loadedImages[imageName] = cachedImage
            }
            return
        }
        
        // Generate placeholder image if not found in bundle
        DispatchQueue.global(qos: .background).async {
            let image = self.generatePlaceholderImage(for: imageName)
            
            DispatchQueue.main.async {
                self.cache.setObject(image, forKey: imageName as NSString)
                self.loadedImages[imageName] = image
            }
        }
    }
    
    private func generatePlaceholderImage(for name: String) -> UIImage {
        let size = CGSize(width: 300, height: 300)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Create gradient background
            let colors = [UIColor.systemPurple, UIColor.systemBlue, UIColor.systemTeal]
            let randomColor1 = colors.randomElement() ?? UIColor.systemPurple
            let randomColor2 = colors.randomElement() ?? UIColor.systemBlue
            
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [randomColor1.cgColor, randomColor2.cgColor] as CFArray,
                locations: [0.0, 1.0]
            )
            
            context.cgContext.drawLinearGradient(
                gradient!,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: size.width, y: size.height),
                options: []
            )
            
            // Add text overlay
            let text = name.contains("profile") ? "👤" : "🎨"
            let font = UIFont.systemFont(ofSize: 60)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.white
            ]
            
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            
            text.draw(in: textRect, withAttributes: attributes)
        }
    }
    
    func clearCache() {
        cache.removeAllObjects()
        loadedImages.removeAll()
    }
}

/// Font management for the app
class FontManager: ObservableObject {
    static let shared = FontManager()
    
    @Published var fontsLoaded = false
    
    private init() {
        loadCustomFonts()
    }
    
    private func loadCustomFonts() {
        // In a real app, you would load custom fonts here
        // For this example, we'll use system fonts
        DispatchQueue.main.async {
            self.fontsLoaded = true
        }
    }
    
    func primaryFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return .system(size: size, weight: weight, design: .default)
    }
    
    func titleFont(size: CGFloat = 20) -> Font {
        return .system(size: size, weight: .bold, design: .default)
    }
}

// MARK: - Custom View Modifiers and Extensions

extension Text {
    func nftTitleStyle() -> some View {
        self
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.white)
    }
    
    func nftSubtitleStyle() -> some View {
        self
            .font(.subheadline)
            .foregroundColor(.gray)
    }
    
    func nftCreatorStyle() -> some View {
        self
            .font(.caption)
            .foregroundColor(.white.opacity(0.8))
    }
}

// MARK: - Async Image View

struct AsyncImageView: View {
    let imageName: String
    @EnvironmentObject var imageLoader: ImageLoader
    @State private var image: UIImage?
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    )
            }
        }
        .onAppear {
            loadImage()
        }
        .onReceive(imageLoader.$loadedImages) { loadedImages in
            if let loadedImage = loadedImages[imageName] {
                self.image = loadedImage
            }
        }
    }
    
    private func loadImage() {
        imageLoader.loadImage(named: imageName)
    }
}

// MARK: - NFT Card View

struct NFTCardView: View {
    let title: String
    let creator: String
    let creatorUsername: String
    let imageName: String
    
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image
            AsyncImageView(imageName: imageName)
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .nftTitleStyle()
                    .lineLimit(1)
                
                HStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 16, height: 16)
                    
                    Text(creator)
                        .nftCreatorStyle()
                        .lineLimit(1)
                    
                    Spacer()
                }
                
                Text(creatorUsername)
                    .nftSubtitleStyle()
                    .font(.caption2)
            }
            .padding(.horizontal, 4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            withAnimation {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    isPressed = false
                }
            }
        }
    }
}

// MARK: - Main App

@main
struct AtheneNFTApp: App {
    
    @StateObject private var imageLoader = ImageLoader.shared
    @StateObject private var fontManager = FontManager.shared
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(imageLoader)
                .environmentObject(fontManager)
                .preferredColorScheme(.dark) // Ensure dark mode for NFT theme
                .onAppear {
                    setupApp()
                }
        }
    }
    
    /// Initialize app-wide configurations
    private func setupApp() {
        // Preload common images for better performance
        let commonImages = [
            "nft-image",
            "profile-image",
            "placeholder"
        ]
        imageLoader.preloadImages(commonImages)
        
        // Configure app appearance
        configureAppearance()
        
        // Setup memory management
        setupMemoryManagement()
    }
    
    /// Configure global app appearance
    private func configureAppearance() {
        // Navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = .black
        navBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 18, weight: .medium)
        ]
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        
        // Tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .black
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    /// Setup memory management observers
    private func setupMemoryManagement() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { _ in
            imageLoader.clearCache()
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var imageLoader: ImageLoader
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NFTGridView()
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("Gallery")
                }
                .tag(0)
            
            TrendingView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Trending")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
                .tag(2)
        }
        .accentColor(.white)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

// MARK: - NFT Grid View

struct NFTGridView: View {
    @EnvironmentObject var imageLoader: ImageLoader
    @State private var nftItems: [NFTItem] = []
    @State private var isLoading = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(nftItems) { item in
                        NFTCardView(
                            title: item.title,
                            creator: item.creator,
                            creatorUsername: item.creatorUsername,
                            imageName: item.imageName
                        )
                        .onAppear {
                            // Load more items when reaching the end
                            if item == nftItems.last {
                                loadMoreItems()
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                
                if isLoading {
                    ProgressView("Loading more NFTs...")
                        .foregroundColor(.white)
                        .padding()
                }
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .navigationTitle("NFT Gallery")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await refreshItems()
            }
        }
        .onAppear {
            if nftItems.isEmpty {
                loadInitialItems()
            }
        }
    }
    
    private func loadInitialItems() {
        nftItems = generateSampleNFTItems(count: 10)
    }
    
    private func loadMoreItems() {
        guard !isLoading else { return }
        
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let newItems = generateSampleNFTItems(count: 6, startIndex: nftItems.count)
            nftItems.append(contentsOf: newItems)
            isLoading = false
        }
    }
    
    private func refreshItems() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        nftItems = generateSampleNFTItems(count: 10)
    }
}

// MARK: - Trending View

struct TrendingView: View {
    @State private var trendingItems: [NFTItem] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Featured section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Featured")
                            .nftTitleStyle()
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 16) {
                                ForEach(trendingItems.prefix(5)) { item in
                                    NFTCardView(
                                        title: item.title,
                                        creator: item.creator,
                                        creatorUsername: item.creatorUsername,
                                        imageName: item.imageName
                                    )
                                    .frame(width: 300)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Categories section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Categories")
                            .nftTitleStyle()
                            .padding(.horizontal)
                        
                        CategoryScrollView()
                    }
                }
                .padding(.vertical)
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .navigationTitle("Trending")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            if trendingItems.isEmpty {
                trendingItems = generateSampleNFTItems(count: 8)
            }
        }
    }
}

// MARK: - Profile View

struct ProfileView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile header
                    VStack(spacing: 16) {
                        AsyncImageView(imageName: "profile-image")
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.2), lineWidth: 2)
                            )
                        
                        VStack(spacing: 8) {
                            Text("@username")
                                .nftTitleStyle()
                            
                            Text("NFT Collector & Creator")
                                .nftSubtitleStyle()
                        }
                    }
                    .padding(.top, 20)
                    
                    // Stats section
                    HStack(spacing: 40) {
                        StatView(title: "Owned", value: "42")
                        StatView(title: "Created", value: "12")
                        StatView(title: "Followers", value: "1.2K")
                    }
                    .padding(.vertical, 20)
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal)
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Helper Views

struct StatView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .nftSubtitleStyle()
        }
    }
}

struct CategoryScrollView: View {
    let categories = ["Art", "Gaming", "Music", "Sports", "Photography"]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    CategoryCard(name: category)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct CategoryCard: View {
    let name: String
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(
                    colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 80, height: 80)
                .overlay(
                    Text(String(name.prefix(1)))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            Text(name)
                .nftCreatorStyle()
        }
    }
}

// MARK: - Data Models

struct NFTItem: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let creator: String
    let creatorUsername: String
    let imageName: String
    
    static func == (lhs: NFTItem, rhs: NFTItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Sample Data Generation

func generateSampleNFTItems(count: Int, startIndex: Int = 0) -> [NFTItem] {
    let sampleTitles = [
        "Cryptopunk Heritage", "Digital Dreams", "Neon Genesis", "Pixel Paradise",
        "Cyber Samurai", "Virtual Visions", "Meta Masterpiece", "Blockchain Beauty",
        "Token Treasure", "Digital Dynasty", "NFT Noir", "Pixel Poetry",
        "Crypto Canvas", "Virtual Velocity", "Digital Dimension"
    ]
    
    let sampleCreators = [
        "@ArtMaster", "@CryptoKing", "@PixelPro", "@NFTNinja",
        "@DigitalDreamer", "@BlockchainBoss", "@MetaArtist", "@CyberCreator"
    ]
    
    let sampleUsernames = [
        "@john_doe", "@jane_smith", "@crypto_lover", "@art_enthusiast",
        "@pixel_painter", "@digital_wizard", "@nft_collector", "@meta_master"
    ]
    
    return (0..<count).map { index in
        let adjustedIndex = startIndex + index
        return NFTItem(
            title: sampleTitles[adjustedIndex % sampleTitles.count],
            creator: sampleCreators[adjustedIndex % sampleCreators.count],
            creatorUsername: sampleUsernames[adjustedIndex % sampleUsernames.count],
            imageName: "Image@\(Int.random(in: 1...25))"
        )
    }
}