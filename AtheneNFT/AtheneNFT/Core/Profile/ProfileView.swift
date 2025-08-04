import SwiftUI
import UIKit

// MARK: - ProfileView

struct ProfileView: View {
    @State private var selectedTab: ProfileTab = .collected
    @State private var profileScale: CGFloat = 1.0
    @State private var isRefreshing = false
    @State private var showingSettings = false
    @State private var followersCount = 834
    @State private var isFollowing = false
    @Namespace var namespace
    private let haptic = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with proper safe area handling
                    headerView(geometry: geometry)
                    
                    // Main scrollable content
                    ScrollView {
                        LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                            // Profile section
                            profileSection(geometry: geometry)
                            
                            // Tab selector as pinned header
                            Section(header: tabSelectorHeader(geometry: geometry)) {
                                // Gallery content
                                galleryContent(geometry: geometry)
                            }
                        }
                    }
                    .refreshable {
                        await refreshContent()
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            haptic.prepare()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
    
    // MARK: - Header View
    private func headerView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            // Safe area spacer
            Color.black.frame(height: geometry.safeAreaInsets.top)
            
            // Header content
            HStack {
                Button(action: {
                    showingSettings = true
                    haptic.impactOccurred()
                }) {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("ben_parker53")
                    .font(Font.custom("Noto Sans", size: DynamicSizing.fontSize(base: 22, geometry: geometry)).weight(.semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    haptic.impactOccurred()
                    // Add share functionality
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            .frame(height: DynamicSizing.size(base: 64, geometry: geometry))
            .background(Color.black)
        }
    }
    
    // MARK: - Profile Section
    private func profileSection(geometry: GeometryProxy) -> some View {
        VStack(spacing: 16) {
            // Profile image with enhanced animation
            profileImageView(geometry: geometry)
            
            // User info
            userInfoSection(geometry: geometry)
            
            // Action buttons
            actionButtonsSection(geometry: geometry)
            
            // Stats
            statsSection(geometry: geometry)
            
            // Divider
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 1)
                .padding(.top, 20)
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
    }
    
    // MARK: - Profile Image
    private func profileImageView(geometry: GeometryProxy) -> some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [.blue, .purple, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(
                    width: DynamicSizing.size(base: 148, geometry: geometry),
                    height: DynamicSizing.size(base: 148, geometry: geometry)
                )
            
            // Profile image
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(
                    width: DynamicSizing.size(base: 140, geometry: geometry),
                    height: DynamicSizing.size(base: 140, geometry: geometry)
                )
                .overlay(
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .padding(DynamicSizing.padding(base: 35, geometry: geometry))
                        .foregroundColor(.gray)
                )
        }
        .scaleEffect(profileScale)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                profileScale = 0.95
            }
            haptic.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    profileScale = 1.0
                }
            }
        }
    }
    
    // MARK: - User Info Section
    private func userInfoSection(geometry: GeometryProxy) -> some View {
        VStack(spacing: 8) {
            // Full name with verification badge
            HStack(spacing: 8) {
                Text("Ben Parker")
                    .font(Font.custom("Noto Sans", size: DynamicSizing.fontSize(base: 28, geometry: geometry)).weight(.bold))
                    .foregroundColor(.white)
                
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 20))
            }
            
            // Location
            HStack(spacing: 6) {
                Image(systemName: "location.fill")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
                
                Text("San Francisco, CA, USA")
                    .foregroundColor(.gray)
                    .font(Font.custom("Noto Sans", size: DynamicSizing.fontSize(base: 16, geometry: geometry)))
            }
            
            // Bio
            Text("Artist, Illustrator, Photoshop\n✨ Creating digital art since 2018")
                .font(Font.custom("Noto Sans", size: DynamicSizing.fontSize(base: 16, geometry: geometry)))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
    }
    
    // MARK: - Action Buttons
    private func actionButtonsSection(geometry: GeometryProxy) -> some View {
        HStack(spacing: 12) {
            // Follow/Following button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isFollowing.toggle()
                    followersCount += isFollowing ? 1 : -1
                }
                haptic.impactOccurred()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: isFollowing ? "person.check.fill" : "person.badge.plus")
                        .font(.system(size: 16, weight: .medium))
                    
                    Text(isFollowing ? "Following" : "Follow")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(isFollowing ? .white : .black)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isFollowing ? Color.white.opacity(0.2) : Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.3), lineWidth: isFollowing ? 1 : 0)
                )
            }
            
            // Message button
            Button(action: {
                haptic.impactOccurred()
                // Add message functionality
            }) {
                Image(systemName: "message.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.2))
                    )
            }
            
            // More options button
            Button(action: {
                haptic.impactOccurred()
                // Add more options
            }) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.2))
                    )
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Stats Section
    private func statsSection(geometry: GeometryProxy) -> some View {
        HStack(spacing: 0) {
            StatView(
                value: "54",
                label: "Pieces",
                geometry: geometry,
                action: { haptic.impactOccurred() }
            )
            
            Divider()
                .frame(height: 40)
                .background(Color.white.opacity(0.2))
            
            StatView(
                value: "\(followersCount)",
                label: "Followers",
                geometry: geometry,
                action: { haptic.impactOccurred() }
            )
            
            Divider()
                .frame(height: 40)
                .background(Color.white.opacity(0.2))
            
            StatView(
                value: "162",
                label: "Following",
                geometry: geometry,
                action: { haptic.impactOccurred() }
            )
        }
        .padding(.top, 20)
    }
    
    // MARK: - Tab Selector Header
    private func tabSelectorHeader(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(ProfileTab.allCases, id: \.self) { tab in
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 14, weight: .medium))
                            
                            Text(tab.rawValue)
                                .font(.system(size: 16, weight: selectedTab == tab ? .semibold : .medium))
                        }
                        .foregroundColor(selectedTab == tab ? .white : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        
                        if selectedTab == tab {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(height: 3)
                                .cornerRadius(1.5)
                                .matchedGeometryEffect(id: "tab", in: namespace)
                        } else {
                            Rectangle().fill(Color.clear).frame(height: 3)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedTab = tab
                        }
                        haptic.impactOccurred()
                    }
                }
            }
            .background(Color.black)
            
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 1)
        }
    }
    
    // MARK: - Gallery Content
    private func galleryContent(geometry: GeometryProxy) -> some View {
        VStack(spacing: 1) {
            if selectedTab == .collected {
                collectedItemsGrid(geometry: geometry)
            } else {
                likedItemsGrid(geometry: geometry)
            }
        }
        .padding(.top, 1)
    }
    
    // MARK: - Collected Items Grid
    private func collectedItemsGrid(geometry: GeometryProxy) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 1), count: 3), spacing: 1) {
            ForEach(0..<9) { index in
                NFTGridItemView(index: index, geometry: geometry)
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: selectedTab)
    }
    
    // MARK: - Liked Items Grid
    private func likedItemsGrid(geometry: GeometryProxy) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 1), count: 3), spacing: 1) {
            ForEach(0..<6) { index in
                NFTGridItemView(index: index + 3, geometry: geometry)
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: selectedTab)
    }

    // MARK: - Pull to Refresh
    private func refreshContent() async {
        haptic.impactOccurred()
        isRefreshing = true
        
        // Simulate network request
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        withAnimation(.easeInOut(duration: 0.3)) {
            isRefreshing = false
        }
    }

    enum ProfileTab: String, CaseIterable {
        case collected = "Collected"
        case liked = "Liked"
        
        var icon: String {
            switch self {
            case .collected:
                return "rectangle.stack.fill"
            case .liked:
                return "heart.fill"
            }
        }
    }
}

