import SwiftUI
import Combine

struct NotificationsView: View {
    @ObservedObject private var service = NFTService.shared
    @State private var notifications: [Notification] = []
    @State private var hasLoaded = false
    @State private var cancellables = Set<AnyCancellable>()
    private let haptic = UIImpactFeedbackGenerator(style: .light)

    private var todayItems: [Notification] {
        notifications.filter { $0.timestamp > Date().addingTimeInterval(-86400) }
    }

    private var thisWeekItems: [Notification] {
        notifications.filter {
            $0.timestamp <= Date().addingTimeInterval(-86400) &&
            $0.timestamp > Date().addingTimeInterval(-7 * 86400)
        }
    }

    private var earlierItems: [Notification] {
        notifications.filter { $0.timestamp <= Date().addingTimeInterval(-7 * 86400) }
    }

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
                            if service.isLoading && notifications.isEmpty {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(height: 120)
                                    .frame(maxWidth: .infinity)
                            } else if notifications.isEmpty {
                                // Empty state
                                VStack(spacing: 12) {
                                    Image(systemName: "bell.slash")
                                        .font(.system(size: 44))
                                        .foregroundColor(.gray)

                                    Text("No notifications yet")
                                        .font(Font.custom("Noto Sans", size: 18).weight(.semibold))
                                        .foregroundColor(.white)

                                    Text("Activity on your NFTs will show up here.")
                                        .font(Font.custom("Noto Sans", size: 14))
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 80)
                            } else {
                                notificationSection(title: "Today", items: todayItems, geometry: geometry)
                                notificationSection(title: "This Week", items: thisWeekItems, geometry: geometry)
                                notificationSection(title: "Earlier", items: earlierItems, geometry: geometry)
                            }
                        }
                    }
                    .refreshable {
                        haptic.impactOccurred()
                        loadNotifications()
                    }
                    .edgesIgnoringSafeArea(.horizontal)
                }
                .navigationBarHidden(true)
            }
        }
        .onAppear {
            haptic.prepare()
            if !hasLoaded {
                hasLoaded = true
                loadNotifications()
            }
        }
    }

    @ViewBuilder
    private func notificationSection(title: String, items: [Notification], geometry: GeometryProxy) -> some View {
        if !items.isEmpty {
            NotificationSectionHeader(title: title)

            ForEach(items) { notification in
                NotificationRow(notification: notification, geometry: geometry)
            }
        }
    }

    private func loadNotifications() {
        service.isLoading = true
        service.fetchNotifications()
            .sink(
                receiveCompletion: { completion in
                    service.isLoading = false
                    if case .failure(let error) = completion {
                        service.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { response in
                    notifications = response.items
                }
            )
            .store(in: &cancellables)
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
    let notification: Notification
    let geometry: GeometryProxy
    @State private var isFollowing = false
    private let haptic = UIImpactFeedbackGenerator(style: .light)

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Unread indicator
            Circle()
                .fill(notification.isRead ? Color.clear : Color.blue)
                .frame(width: 8, height: 8)

            // Profile Image
            Circle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.6, green: 0.4, blue: 0.2),
                        Color(red: 0.3, green: 0.2, blue: 0.1)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .frame(width: 44, height: 44)
                .overlay(
                    Text(notification.user.username.avatarInitial)
                        .font(Font.custom("Noto Sans", size: 16).weight(.bold))
                        .foregroundColor(.white)
                )

            // Text Content
            VStack(alignment: .leading, spacing: 2) {
                Text(notification.message)
                    .font(Font.custom("Noto Sans", size: 15))
                    .foregroundColor(.white)
                    .lineLimit(2)

                Text(notification.timeAgo)
                    .font(Font.custom("Noto Sans", size: 13))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Right Side Content
            if let nft = notification.nft {
                // NFT thumbnail
                FallbackAsyncImage(
                    imageName: nft.imageURL,
                    size: CGSize(width: 44, height: 44),
                    contentMode: .fill,
                    cornerRadius: 6
                )
            } else {
                // Follow Button (follow notifications have no NFT attached)
                Button(action: {
                    haptic.impactOccurred()
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isFollowing.toggle()
                    }
                }) {
                    Text(isFollowing ? "Following" : "Follow")
                        .font(Font.custom("Noto Sans", size: 14).weight(.semibold))
                        .foregroundColor(.white)
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
