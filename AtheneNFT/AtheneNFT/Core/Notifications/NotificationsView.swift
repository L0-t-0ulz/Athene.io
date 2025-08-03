import SwiftUI

struct NotificationsView: View {
    @State private var isRefreshing = false
    private let haptic = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with safe area
                    VStack(spacing: 0) {
                        Color.black
                            .frame(height: geometry.safeAreaInsets.top)
                        
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(height: DynamicSizing.size(base: 64, geometry: geometry))
                                .background(.black)
                            
                            Text("Notifications")
                                .font(Font.custom("Noto Sans", size: DynamicSizing.fontSize(base: 32, geometry: geometry)).weight(.bold))
                                .foregroundColor(.white)
                                .padding(.leading, DynamicSizing.padding(base: 20, geometry: geometry))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .background(Color.black)
                
                    // Content with pull to refresh
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            // Pull to refresh indicator
                            if isRefreshing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                                    .frame(height: 50)
                                    .frame(maxWidth: .infinity)
                                    .transition(.opacity)
                            }
                        // New section
                        NotificationSectionHeader(title: "New")
                        
                        NotificationRow(
                            username: "karennne",
                            action: "liked",
                            targetText: "your post",
                            timeAgo: "1h",
                            showImage: true,
                            isFollowing: false,
                            geometry: geometry
                        )
                        
                        // Today section
                        NotificationSectionHeader(title: "Today")
                        
                        NotificationRow(
                            username: "kiero_d, zackjohn",
                            action: "and 26 others viewed",
                            targetText: "your listing on opensea.io",
                            timeAgo: "3h",
                            showImage: true,
                            isFollowing: false,
                            geometry: geometry
                        )
                        
                        // This Week section
                        NotificationSectionHeader(title: "This Week")
                        
                        NotificationRow(
                            username: "craig_love",
                            action: "shared",
                            targetText: "your post",
                            timeAgo: "2d",
                            showImage: true,
                            isFollowing: false,
                            emoji: " 💫",
                            geometry: geometry
                        )
                        
                        NotificationRow(
                            username: "martini_rond",
                            action: "started",
                            targetText: "following you",
                            timeAgo: "3d",
                            showImage: false,
                            isFollowing: true,
                            geometry: geometry
                        )
                        
                        NotificationRow(
                            username: "maxjacobson",
                            action: "started",
                            targetText: "following you",
                            timeAgo: "3d",
                            showImage: false,
                            isFollowing: true,
                            geometry: geometry
                        )
                        
                        NotificationRow(
                            username: "mis_potter",
                            action: "started",
                            targetText: "following you",
                            timeAgo: "3d",
                            showImage: false,
                            isFollowing: false,
                            geometry: geometry
                        )
                        
                        // This Month section
                        NotificationSectionHeader(title: "This Month")
                        
                        NotificationRow(
                            username: "m_humphrey",
                            action: "started",
                            targetText: "following you",
                            timeAgo: "3d",
                            showImage: false,
                            isFollowing: true,
                            geometry: geometry
                        )
                        
                        NotificationRow(
                            username: "jammie_",
                            action: "started",
                            targetText: "following you",
                            timeAgo: "1w",
                            showImage: false,
                            isFollowing: false,
                            geometry: geometry
                        )
                    }
                    }
                    .refreshable {
                        await refreshContent()
                    }
                    .edgesIgnoringSafeArea(.horizontal)
                }
                .navigationBarHidden(true)
            }
        }
        .onAppear {
            haptic.prepare()
        }
    }
    
    // Pull to refresh function
    private func refreshContent() async {
        haptic.impactOccurred()
        isRefreshing = true
        
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        withAnimation(.easeInOut(duration: 0.3)) {
            isRefreshing = false
        }
    }
}

struct NotificationSectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(Font.custom("Noto Sans", size: 15).weight(.semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.black)
    }
}

struct NotificationRow: View {
    let username: String
    let action: String
    let targetText: String
    let timeAgo: String
    let showImage: Bool
    let isFollowing: Bool
    var emoji: String = ""
    let geometry: GeometryProxy
    @State private var isPressed = false
    private let haptic = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Profile Image
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .padding(12)
                        .foregroundColor(.gray)
                )
            
            // Text Content
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .center, spacing: 4) {
                    Text(username)
                        .font(Font.custom("Noto Sans", size: 15).weight(.semibold))
                        .foregroundColor(.white)
                    
                    Text(action)
                        .font(Font.custom("Noto Sans", size: 15))
                        .foregroundColor(.white)
                }
                
                HStack(spacing: 4) {
                    Text(targetText)
                        .font(Font.custom("Noto Sans", size: 15))
                        .foregroundColor(.white)
                    
                    if !emoji.isEmpty {
                        Text(emoji)
                    }
                    
                    Text(timeAgo)
                        .font(Font.custom("Noto Sans", size: 15))
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Right Side Content
            if showImage {
                // NFT Image
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 44, height: 44)
                    .cornerRadius(6)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                            .font(.caption)
                    )
            } else {
                // Follow Button
                Button(action: {}) {
                    Text(isFollowing ? "Following" : "Follow")
                        .font(Font.custom("Noto Sans", size: 14).weight(.semibold))
                        .foregroundColor(isFollowing ? .white : .white)
                        .frame(width: 90, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(isFollowing ? Color.blue.opacity(0.3) : Color.blue)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isFollowing ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 1)
                        )
                }
            }
        }
        .padding(.horizontal, DynamicSizing.padding(base: 20, geometry: geometry))
        .padding(.vertical, DynamicSizing.padding(base: 14, geometry: geometry))
        .frame(maxWidth: .infinity)
        .background(Color.black)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color.gray.opacity(0.3)),
            alignment: .bottom
        )
    }
}