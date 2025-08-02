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

// Helper struct to make strings identifiable
struct StringItem: Identifiable {
    let id = UUID()
    let value: String
}

// MARK: - Main View
struct DiscoverView: View {
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var selectedCategory: NFTCategory? = nil
    @State private var showSearchView = false
    @StateObject private var nftService = NFTService.shared
    
    private let haptic = UIImpactFeedbackGenerator(style: .light)
    
    // Sample data organized by category
    private let sampleData = SampleNFTData()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background color
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with safe area
                    headerView(geometry: geometry)
                    
                    // Search bar
                    searchBarView(geometry: geometry)
                    
                    // Content
                    contentScrollView(geometry: geometry)
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
                    .font(Font.custom("Noto Sans", size: dynamicFontSize(base: 32, geometry: geometry)).weight(.bold))
                    .foregroundColor(.white)
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        // Toggle category filter or show options
                    }
                    haptic.impactOccurred()
                }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: dynamicSize(base: 18, geometry: geometry), weight: .bold))
                        .foregroundColor(.white)
                        .padding(.leading, 4)
                }
                
                Spacer()
                
                // Filter button
                Button(action: {
                    haptic.impactOccurred()
                }) {
                    Image(systemName: "line.horizontal.3.decrease.circle")
                        .font(.system(size: dynamicSize(base: 24, geometry: geometry)))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, dynamicPadding(base: 20, geometry: geometry))
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
                    .font(.system(size: dynamicSize(base: 20, geometry: geometry)))
                    .padding(.leading, dynamicPadding(base: 14, geometry: geometry))
                
                Text("Search NFTs, collections, artists...")
                    .font(Font.custom("Noto Sans", size: dynamicFontSize(base: 17, geometry: geometry)))
                    .foregroundColor(Color.white.opacity(0.60))
                
                Spacer()
            }
            .frame(height: dynamicSize(base: 48, geometry: geometry))
            .background(Color(white: 0.15))
            .cornerRadius(12)
        }
        .padding(.horizontal, dynamicPadding(base: 20, geometry: geometry))
        .padding(.bottom, dynamicPadding(base: 24, geometry: geometry))
        .scaleEffect(isSearching ? 0.98 : 1.0)
        .animation(.spring(response: 0.3), value: isSearching)
    }
    
    private func contentScrollView(geometry: GeometryProxy) -> some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 32) {
                // Featured Categories
                featuredCategoriesView(geometry: geometry)
                
                // Category Sections
                ForEach(NFTCategory.allCases, id: \.self) { category in
                    categorySection(category: category, geometry: geometry)
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 100) // Extra space for tab bar
        }
    }
    
    private func featuredCategoriesView(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Featured Categories")
                .font(Font.custom("Noto Sans", size: 24).weight(.bold))
                .foregroundColor(.white)
                .padding(.horizontal, dynamicPadding(base: 20, geometry: geometry))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(NFTCategory.allCases, id: \.self) { category in
                        CategoryChip(category: category, isSelected: selectedCategory == category) {
                            selectedCategory = selectedCategory == category ? nil : category
                            haptic.impactOccurred()
                        }
                    }
                }
                .padding(.horizontal, dynamicPadding(base: 20, geometry: geometry))
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
            .padding(.horizontal, dynamicPadding(base: 20, geometry: geometry))
            
            // User avatars row
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(sampleData.getItems(for: category)) { item in
                        UserCircleView(username: item.username, geometry: geometry)
                    }
                }
                .padding(.horizontal, dynamicPadding(base: 20, geometry: geometry))
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
                            // Handle NFT card tap
                        }
                    )
                }
            }
            .padding(.horizontal, dynamicPadding(base: 20, geometry: geometry))
        }
    }
    
    // MARK: - Dynamic Sizing Helpers
    private func dynamicSize(base: CGFloat, geometry: GeometryProxy) -> CGFloat {
        let screenWidth = geometry.size.width
        let scaleFactor = min(screenWidth / 390, 1.3)
        return base * scaleFactor
    }
    
    private func dynamicFontSize(base: CGFloat, geometry: GeometryProxy) -> CGFloat {
        let screenWidth = geometry.size.width
        let scaleFactor = min(screenWidth / 390, 1.3)
        return base * scaleFactor
    }
    
    private func dynamicPadding(base: CGFloat, geometry: GeometryProxy) -> CGFloat {
        let screenWidth = geometry.size.width
        let scaleFactor = min(screenWidth / 390, 1.3)
        return base * scaleFactor
    }
}