// MARK: - Enhanced StatView

struct StatView: View {
    let value: String
    let label: String
    let geometry: GeometryProxy
    let action: (() -> Void)?
    
    init(value: String, label: String, geometry: GeometryProxy, action: (() -> Void)? = nil) {
        self.value = value
        self.label = label
        self.geometry = geometry
        self.action = action
    }

    var body: some View {
        Button(action: {
            action?()
        }) {
            VStack(spacing: 6) {
                Text(value)
                    .font(Font.custom("Noto Sans", size: DynamicSizing.fontSize(base: 24, geometry: geometry)).weight(.bold))
                    .foregroundColor(.white)
                
                Text(label)
                    .font(Font.custom("Noto Sans", size: DynamicSizing.fontSize(base: 14, geometry: geometry)))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Enhanced NFTGridItemView

struct NFTGridItemView: View {
    let index: Int
    let geometry: GeometryProxy
    @State private var isPressed = false
    @State private var imageLoaded = false
    private let haptic = UIImpactFeedbackGenerator(style: .light)

    private let imagePaths = [
        "Trending/Image@19",
        "Cards/Image@10", 
        "Doge/Image@17",
        "Gifs/Image@7",
        "Celebrities/Image@2",
        "New/Image@24",
        "Trending/Image@20",
        "Cards/Image@12",
        "Doge/Image@15"
    ]

    var body: some View {
        NavigationLink(destination: NFTDetailView(index: index)) {
            ZStack {
                // Background
                Rectangle()
                    .fill(Color(white: 0.1))
                
                // Shimmer loading effect
                if !imageLoaded {
                    ShimmerView()
                }
                
                // Image
                FallbackAsyncImage(
                    imageName: imagePaths[safe: index] ?? "placeholder",
                    contentMode: .fill,
                    cornerRadius: 0
                )
                .opacity(imageLoaded ? 1 : 0)
                .onAppear {
                    withAnimation(.easeIn(duration: 0.3)) {
                        imageLoaded = true
                    }
                }
                
                // Gradient overlay
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.3)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                
                // Favorite button
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            haptic.impactOccurred()
                        }) {
                            Image(systemName: "heart")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        .padding(8)
                    }
                    Spacer()
                }
            }
            .aspectRatio(1, contentMode: .fill)
            .clipShape(RoundedRectangle(cornerRadius: 2))
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            pressing: { pressing in
                isPressed = pressing
                if pressing {
                    haptic.impactOccurred()
                }
            },
            perform: {}
        )
    }
}

