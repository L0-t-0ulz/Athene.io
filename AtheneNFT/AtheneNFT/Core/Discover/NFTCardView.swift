import SwiftUI
import Combine

/// Enhanced NFT Card View with modern design and smooth interactions
struct NFTCardView: View {
    let title: String
    let creator: String
    let creatorUsername: String
    let imageName: String
    
    @State private var isImageLoaded = false
    @State private var imageLoadError = false
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Card container with enhanced styling
            ZStack {
                cardBackground
                
                VStack(spacing: 0) {
                    headerSection
                    mainImageSection
                    footerSection
                }
            }
        }
        .frame(width: 343, height: 343)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .shadow(
            color: .black.opacity(isHovered ? 0.4 : 0.2),
            radius: isHovered ? 12 : 6,
            x: 0,
            y: isHovered ? 8 : 4
        )
    }
    
    // MARK: - Card Sections
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                LinearGradient(
                    colors: [
                        Color.black,
                        Color(red: 0.05, green: 0.05, blue: 0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color(red: 0.90, green: 0.91, blue: 0.92).opacity(0.3),
                                Color.clear,
                                Color(red: 0.90, green: 0.91, blue: 0.92).opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
    }
    
    private var headerSection: some View {
        HStack(spacing: 8) {
            // Creator profile image
            AsyncImageView(
                imageName: "profile-image",
                placeholder: Image(systemName: "person.circle.fill")
            )
            .frame(width: 36, height: 36)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.white.opacity(0.3), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            
            // Username
            VStack(alignment: .leading, spacing: 2) {
                Text(creatorUsername)
                    .nftUsernameStyle()
                    .lineLimit(1)
                
                Text("Creator")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            // Options menu
            Button(action: {}) {
                Image(systemName: "ellipsis")
                    .foregroundColor(.white.opacity(0.7))
                    .font(.system(size: 16, weight: .medium))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .frame(height: 60)
    }
    
    private var mainImageSection: some View {
        ZStack {
            // Image container with loading states
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.1, green: 0.1, blue: 0.15))
                .frame(width: 311, height: 200)
                .overlay(
                    Group {
                        if imageLoadError {
                            // Error state
                            VStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.title2)
                                    .foregroundColor(.red.opacity(0.7))
                                
                                Text("Failed to load")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        } else {
                            // Image or loading state
                            AsyncImageView(
                                imageName: imageName,
                                placeholder: loadingPlaceholder
                            )
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 311, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .onAppear {
                                checkImageLoad()
                            }
                        }
                    }
                )
                .overlay(
                    // Shimmer effect for loading
                    isImageLoaded ? nil : shimmerOverlay
                )
        }
        .animation(.easeInOut(duration: 0.3), value: isImageLoaded)
    }
    
    private var loadingPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.2, green: 0.2, blue: 0.25),
                            Color(red: 0.15, green: 0.15, blue: 0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 8) {
                Image(systemName: "photo.artframe")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.3))
                
                Text("Loading...")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
        }
    }
    
    private var shimmerOverlay: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.white.opacity(0.1),
                        Color.clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .offset(x: isImageLoaded ? 400 : -400)
            .animation(
                Animation.linear(duration: 1.5)
                    .repeatForever(autoreverses: false),
                value: isImageLoaded
            )
    }
    
    private var footerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // NFT Title with better typography
            HStack {
                Text(title)
                    .font(.custom("Noto Sans", size: 16, relativeTo: .headline))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            
            // Creator information with enhanced design
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Created by")
                        .font(.custom("Noto Sans", size: 11))
                        .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                    
                    Text(creator)
                        .font(.custom("Noto Sans", size: 13))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Creator mini avatar
                AsyncImageView(
                    imageName: "profile-image",
                    placeholder: Image(systemName: "person.circle")
                )
                .frame(width: 28, height: 28)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Helper Methods
    
    private func checkImageLoad() {
        // Simulate image loading check
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                isImageLoaded = true
            }
        }
        
        // Check for actual image load error
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if UIImage(named: imageName) == nil {
                imageLoadError = true
            }
        }
    }
}

// MARK: - Simple AsyncImageView
struct AsyncImageView: View {
    let imageName: String
    let placeholder: Image?
    
    var body: some View {
        if let uiImage = UIImage(named: imageName) {
            Image(uiImage: uiImage)
                .resizable()
        } else {
            placeholder ?? Image(systemName: "photo")
                .foregroundColor(.gray)
        }
    }
}

// MARK: - NFT Grid Container with Scroll Features
struct ScrollableNFTGrid: View {
    let nftItems: [NFTItem]
    let columns: Int
    @State private var scrollPosition: CGFloat = 0
    @State private var showScrollToTop = false
    
    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 16), count: columns)
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVGrid(columns: gridColumns, spacing: 20) {
                        ForEach(nftItems) { item in
                            NFTCardView(
                                title: item.title,
                                creator: item.creator,
                                creatorUsername: item.creatorUsername,
                                imageName: item.imageName
                            )
                            .id(item.id)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                }
                .background(Color.black.edgesIgnoringSafeArea(.all))
                .onScrollPositionChanged { position in
                    scrollPosition = position
                    showScrollToTop = position > 500
                }
                .overlay(
                    // Scroll to top button
                    scrollToTopButton(proxy: proxy)
                )
            }
        }
    }
    
    @ViewBuilder
    private func scrollToTopButton(proxy: ScrollViewReader) -> some View {
        if showScrollToTop {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.6)) {
                            proxy.scrollTo(nftItems.first?.id, anchor: .top)
                        }
                    }) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.8))
                                    .overlay(
                                        Circle()
                                            .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .transition(.scale.combined(with: .opacity))
                }
                .padding(.trailing, 20)
                .padding(.bottom, 100)
            }
        }
    }
}

// MARK: - Scroll Position Tracking
extension View {
    func onScrollPositionChanged(perform action: @escaping (CGFloat) -> Void) -> some View {
        self.background(
            GeometryReader { geometry in
                Color.clear
                    .preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: geometry.frame(in: .named("scroll")).minY
                    )
            }
        )
        .onPreferenceChange(ScrollOffsetPreferenceKey.self, perform: action)
        .coordinateSpace(name: "scroll")
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Preview
struct NFTCardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Single card
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                NFTCardView(
                    title: "The Hazy Maze Collection",
                    creator: "@artninja",
                    creatorUsername: "@jonahlipps",
                    imageName: "nft-image"
                )
            }
            .previewDisplayName("Single Card")
            
            // Scrollable grid
            ScrollableNFTGrid(
                nftItems: generateSampleNFTItems(count: 12),
                columns: 1
            )
            .previewDisplayName("Scrollable Grid")
            
            // Two-column grid
            ScrollableNFTGrid(
                nftItems: generateSampleNFTItems(count: 20),
                columns: 2
            )
            .previewDisplayName("Two-Column Grid")
        }
        .environmentObject(FontManager.shared)
    }
}