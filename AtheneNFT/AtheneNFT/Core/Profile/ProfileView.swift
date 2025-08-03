import SwiftUI
import UIKit

// MARK: - ProfileView

struct ProfileView: View {
    @State private var selectedTab: ProfileTab = .collected
    @State private var profileScale: CGFloat = 1.0
    @State private var isRefreshing = false
    @Namespace var namespace
    private let haptic = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 0) {
                        Color.black.frame(height: geometry.safeAreaInsets.top)
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(height: DynamicSizing.size(base: 64, geometry: geometry))
                                .background(Color.black)
                            Text("ben_parker53")
                                .font(Font.custom("Noto Sans", size: DynamicSizing.fontSize(base: 22, geometry: geometry)).weight(.semibold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .background(Color.black)

                    // Main content
                    ScrollView {
                        VStack(spacing: 12) {
                            // Profile image with tap animation
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
                                .padding(.top, DynamicSizing.padding(base: 24, geometry: geometry))
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

                            // Full name
                            Text("Ben Parker")
                                .font(Font.custom("Noto Sans", size: DynamicSizing.fontSize(base: 30, geometry: geometry)).weight(.bold))
                                .foregroundColor(.white)
                                .padding(.top, DynamicSizing.padding(base: 14, geometry: geometry))
                                .padding(.bottom, 4)

                            // Location
                            Text("San Francisco, CA, USA")
                                .foregroundColor(.gray)
                                .font(Font.custom("Noto Sans", size: DynamicSizing.fontSize(base: 17, geometry: geometry)))
                                .padding(.bottom, DynamicSizing.padding(base: 10, geometry: geometry))

                            // Bio
                            Text("Artist, Illustrator, Photoshop")
                                .font(Font.custom("Noto Sans", size: DynamicSizing.fontSize(base: 17, geometry: geometry)))
                                .foregroundColor(.white)
                                .padding(.bottom, DynamicSizing.padding(base: 20, geometry: geometry))

                            // Stats
                            HStack(spacing: DynamicSizing.spacing(base: 40, geometry: geometry)) {
                                StatView(value: "54", label: "Pieces", geometry: geometry)
                                StatView(value: "834", label: "Followers", geometry: geometry)
                                StatView(value: "162", label: "Following", geometry: geometry)
                            }
                            .padding(.vertical, DynamicSizing.padding(base: 12, geometry: geometry))

                            // Divider
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                                .edgesIgnoringSafeArea(.horizontal)

                            // Tab selector
                            HStack(spacing: 0) {
                                ForEach(ProfileTab.allCases, id: \.self) { tab in
                                    VStack(spacing: 6) {
                                        Text(tab.rawValue)
                                            .fontWeight(selectedTab == tab ? .semibold : .regular)
                                            .foregroundColor(selectedTab == tab ? .white : .gray)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                        if selectedTab == tab {
                                            Rectangle()
                                                .fill(Color.blue)
                                                .frame(height: 2)
                                                .matchedGeometryEffect(id: "tab", in: namespace)
                                        } else {
                                            Rectangle().fill(Color.clear).frame(height: 2)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            selectedTab = tab
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .edgesIgnoringSafeArea(.horizontal)

                            // Gallery grid
                            VStack(spacing: 1) {
                                ForEach(0..<3) { row in
                                    HStack(spacing: 1) {
                                        ForEach(0..<3) { col in
                                            let index = row * 3 + col
                                            NFTGridItemView(index: index, geometry: geometry)
                                        }
                                    }
                                }
                            }
                            .edgesIgnoringSafeArea(.horizontal)
                        }
                    }
                    .refreshable {
                        await refreshContent()
                    }
                    .edgesIgnoringSafeArea(.horizontal)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            haptic.prepare()
        }
    }

    // Pull to refresh
    private func refreshContent() async {
        haptic.impactOccurred()
        isRefreshing = true
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        withAnimation(.easeInOut(duration: 0.3)) {
            isRefreshing = false
        }
    }

    enum ProfileTab: String, CaseIterable {
        case collected = "Collected"
        case liked = "Liked"
    }
}

// MARK: - StatView

struct StatView: View {
    let value: String
    let label: String
    let geometry: GeometryProxy

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(Font.custom("Noto Sans", size: DynamicSizing.fontSize(base: 24, geometry: geometry)).weight(.bold))
                .foregroundColor(.white)
            Text(label)
                .font(Font.custom("Noto Sans", size: DynamicSizing.fontSize(base: 15, geometry: geometry)))
                .foregroundColor(.gray)
        }
    }
}

// MARK: - NFTGridItemView

struct NFTGridItemView: View {
    let index: Int
    let geometry: GeometryProxy
    @State private var isPressed = false
    private let haptic = UIImpactFeedbackGenerator(style: .light)

    // Updated image paths to match your actual assets
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
                Rectangle().fill(Color(white: 0.1))
                
                // Use FallbackAsyncImage for better image handling
                FallbackAsyncImage(
                    imageName: imagePaths[safe: index] ?? "placeholder",
                    contentMode: .fill,
                    cornerRadius: 0
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
            }
            .aspectRatio(1, contentMode: .fill)
            .frame(maxWidth: .infinity)
            .clipped()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - NFTDetailView

struct NFTDetailView: View {
    let index: Int

    var body: some View {
        ScrollView {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(alignment: .leading, spacing: 16) {
                    // NFT Image - Better fallback handling
                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(1, contentMode: .fit)
                        
                        // Use FallbackAsyncImage for consistent image loading
                        FallbackAsyncImage(
                            imageName: "nft-image",
                            contentMode: .fit,
                            cornerRadius: 0
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)

                    // Title and price
                    HStack {
                        VStack(alignment: .leading) {
                            Text("NFT Title #\(index + 1)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Created by @ben_parker53")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text("0.\(index + 1) ETH")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)

                    // Description
                    Text("This is a unique digital artwork created by the artist. Each piece is one of a kind and represents a unique moment in digital art history.")
                        .foregroundColor(.white)
                        .padding(.horizontal)

                    // Buy button
                    Button(action: {}) {
                        Text("Buy Now")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("NFT Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Array Extension for Safe Access
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}