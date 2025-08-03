import SwiftUI
import UIKit

// MARK: - Models
struct NFTItemData: Identifiable {
    let id: UUID
    let title: String
    let creator: User
    let username: String
    let imageName: String
    let category: NFTCategory
    
    init(title: String, creator: User, username: String, imageName: String, category: NFTCategory = .new) {
        self.id = UUID()
        self.title = title
        self.creator = creator
        self.username = username
        self.imageName = imageName
        self.category = category
    }
}

enum NFTCategory: String, CaseIterable {
    case new = "New"
    case trending = "Trending"
    case doge = "Doge"
    case cards = "Cards"
    case gifs = "Gifs"
    case celebrities = "Celebrities"
    
    var displayName: String {
        switch self {
        case .doge:
            return "#Doge"
        case .cards:
            return "#Cards"
        case .gifs:
            return "#Gifs"
        case .celebrities:
            return "#Celebrities"
        default:
            return rawValue
        }
    }
}

// MARK: - Main View
struct DiscoverView: View {
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var selectedCategory: NFTCategory? = nil
    @State private var showSearchView = false
    @StateObject private var nftService = NFTService.shared
    
    private let haptic = UIImpactFeedbackGenerator(style: .light)
    private let sampleData = SampleNFTData()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.black.ignoresSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Fixed Header
                    headerView(geometry: geometry)
                    
                    // Fixed Search Bar
                    searchBarView(geometry: geometry)
                    