// MARK: - Shimmer View
struct ShimmerView: View {
    @State private var phase: CGFloat = 0
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.gray.opacity(0.3),
                        Color.gray.opacity(0.5),
                        Color.gray.opacity(0.3)
                    ],
                    startPoint: .init(x: phase - 0.5, y: 0),
                    endPoint: .init(x: phase + 0.5, y: 0)
                )
            )
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Profile Settings")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    Spacer()
                    
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Enhanced NFTDetailView

struct NFTDetailView: View {
    let index: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // NFT Image with better layout
                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(1, contentMode: .fit)
                        
                        FallbackAsyncImage(
                            imageName: "nft-image",
                            contentMode: .fit,
                            cornerRadius: 16
                        )
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    VStack(alignment: .leading, spacing: 16) {
                        // Title and price
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Digital Masterpiece #\(index + 1)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                HStack(spacing: 6) {
                                    Image(systemName: "person.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 16))
                                    
                                    Text("Created by @ben_parker53")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 16))
                                }
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("0.\(index + 1) ETH")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("$\((index + 1) * 245)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue.opacity(0.2))
                            )
                        }

                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("This is a unique digital artwork that represents the intersection of technology and creativity. Each piece tells a story through carefully crafted pixels and innovative design techniques that push the boundaries of digital art.")
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(nil)
                        }

                        // Properties
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Properties")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                PropertyView(title: "Background", value: "Cosmic")
                                PropertyView(title: "Style", value: "Abstract")
                                PropertyView(title: "Rarity", value: "Ultra Rare")
                                PropertyView(title: "Edition", value: "1 of 1")
                            }
                        }

                        // Buy button
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "creditcard.fill")
                                    .font(.system(size: 18, weight: .medium))
                                
                                Text("Buy Now for 0.\(index + 1) ETH")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                        }
                        .padding(.top, 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - Property View
struct PropertyView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.05))
        )
    }
}

// MARK: - Array Extension for Safe Access
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}