// MARK: - Category Chip Component
struct CategoryChip: View {
    let category: NFTCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(category.displayName)
                .font(Font.custom("Noto Sans", size: 14).weight(.medium))
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.white : Color.white.opacity(0.1))
                )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
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
                    
                    // Image loading with proper fallback
                    AsyncImage(url: URL(string: "https://picsum.photos/300/300?random=\(item.id.hashValue)")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        VStack {
                            Image(systemName: "photo.artframe")
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.6))
                            
                            Text(item.title)
                                .font(Font.custom("Noto Sans", size: 12))
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 8)
                                .padding(.top, 4)
                        }
                    }
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
                            AsyncImage(url: URL(string: "https://picsum.photos/60/60?random=\(item.id.hashValue)")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                            }
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            
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
        
        // Simulate search delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Mock search results
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
                title: "Dogepunk x Cybertruck",
                creator: User(id: "c1", username: "@dogepunks", displayName: "DogePunks", profileImage: "profile-1"),
                username: "@theaibender",
                imageName: "Image@18.png",
                category: .new
            ),
            NFTItemData(
                title: "Dogepunk x Hotdog",
                creator: User(id: "c2", username: "@dogepunks", displayName: "DogePunks", profileImage: "profile-2"),
                username: "@theabstractor",
                imageName: "Image@17.png",
                category: .new
            ),
            NFTItemData(
                title: "Dogepunk x Aquaking",
                creator: User(id: "c3", username: "@dogepunks", displayName: "DogePunks", profileImage: "profile-3"),
                username: "@haykronmiyc",
                imageName: "Image@16.png",
                category: .new
            ),
            NFTItemData(
                title: "Dogepunk x Socialite",
                creator: User(id: "c4", username: "@dogepunks", displayName: "DogePunks", profileImage: "profile-4"),
                username: "@jonboyeq43",
                imageName: "Image@15.png",
                category: .new
            )
        ]
        
        let trendingItems = [
            NFTItemData(
                title: "The Hazy Maze",
                creator: User(id: "t1", username: "@jonahlipps", displayName: "Jonah Lipps", profileImage: "profile-3"),
                username: "@jonahlipps",
                imageName: "Trending",
                category: .trending
            ),
            NFTItemData(
                title: "Splash",
                creator: User(id: "t2", username: "@aalvarez", displayName: "A Alvarez", profileImage: "profile-4"),
                username: "@aalvarez",
                imageName: "Trending",
                category: .trending
            ),
            NFTItemData(
                title: "Abstract Thoughts",
                creator: User(id: "t3", username: "@abstract_mind", displayName: "Abstract Mind", profileImage: "profile-9"),
                username: "@abstract_mind",
                imageName: "Trending",
                category: .trending
            ),
            NFTItemData(
                title: "Future City",
                creator: User(id: "t4", username: "@futurist", displayName: "Futurist", profileImage: "profile-10"),
                username: "@futurist",
                imageName: "Trending",
                category: .trending
            )
        ]
        
        let dogeItems = [
            NFTItemData(
                title: "Doge King",
                creator: User(id: "d1", username: "@dogemaster", displayName: "Doge Master", profileImage: "profile-doge1"),
                username: "@dogemaster",
                imageName: "Image@15.png",
                category: .doge
            ),
            NFTItemData(
                title: "Space Doge",
                creator: User(id: "d2", username: "@spacedoge", displayName: "Space Doge", profileImage: "profile-doge2"),
                username: "@spacedoge",
                imageName: "Image@16.png",
                category: .doge
            ),
            NFTItemData(
                title: "Cyber Doge",
                creator: User(id: "d3", username: "@cyberdoge", displayName: "Cyber Doge", profileImage: "profile-doge3"),
                username: "@cyberdoge",
                imageName: "Image@17.png",
                category: .doge
            ),
            NFTItemData(
                title: "Golden Doge",
                creator: User(id: "d4", username: "@goldendoge", displayName: "Golden Doge", profileImage: "profile-doge4"),
                username: "@goldendoge",
                imageName: "Image@18.png",
                category: .doge
            )
        ]
        
        let cardItems = [
            NFTItemData(
                title: "Prometheus",
                creator: User(id: "c1", username: "@royalcards", displayName: "Royal Cards", profileImage: "profile-cards"),
                username: "@jenna453",
                imageName: "Cards",
                category: .cards
            ),
            NFTItemData(
                title: "The Vitalik Card",
                creator: User(id: "c2", username: "@dogepunks", displayName: "DogePunks", profileImage: "profile-cards"),
                username: "@lisart",
                imageName: "Cards",
                category: .cards
            ),
            NFTItemData(
                title: "Neymar's Card",
                creator: User(id: "c3", username: "@anone43", displayName: "Anone", profileImage: "profile-cards"),
                username: "@liang2000",
                imageName: "Cards",
                category: .cards
            ),
            NFTItemData(
                title: "Adelaide",
                creator: User(id: "c4", username: "@royalcards", displayName: "Royal Cards", profileImage: "profile-cards"),
                username: "@henrythecollector",
                imageName: "Cards",
                category: .cards
            )
        ]
        
        let gifItems = [
            NFTItemData(
                title: "Confused Picasso",
                creator: User(id: "g1", username: "@cryptogrin", displayName: "Crypto Grin", profileImage: "profile-gif"),
                username: "@cryptoori",
                imageName: "Gifs",
                category: .gifs
            ),
            NFTItemData(
                title: "Kitty Gif",
                creator: User(id: "g2", username: "@mrrerb", displayName: "Mr. Rerb", profileImage: "profile-gif"),
                username: "@theabstractor",
                imageName: "Gifs",
                category: .gifs
            ),
            NFTItemData(
                title: "CyberBoy",
                creator: User(id: "g3", username: "@cryptogrin", displayName: "Crypto Grin", profileImage: "profile-gif"),
                username: "@joysxcards",
                imageName: "Gifs",
                category: .gifs
            ),
            NFTItemData(
                title: "Melt",
                creator: User(id: "g4", username: "@connect3", displayName: "Connect3", profileImage: "profile-gif"),
                username: "@annie43",
                imageName: "Gifs",
                category: .gifs
            )
        ]
        
        let celebrityItems = [
            NFTItemData(
                title: "Logan Paul Card",
                creator: User(id: "cel1", username: "@cryptogrin3", displayName: "Crypto Grin 3", profileImage: "profile-celebrity"),
                username: "@cryptogrin33",
                imageName: "Celebrities",
                category: .celebrities
            ),
            NFTItemData(
                title: "Ugly Weekend Meme",
                creator: User(id: "cel2", username: "@instamiyu", displayName: "Instamiyu", profileImage: "profile-celebrity"),
                username: "@james45",
                imageName: "Celebrities",
                category: .celebrities
            ),
            NFTItemData(
                title: "Dicaprio Meme",
                creator: User(id: "cel3", username: "@instamiyu", displayName: "Instamiyu", profileImage: "profile-celebrity"),
                username: "@instamiyu",
                imageName: "Celebrities",
                category: .celebrities
            ),
            NFTItemData(
                title: "Lebron Card",
                creator: User(id: "cel4", username: "@cryptomill", displayName: "Crypto Mill", profileImage: "profile-celebrity"),
                username: "@kerrypoet",
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

// MARK: - Preview
struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView()
            .preferredColorScheme(.dark)
    }
}