                    // SCROLLABLE CONTENT - Following SwiftUI best practices
                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(spacing: 24) {
                            // Featured Categories Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Featured Categories")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(NFTCategory.allCases, id: \.self) { category in
                                            CategoryChip(
                                                category: category,
                                                isSelected: selectedCategory == category
                                            ) {
                                                selectedCategory = selectedCategory == category ? nil : category
                                                haptic.impactOccurred()
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            // NFT Grid Content - Multiple sections to ensure scrollable height
                            ForEach(NFTCategory.allCases, id: \.self) { category in
                                VStack(alignment: .leading, spacing: 16) {
                                    // Section Header
                                    HStack {
                                        Text(category.displayName)
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Button("View All") {
                                            // Action
                                        }
                                        .foregroundColor(.blue)
                                        .font(.caption)
                                    }
                                    .padding(.horizontal)
                                    
                                    // NFT Grid for this category
                                    LazyVGrid(columns: [
                                        GridItem(.flexible(), spacing: 16),
                                        GridItem(.flexible(), spacing: 16)
                                    ], spacing: 16) {
                                        ForEach(sampleData.nfts(for: category).prefix(6), id: \.id) { item in
                                            NFTGridCard(item: item)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            // Additional scrollable content to guarantee scroll
                            VStack(spacing: 20) {
                                Text("More NFT Collections")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                ForEach(0..<10, id: \.self) { index in
                                    HStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 60, height: 60)
                                        
                                        VStack(alignment: .leading) {
                                            Text("Collection \(index + 1)")
                                                .foregroundColor(.white)
                                                .font(.headline)
                                            Text("Trending NFT Collection")
                                                .foregroundColor(.gray)
                                                .font(.caption)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(12)
                                }
                            }
                            .padding()
                            
                            // Bottom padding for tab bar - CRITICAL for scrolling
                            Spacer(minLength: 120)
                        }
                        .padding(.top, 8)
                    }
                    // Remove any frame constraints that could prevent scrolling
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            haptic.prepare()
        }
        .sheet(isPresented: $showSearchView) {
            SearchView(searchText: $searchText)
        }
    }
    
    // MARK: - View Components
    private func headerView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            Color.black
                .frame(height: geometry.safeAreaInsets.top)
            
            HStack {
                Text("Discover")
                    .font(Font.custom("Noto Sans", size: DynamicSizing.fontSize(base: 32, geometry: geometry)).weight(.bold))
                    .foregroundColor(.white)
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        // Toggle category filter or show options
                    }
                    haptic.impactOccurred()
                }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: DynamicSizing.size(base: 18, geometry: geometry), weight: .bold))
                        .foregroundColor(.white)
                        .padding(.leading, 4)
                }
                
                Spacer()
                
                // Filter button
                Button(action: {
                    haptic.impactOccurred()
                }) {
                    Image(systemName: "line.horizontal.3.decrease.circle")
                        .font(.system(size: DynamicSizing.size(base: 24, geometry: geometry)))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, DynamicSizing.padding(base: 20, geometry: geometry))
            .padding(.vertical, 12)
        }
        .background(Color.black)
    }
    
    private func searchBarView(geometry: GeometryProxy) -> some View {
        Button(action: {
            showSearchView = true
            haptic.impactOccurred()
        }) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.6))
                    .font(.system(size: DynamicSizing.size(base: 20, geometry: geometry)))
                    .padding(.leading, DynamicSizing.padding(base: 14, geometry: geometry))
                
                Text("Search NFTs, collections, artists...")
                    .font(Font.custom("Noto Sans", size: DynamicSizing.fontSize(base: 17, geometry: geometry)))
                    .foregroundColor(Color.white.opacity(0.60))
                
                Spacer()
            }
            .frame(height: DynamicSizing.size(base: 48, geometry: geometry))
            .background(Color(white: 0.15))
            .cornerRadius(12)
        }
        .padding(.horizontal, DynamicSizing.padding(base: 20, geometry: geometry))
        .padding(.bottom, DynamicSizing.padding(base: 24, geometry: geometry))
        .scaleEffect(isSearching ? 0.98 : 1.0)
        .animation(.spring(response: 0.3), value: isSearching)
    }
    
    private func featuredCategoriesView(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Featured Categories")
                .font(Font.custom("Noto Sans", size: 24).weight(.bold))
                .foregroundColor(.white)
                .padding(.horizontal, DynamicSizing.padding(base: 20, geometry: geometry))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(NFTCategory.allCases, id: \.self) { category in
                        CategoryChip(category: category, isSelected: selectedCategory == category) {
                            selectedCategory = selectedCategory == category ? nil : category
                            haptic.impactOccurred()
                        }
                    }
                }
                .padding(.horizontal, DynamicSizing.padding(base: 20, geometry: geometry))
            }
        }
    }
    
    private func categorySection(category: NFTCategory, geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Section header
            HStack {
                Text(category.displayName)
                    .font(Font.custom("Noto Sans", size: 24).weight(.bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("See All") {
                    haptic.impactOccurred()
                }
                .font(Font.custom("Noto Sans", size: 14).weight(.medium))
                .foregroundColor(.blue)
            }
            .padding(.horizontal, DynamicSizing.padding(base: 20, geometry: geometry))
            
            // User avatars row
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(sampleData.getItems(for: category)) { item in
                        UserCircleView(username: item.username, geometry: geometry)
                    }
                }
                .padding(.horizontal, DynamicSizing.padding(base: 20, geometry: geometry))
            }
            
            // NFT Cards in grid
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 12
            ) {
                ForEach(sampleData.getItems(for: category)) { item in
                    NFTImageCard(
                        item: item,
                        category: category,
                        geometry: geometry,
                        onTap: {
                            haptic.impactOccurred()
                        }
                    )
                }
            }
            .padding(.horizontal, DynamicSizing.padding(base: 20, geometry: geometry))
        }
    }
}

// MARK: - Category Chip Component
struct CategoryChip: View {
    let category: NFTCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category.displayName)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ? Color.blue : Color.gray.opacity(0.2)
                )
                .foregroundColor(isSelected ? .white : .gray)
                .cornerRadius(16)
        }
    }
}

// MARK: - NFT Grid Card Component
struct NFTGridCard: View {
    let item: NFTItemData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // NFT Image
            FallbackAsyncImage(
                imageName: item.imageName,
                size: CGSize(width: 160, height: 160),
                contentMode: .fill,
                cornerRadius: 12
            )
            
            // NFT Info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(item.creator.username)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - User Circle View Component
struct UserCircleView: View {
    let username: String
    let geometry: GeometryProxy
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.2)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.2)) {
                    isPressed = false
                }
            }
        }) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.purple, Color.blue, Color.cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    
                    Circle()
                        .fill(Color.black)
                        .frame(width: 52, height: 52)
                    
                    Text(String(username.dropFirst(1).prefix(1)).capitalized)
                        .font(Font.custom("Noto Sans", size: 20).weight(.semibold))
                        .foregroundColor(.white)
                }
                
                Text(username)
                    .font(Font.custom("Noto Sans", size: 11))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .frame(width: 70)
            }
        }
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .animation(.spring(response: 0.2), value: isPressed)
    }
}

