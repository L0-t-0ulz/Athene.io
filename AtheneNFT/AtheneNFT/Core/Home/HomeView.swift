import SwiftUI
import UIKit

struct HomeView: View {
    @State private var isRefreshing = false
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
    @State private var scrollToTopTrigger = false
    @State private var scrollToBottomTrigger = false
    
    private func scrollToTop() {
        scrollToTopTrigger.toggle()
    }

    private func scrollToBottom() {
        scrollToBottomTrigger.toggle()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background color
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with safe area
                    VStack(spacing: 0) {
                        Color.black
                            .frame(height: geometry.safeAreaInsets.top)
                        
                        HStack {
                            Text("Home Feed")
                                .font(Font.custom("Noto Sans", size: DynamicSizing.fontSize(base: 28, geometry: geometry)).weight(.bold))
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding(.horizontal, DynamicSizing.padding(base: 20, geometry: geometry))
                        .padding(.vertical, 12)
                    }
                    .background(Color.black)
                    
                    // Content with pull to refresh and scroll-to-top/bottom support
                    ScrollViewReader { proxy in
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 0) {
                                // Top anchor
                                Color.clear.frame(height: 1).id("top")

                                // Pull to refresh indicator
                                if isRefreshing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                        .frame(height: 50)
                                        .frame(maxWidth: .infinity)
                                        .transition(.opacity)
                                }

                                // NFT posts
                                let posts = getMockNFTs()
                                if posts.isEmpty {
                                    VStack(spacing: 12) {
                                        Image(systemName: "photo.on.rectangle.angled")
                                            .font(.system(size: 44))
                                            .foregroundColor(.gray)

                                        Text("No posts yet")
                                            .font(Font.custom("Noto Sans", size: 18).weight(.semibold))
                                            .foregroundColor(.white)

                                        Text("Follow creators to fill your feed.")
                                            .font(Font.custom("Noto Sans", size: 14))
                                            .foregroundColor(.gray)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 80)
                                } else {
                                    ForEach(posts) { nft in
                                        NFTPostView(nft: nft, geometry: geometry)
                                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                                    }
                                }

                                // Bottom anchor
                                Color.clear.frame(height: 100).id("bottom")
                            }
                        }
                        .refreshable {
                            await refreshContent()
                        }
                        .ignoresSafeArea(edges: .horizontal)
                        .onChange(of: scrollToTopTrigger) { oldValue, newValue in
                            if oldValue != newValue {
                                withAnimation {
                                    proxy.scrollTo("top", anchor: .top)
                                }
                            }
                        }
                        .onChange(of: scrollToBottomTrigger) { oldValue, newValue in
                            if oldValue != newValue {
                                withAnimation {
                                    proxy.scrollTo("bottom", anchor: .bottom)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func refreshContent() async {
        isRefreshing = true
        hapticFeedback.impactOccurred()
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        isRefreshing = false
    }
    
    // Mock data for the UI
    func getMockNFTs() -> [NFT] {
        let creators = [
            User(id: "1", username: "@Rayul", displayName: "Rayul", profileImage: "profile-image", bio: "Digital artist", location: "New York"),
            User(id: "2", username: "@international_md", displayName: "International MD", profileImage: "profile-image", bio: "NFT Creator", location: "Digital World"),
            User(id: "3", username: "@cryptoart", displayName: "Crypto Art", profileImage: "profile-image", bio: "NFT Collector", location: "Miami"),
            User(id: "4", username: "@digitalmaster", displayName: "Digital Master", profileImage: "profile-image", bio: "3D Artist", location: "Los Angeles"),
            User(id: "5", username: "@nftgenius", displayName: "NFT Genius", profileImage: "profile-image", bio: "Creative Director", location: "Tokyo")
        ]
        
        let nfts = [
            NFT(
                id: "1",
                title: "Slango",
                description: "Heres my latest piece that I created, I hope you guys like it!\n#newrelease",
                imageURL: "Trending",
                price: 2.5,
                creator: creators[0],
                createdAt: Date().addingTimeInterval(-3600),
                blockchain: .ethereum,
                contract: "0x123456",
                tokenId: "1",
                isLiked: false,
                likeCount: 154,
                isCollected: false
            ),
            NFT(
                id: "2",
                title: "Cave Man",
                description: "Cave man themed nft, check it out on opensea! #caveman",
                imageURL: "Cards",
                price: 1.8,
                creator: creators[1],
                createdAt: Date().addingTimeInterval(-7200),
                blockchain: .ethereum,
                contract: "0x789012",
                tokenId: "2",
                isLiked: false,
                likeCount: 89,
                isCollected: false
            ),
            NFT(
                id: "3",
                title: "Dogepunk Elite",
                description: "Special edition Dogepunk with rare attributes #dogepunk #rare",
                imageURL: "Doge",
                price: 3.2,
                creator: creators[2],
                createdAt: Date().addingTimeInterval(-10800),
                blockchain: .ethereum,
                contract: "0xABC123",
                tokenId: "3",
                isLiked: true,
                likeCount: 287,
                isCollected: false
            ),
            NFT(
                id: "4",
                title: "Animated Dreams",
                description: "Mesmerizing animated artwork #gif #animated #art",
                imageURL: "Gifs",
                price: 1.5,
                creator: creators[3],
                createdAt: Date().addingTimeInterval(-14400),
                blockchain: .ethereum,
                contract: "0xDEF456",
                tokenId: "4",
                isLiked: false,
                likeCount: 92,
                isCollected: true
            ),
            NFT(
                id: "5",
                title: "Celebrity Collection",
                description: "Exclusive celebrity themed NFT #celebrity #exclusive",
                imageURL: "Celebrities",
                price: 5.0,
                creator: creators[4],
                createdAt: Date().addingTimeInterval(-18000),
                blockchain: .ethereum,
                contract: "0xAB1789",
                tokenId: "5",
                isLiked: true,
                likeCount: 421,
                isCollected: false
            ),
            NFT(
                id: "6",
                title: "Future Vision",
                description: "A glimpse into the future of digital art #new #future",
                imageURL: "New",
                price: 2.8,
                creator: creators[0],
                createdAt: Date().addingTimeInterval(-21600),
                blockchain: .ethereum,
                contract: "0xBC4012",
                tokenId: "6",
                isLiked: false,
                likeCount: 67,
                isCollected: false
            )
        ]
        
        return nfts
    }
}

struct NFTPostView: View {
    let nft: NFT
    let geometry: GeometryProxy
    @State private var imageHeight: CGFloat = 0
    @State private var isLiked: Bool = false
    @State private var likeScale: CGFloat = 1.0
    @State private var showComments = false
    @State private var showLinkCopied = false
    private let haptic = UIImpactFeedbackGenerator(style: .medium)

    /// Shared avatar gradient for the post header and "Created by" badge.
    private static let avatarGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.6, green: 0.4, blue: 0.2),
            Color(red: 0.3, green: 0.2, blue: 0.1)
        ]),
        startPoint: .top,
        endPoint: .bottom
    )

    private var shareURL: URL? {
        NFTService.shared.shareNFT(nft: nft)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // User header
            HStack(spacing: DynamicSizing.spacing(base: 10, geometry: geometry)) {
                // Profile image
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: DynamicSizing.size(base: 40, geometry: geometry), height: DynamicSizing.size(base: 40, geometry: geometry))
            
                    // Profile image overlay with gradient background
                    Circle()
                        .fill(Self.avatarGradient)
                        .frame(width: DynamicSizing.size(base: 38, geometry: geometry), height: DynamicSizing.size(base: 38, geometry: geometry))
                        .overlay(
                            Text(nft.creator.username.avatarInitial)
                                .font(Font.custom("Noto Sans", size: DynamicSizing.fontSize(base: 15, geometry: geometry)).weight(.bold))
                                .foregroundColor(.white)
                        )
                }
                
                // Username
                Text(nft.creator.username)
                    .font(Font.custom("Noto Sans", size: DynamicSizing.fontSize(base: 16, geometry: geometry)).weight(.semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Options button
                Menu {
                    if let url = shareURL {
                        ShareLink(item: url) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        Button {
                            UIPasteboard.general.url = url
                            haptic.impactOccurred()
                            showLinkCopied = true
                        } label: {
                            Label("Copy Link", systemImage: "link")
                        }
                    }
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            isLiked.toggle()
                        }
                        haptic.impactOccurred()
                    } label: {
                        Label(isLiked ? "Unlike" : "Like", systemImage: isLiked ? "heart.slash" : "heart")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, DynamicSizing.padding(base: 16, geometry: geometry))
            .padding(.vertical, DynamicSizing.padding(base: 10, geometry: geometry))
            
            // Image with improved loading
            ZStack {
                // Background
                Rectangle()
                    .fill(Color(red: 0.1, green: 0.1, blue: 0.1))
                    .aspectRatio(1, contentMode: .fit)
                
                // Use FallbackAsyncImage for better image loading
                FallbackAsyncImage(
                    imageName: nft.imageURL,
                    contentMode: .fill,
                    cornerRadius: 0
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
            }
            .aspectRatio(1, contentMode: .fit)
            .frame(maxWidth: .infinity)
            
            // Interaction buttons
            HStack(spacing: DynamicSizing.spacing(base: 16, geometry: geometry)) {
                // Like button with animation
                Button(action: {
                    haptic.impactOccurred()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isLiked.toggle()
                        likeScale = isLiked ? 1.2 : 1.0
                    } completion: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            likeScale = 1.0
                        }
                    }
                }) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.system(size: DynamicSizing.size(base: 24, geometry: geometry)))
                        .foregroundColor(isLiked ? .red : .white)
                        .scaleEffect(likeScale)
                }
                
                // Comment button
                Button(action: {
                    haptic.impactOccurred()
                    showComments = true
                }) {
                    Image(systemName: "message")
                        .font(.system(size: DynamicSizing.size(base: 22, geometry: geometry)))
                        .foregroundColor(.white)
                }

                // Share button
                if let url = shareURL {
                    ShareLink(item: url) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: DynamicSizing.size(base: 22, geometry: geometry)))
                            .foregroundColor(.white)
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        haptic.impactOccurred()
                    })
                }

                Spacer()
            }
            .padding(.horizontal, DynamicSizing.padding(base: 16, geometry: geometry))
            .padding(.top, DynamicSizing.padding(base: 14, geometry: geometry))
            .padding(.bottom, DynamicSizing.padding(base: 8, geometry: geometry))
            
            // Title
            if !nft.title.isEmpty {
                Text(nft.title)
                    .font(Font.custom("Noto Sans", size: 17).weight(.bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, DynamicSizing.padding(base: 16, geometry: geometry))
                    .padding(.top, 2)
            }
            
            // Caption with hashtags
            let captionText = buildCaptionText(for: nft)
            captionText
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DynamicSizing.padding(base: 16, geometry: geometry))
                .padding(.top, 2)
            
            // "Created by" section
            HStack(spacing: 6) {
                Text("Created by")
                    .font(Font.custom("Noto Sans", size: 13))
                    .foregroundColor(.gray)
                
                ZStack {
                    Circle()
                        .fill(Self.avatarGradient)
                        .frame(width: 20, height: 20)
                    
                    Text(nft.creator.username.avatarInitial)
                        .font(Font.custom("Noto Sans", size: 10).weight(.bold))
                        .foregroundColor(.white)
                }
                
                Text(nft.creator.username)
                    .font(Font.custom("Noto Sans", size: 13).weight(.medium))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, DynamicSizing.padding(base: 16, geometry: geometry))
            .padding(.top, DynamicSizing.padding(base: 10, geometry: geometry))
            .padding(.bottom, DynamicSizing.padding(base: 16, geometry: geometry))
        }
        .background(Color.black)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.15)),
            alignment: .bottom
        )
        .alert("Comments", isPresented: $showComments) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Comments are coming soon.")
        }
        .alert("Link Copied", isPresented: $showLinkCopied) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The NFT link is on your clipboard.")
        }
    }

    private func buildCaptionText(for nft: NFT) -> Text {
        let text = nft.description

        if text.contains("#") {
            // Split on all whitespace (incl. newlines) so hashtags on their own
            // line are still styled.
            let components = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }

            var result = Text("")

            for (index, component) in components.enumerated() {
                if component.hasPrefix("#") {
                    // This is a hashtag
                    if index > 0 {
                        result = result + Text(" ")
                    }
                    result = result + Text(component)
                        .font(Font.custom("Noto Sans", size: 15))
                        .foregroundColor(.blue)
                } else {
                    // This is normal text
                    if index > 0 {
                        result = result + Text(" ")
                    }
                    result = result + Text(component)
                        .font(Font.custom("Noto Sans", size: 15))
                        .foregroundColor(.white)
                }
            }
            
            return result
        } else {
            return Text(text)
                .font(Font.custom("Noto Sans", size: 15))
                .foregroundColor(.white)
        }
    }
}