import SwiftUI
import Combine

/// Enhanced NFT Art Card with improved layout and accessibility
struct NFTArtCard: View {
    let title: String
    let creator: String
    let username: String
    let imageName: String
    let isLiked: Bool
    let likeCount: Int
    let onLike: (() -> Void)?
    let onTap: (() -> Void)?
    
    @State private var imageLoadError = false
    @State private var isPressed = false
    
    init(
        title: String,
        creator: String,
        username: String,
        imageName: String,
        isLiked: Bool = false,
        likeCount: Int = 0,
        onLike: (() -> Void)? = nil,
        onTap: (() -> Void)? = nil
    ) {
        self.title = title
        self.creator = creator
        self.username = username
        self.imageName = imageName
        self.isLiked = isLiked
        self.likeCount = likeCount
        self.onLike = onLike
        self.onTap = onTap
    }
    
    var body: some View {
        GeometryReader { geometry in
            Button(action: { onTap?() }) {
                cardContent(geometry: geometry)
            }
            .buttonStyle(NFTCardButtonStyle())
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .onLongPressGesture(minimumDuration: 0) { _ in
                // Handle press state for visual feedback
            } onPressingChanged: { pressing in
                isPressed = pressing
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("NFT: \(title) by \(creator)")
            .accessibilityHint("Double tap to view details")
        }
        .frame(width: 343, height: 343)
    }
    
    private func cardContent(geometry: GeometryProxy) -> some View {
        ZStack {
            // Main card container
            cardBackground
            
            VStack(spacing: 0) {
                // Header with user info
                cardHeader(geometry: geometry)
                
                // Main NFT image
                nftImageSection
                
                Spacer()
                
                // Footer with title and creator info
                cardFooter(geometry: geometry)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Card Components
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.black)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color(red: 0.90, green: 0.91, blue: 0.92).opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: .black.opacity(0.3),
                radius: 8,
                x: 0,
                y: 4
            )
    }
    
    private func cardHeader(geometry: GeometryProxy) -> some View {
        HStack {
            // User profile section
            HStack(spacing: 8) {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.6, green: 0.4, blue: 0.2),
                            Color(red: 0.3, green: 0.2, blue: 0.1)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(String(username.dropFirst(1).prefix(1)).capitalized)
                            .font(FontUtility.responsiveFont(baseSize: 12, geometry: geometry, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                Text(username)
                    .font(FontUtility.responsiveFont(baseSize: 14, geometry: geometry, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Like button
            Button(action: { onLike?() }) {
                HStack(spacing: 4) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .foregroundColor(isLiked ? .red : .white.opacity(0.7))
                        .font(.system(size: 16))
                    
                    if likeCount > 0 {
                        Text("\(likeCount)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .frame(height: 50)
    }
    
    private var nftImageSection: some View {
        FallbackAsyncImage(
            imageName: imageName,
            size: CGSize(width: 311, height: 200),
            contentMode: .fill,
            cornerRadius: 8
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
        )
        .onTapGesture {
            onTap?()
        }
    }
    
    private func cardFooter(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // NFT Title
            HStack {
                Text(title)
                    .font(FontUtility.responsiveFont(baseSize: 18, geometry: geometry, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            
            // Creator info
            HStack(spacing: 8) {
                Text("Created by")
                    .font(FontUtility.responsiveFont(baseSize: 12, geometry: geometry))
                    .foregroundColor(.gray)
                
                Text(creator)
                    .font(FontUtility.responsiveFont(baseSize: 12, geometry: geometry, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Small creator avatar
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 24, height: 24)
                    .overlay(
                        Text(String(creator.dropFirst(1).prefix(1)).capitalized)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Custom Button Style
struct NFTCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Enhanced NFT Card with Animation
struct AnimatedNFTCard: View {
    let nftItem: NFTItem
    @State private var isLiked = false
    @State private var likeCount = Int.random(in: 5...50)
    @State private var showingDetail = false
    
    var body: some View {
        NFTArtCard(
            title: nftItem.title,
            creator: nftItem.creator,
            username: nftItem.creatorUsername,
            imageName: nftItem.imageName,
            isLiked: isLiked,
            likeCount: likeCount,
            onLike: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isLiked.toggle()
                    likeCount += isLiked ? 1 : -1
                }
                
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            },
            onTap: {
                showingDetail = true
            }
        )
        .sheet(isPresented: $showingDetail) {
            NFTDetailView(nftItem: nftItem)
        }
    }
}

// MARK: - NFT Detail View
struct NFTDetailView: View {
    let nftItem: NFTItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Large image
                    FallbackAsyncImage(
                        imageName: nftItem.imageName,
                        contentMode: .fit,
                        cornerRadius: 16
                    )
                    .aspectRatio(1, contentMode: .fit)
                    .padding(.horizontal)
                    
                    // Details
                    VStack(alignment: .leading, spacing: 16) {
                        Text(nftItem.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        HStack {
                            Text("Created by")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Text(nftItem.creator)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        
                        // Mock description
                        Text("This unique digital artwork represents the intersection of traditional art and blockchain technology. Each piece is carefully crafted and verified on the blockchain.")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(nil)
                        
                        // Mock properties
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Properties")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                PropertyTag(name: "Rarity", value: "Epic")
                                PropertyTag(name: "Edition", value: "1 of 100")
                                PropertyTag(name: "Creator", value: "Verified")
                                PropertyTag(name: "Blockchain", value: "Ethereum")
                            }
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal)
                }
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .navigationTitle("NFT Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

struct PropertyTag: View {
    let name: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.white.opacity(0.1))
        )
    }
}

// MARK: - Preview
struct NFTArtCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Single card preview
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                NFTArtCard(
                    title: "Cryptopunk 10th Edition",
                    creator: "@CryptoJack",
                    username: "@chlomo",
                    imageName: "nft-image",
                    isLiked: false,
                    likeCount: 23
                )
            }
            
            // Grid preview
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                LazyVGrid(columns: [GridItem(.flexible())], spacing: 16) {
                    ForEach(generateSampleNFTItems(count: 3)) { item in
                        AnimatedNFTCard(nftItem: item)
                    }
                }
                .padding()
            }
            .previewDisplayName("Grid View")
        }
        .environmentObject(FontManager.shared)
    }
}