// MARK: - NFT Image Card Component
struct NFTImageCard: View {
    let item: NFTItemData
    let category: NFTCategory
    let geometry: GeometryProxy
    let onTap: () -> Void
    
    @State private var isPressed = false
    @State private var isLiked = false
    @State private var likeCount = Int.random(in: 12...156)
    
    private let haptic = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.2)) {
                isPressed = true
            }
            onTap()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.2)) {
                    isPressed = false
                }
            }
        }) {
            VStack(alignment: .leading, spacing: 0) {
                // NFT Image with overlay
                ZStack {
                    Rectangle()
                        .fill(Color(white: 0.15))
                        .aspectRatio(1, contentMode: .fit)
                    
                    // Use the new FallbackAsyncImage for better image handling
                    FallbackAsyncImage(
                        imageName: item.imageName,
                        contentMode: .fill,
                        cornerRadius: 0
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    
                    // Overlay with like button
                    VStack {
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.3)) {
                                    isLiked.toggle()
                                    likeCount += isLiked ? 1 : -1
                                }
                                haptic.impactOccurred()
                            }) {
                                Image(systemName: isLiked ? "heart.fill" : "heart")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(isLiked ? .red : .white)
                                    .background(
                                        Circle()
                                            .fill(Color.black.opacity(0.5))
                                            .frame(width: 32, height: 32)
                                    )
                            }
                        }
                        .padding(8)
                        
                        Spacer()
                        
                        // Price overlay
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Current bid")
                                    .font(Font.custom("Noto Sans", size: 10))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Text("\(String(format: "%.2f", Double.random(in: 0.1...5.0))) ETH")
                                    .font(Font.custom("Noto Sans", size: 12).weight(.semibold))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.black.opacity(0.7))
                            )
                            
                            Spacer()
                        }
                        .padding(.horizontal, 8)
                        .padding(.bottom, 8)
                    }
                }
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(12, corners: [.topLeft, .topRight])
                
                // Title and creator info
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.title)
                        .font(Font.custom("Noto Sans", size: 14).weight(.medium))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // Creator and stats info
                    HStack(spacing: 8) {
                        // Creator avatar
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange, Color.pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 20, height: 20)
                            .overlay(
                                Text(String(item.creator.username.dropFirst(1).prefix(1)).capitalized)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            )
                        
                        VStack(alignment: .leading, spacing: 1) {
                            Text(item.creator.username)
                                .font(Font.custom("Noto Sans", size: 11))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(.red)
                                
                                Text("\(likeCount)")
                                    .font(Font.custom("Noto Sans", size: 10))
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
            }
        }
        .background(Color(white: 0.12))
        .cornerRadius(12)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.2), value: isPressed)
        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Search View
struct SearchView: View {
    @Binding var searchText: String
    @Environment(\.dismiss) private var dismiss
    @State private var searchResults: [NFTItemData] = []
    @State private var isSearching = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search NFTs, collections, artists...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            performSearch()
                        }
                    
                    if !searchText.isEmpty {
                        Button("Clear") {
                            searchText = ""
                            searchResults = []
                        }
                        .font(.caption)
                    }
                }
                .padding()
                
                // Search results
                if isSearching {
                    ProgressView("Searching...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if searchResults.isEmpty && !searchText.isEmpty {
                    VStack {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        
                        Text("No results found")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Text("Try different keywords")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(searchResults) { item in
                        HStack {
                            FallbackAsyncImage(
                                imageName: item.imageName,
                                size: CGSize(width: 60, height: 60),
                                contentMode: .fill,
                                cornerRadius: 8
                            )
                            
                            VStack(alignment: .leading) {
                                Text(item.title)
                                    .font(.headline)
                                
                                Text(item.creator.username)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        isSearching = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let sampleData = SampleNFTData()
            searchResults = sampleData.getAllItems().filter { item in
                item.title.localizedCaseInsensitiveContains(searchText) ||
                item.creator.username.localizedCaseInsensitiveContains(searchText)
            }
            isSearching = false
        }
    }
}

// MARK: - Sample Data Provider
class SampleNFTData {
    private let categories: [NFTCategory: [NFTItemData]]
    
    init() {
        // Initialize sample data for each category
        let newItems = [
            NFTItemData(
                title: "New Digital Art",
                creator: User(id: "c1", username: "@newartist", displayName: "New Artist", profileImage: "Profile"),
                username: "@theaibender",
                imageName: "New",
                category: .new
            ),
            NFTItemData(
                title: "Fresh Collection",
                creator: User(id: "c2", username: "@freshcreator", displayName: "Fresh Creator", profileImage: "Profile"),
                username: "@theabstractor",
                imageName: "New",
                category: .new
            ),
            NFTItemData(
                title: "Latest Drop",
                creator: User(id: "c3", username: "@latestdrop", displayName: "Latest Drop", profileImage: "Profile"),
                username: "@haykronmiyc",
                imageName: "New",
                category: .new
            ),
            NFTItemData(
                title: "Newest Mint",
                creator: User(id: "c4", username: "@newestmint", displayName: "Newest Mint", profileImage: "Profile"),
                username: "@jonboyeq43",
                imageName: "New",
                category: .new
            )
        ]
        
        let trendingItems = [
            NFTItemData(
                title: "The Hazy Maze",
                creator: User(id: "t1", username: "@jonahlipps", displayName: "Jonah Lipps", profileImage: "Profile"),
                username: "@jonahlipps",
                imageName: "Trending",
                category: .trending
            ),
            NFTItemData(
                title: "Splash",
                creator: User(id: "t2", username: "@aalvarez", displayName: "A Alvarez", profileImage: "Profile"),
                username: "@aalvarez",
                imageName: "Trending",
                category: .trending
            ),
            NFTItemData(
                title: "Abstract Thoughts",
                creator: User(id: "t3", username: "@abstract_mind", displayName: "Abstract Mind", profileImage: "Profile"),
                username: "@abstract_mind",
                imageName: "Trending",
                category: .trending
            )
        ]
        
        let dogeItems = [
            NFTItemData(
                title: "Doge King",
                creator: User(id: "d1", username: "@dogemaster", displayName: "Doge Master", profileImage: "Profile"),
                username: "@dogemaster",
                imageName: "Doge",
                category: .doge
            ),
            NFTItemData(
                title: "Space Doge",
                creator: User(id: "d2", username: "@spacedoge", displayName: "Space Doge", profileImage: "Profile"),
                username: "@spacedoge",
                imageName: "Doge",
                category: .doge
            )
        ]
        
        let cardItems = [
            NFTItemData(
                title: "Prometheus",
                creator: User(id: "c1", username: "@royalcards", displayName: "Royal Cards", profileImage: "Profile"),
                username: "@jenna453",
                imageName: "Cards",
                category: .cards
            ),
            NFTItemData(
                title: "The Vitalik Card",
                creator: User(id: "c2", username: "@cardmaster", displayName: "Card Master", profileImage: "Profile"),
                username: "@lisart",
                imageName: "Cards",
                category: .cards
            )
        ]
        
        let gifItems = [
            NFTItemData(
                title: "Confused Picasso",
                creator: User(id: "g1", username: "@cryptogrin", displayName: "Crypto Grin", profileImage: "Profile"),
                username: "@cryptoori",
                imageName: "Gifs",
                category: .gifs
            ),
            NFTItemData(
                title: "Kitty Gif",
                creator: User(id: "g2", username: "@mrrerb", displayName: "Mr. Rerb", profileImage: "Profile"),
                username: "@theabstractor",
                imageName: "Gifs",
                category: .gifs
            )
        ]
        
        let celebrityItems = [
            NFTItemData(
                title: "Logan Paul Card",
                creator: User(id: "cel1", username: "@cryptogrin3", displayName: "Crypto Grin 3", profileImage: "Profile"),
                username: "@cryptogrin33",
                imageName: "Celebrities",
                category: .celebrities
            ),
            NFTItemData(
                title: "Dicaprio Meme",
                creator: User(id: "cel3", username: "@instamiyu", displayName: "Instamiyu", profileImage: "Profile"),
                username: "@instamiyu",
                imageName: "Celebrities",
                category: .celebrities
            )
        ]
        
        self.categories = [
            .new: newItems,
            .trending: trendingItems,
            .doge: dogeItems,
            .cards: cardItems,
            .gifs: gifItems,
            .celebrities: celebrityItems
        ]
    }
    
    func getItems(for category: NFTCategory) -> [NFTItemData] {
        return categories[category] ?? []
    }
    
    func getAllItems() -> [NFTItemData] {
        return categories.values.flatMap { $0 }
    }
    
    func nfts(for category: NFTCategory) -> [NFTItemData] {
        return categories[category] ?? []
    }
}

// MARK: - View Extensions
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}