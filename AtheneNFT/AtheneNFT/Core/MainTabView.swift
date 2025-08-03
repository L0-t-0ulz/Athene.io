import SwiftUI
import Combine

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var showWalletTransfer = false
    private let haptic = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(0)
                
                DiscoverView()
                    .tag(1)
                
                Color.clear
                    .tag(2)
                    .onAppear {
                        if selectedTab == 2 {
                            showWalletTransfer = true
                            selectedTab = 0 // Reset to home after showing modal
                        }
                    }
                
                NotificationsView()
                    .tag(3)
                
                ProfileView()
                    .tag(4)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .ignoresSafeArea()
            
                // Custom Tab Bar
                // Modern tab bar matching the screenshots
                ZStack {
                    // Background with subtle border
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: dynamicSize(base: 88, geometry: geometry) + geometry.safeAreaInsets.bottom)
                        .background(Color.black)
                        .overlay(
                            Rectangle()
                                .frame(height: 0.5)
                                .foregroundColor(Color.gray.opacity(0.2)),
                            alignment: .top
                        )
                
                    HStack(spacing: 0) {
                        // Home tab
                        TabButton(
                            icon: "house.fill",
                            title: "Home",
                            isSelected: selectedTab == 0,
                            geometry: geometry
                        ) {
                            haptic.impactOccurred()
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = 0
                            }
                        }
                    
                        // Discover tab
                        TabButton(
                            icon: "magnifyingglass",
                            title: "Discover",
                            isSelected: selectedTab == 1,
                            geometry: geometry
                        ) {
                            haptic.impactOccurred()
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = 1
                            }
                        }
                    
                        // Share tab (center)
                        ShareButton(geometry: geometry) {
                            haptic.impactOccurred()
                            showWalletTransfer = true
                        }
                    
                        // Notifications tab
                        TabButton(
                            icon: "bell.fill",
                            title: "Notifications",
                            isSelected: selectedTab == 3,
                            geometry: geometry
                        ) {
                            haptic.impactOccurred()
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = 3
                            }
                        }
                    
                        // Profile tab
                        TabButton(
                            icon: "person.fill",
                            title: "Me",
                            isSelected: selectedTab == 4,
                            geometry: geometry
                        ) {
                            haptic.impactOccurred()
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = 4
                            }
                        }
                    }
                    .padding(.horizontal, dynamicPadding(base: 24, geometry: geometry))
                    .padding(.top, dynamicPadding(base: 12, geometry: geometry))
                    .padding(.bottom, geometry.safeAreaInsets.bottom)
                }
                .frame(height: dynamicSize(base: 88, geometry: geometry) + geometry.safeAreaInsets.bottom)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .sheet(isPresented: $showWalletTransfer) {
                WalletTransferView(isPresented: $showWalletTransfer)
            }
        }
        .onAppear {
            haptic.prepare()
        }
    }
    
    // Dynamic sizing helpers
    private func dynamicSize(base: CGFloat, geometry: GeometryProxy) -> CGFloat {
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

// Custom tab button with animations
struct TabButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let geometry: GeometryProxy
    let action: () -> Void
    @State private var bounceScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: dynamicSpacing(base: 5)) {
            Image(systemName: icon)
                .font(.system(size: dynamicSize(base: 24)))
                .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                .scaleEffect(bounceScale)
            Text(title)
                .font(Font.custom("Noto Sans", size: dynamicFontSize(base: 11)).weight(.semibold))
                .foregroundColor(isSelected ? .white : .white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                bounceScale = 1.2
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    bounceScale = 1.0
                }
            }
            
            action()
        }
    }
    
    private func dynamicSize(base: CGFloat) -> CGFloat {
        let screenWidth = geometry.size.width
        let scaleFactor = min(screenWidth / 390, 1.3)
        return base * scaleFactor
    }
    
    private func dynamicFontSize(base: CGFloat) -> CGFloat {
        let screenWidth = geometry.size.width
        let scaleFactor = min(screenWidth / 390, 1.3)
        return base * scaleFactor
    }
    
    private func dynamicSpacing(base: CGFloat) -> CGFloat {
        let screenWidth = geometry.size.width
        let scaleFactor = min(screenWidth / 390, 1.3)
        return base * scaleFactor
    }
}

// Share button with special styling
struct ShareButton: View {
    let geometry: GeometryProxy
    let action: () -> Void
    @State private var bounceScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: dynamicSpacing(base: 5)) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.50, green: 0.23, blue: 0.27).opacity(0.5))
                    .frame(width: dynamicSize(base: 54), height: dynamicSize(base: 54))
                
                Image(systemName: "plus")
                    .font(.system(size: dynamicSize(base: 26), weight: .bold))
                    .foregroundColor(.white)
            }
            .scaleEffect(bounceScale)
            
            Text("Share")
                .font(Font.custom("Noto Sans", size: dynamicFontSize(base: 11)).weight(.semibold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                bounceScale = 0.9
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    bounceScale = 1.0
                }
            }
            
            action()
        }
    }
    
    private func dynamicSize(base: CGFloat) -> CGFloat {
        let screenWidth = geometry.size.width
        let scaleFactor = min(screenWidth / 390, 1.3)
        return base * scaleFactor
    }
    
    private func dynamicFontSize(base: CGFloat) -> CGFloat {
        let screenWidth = geometry.size.width
        let scaleFactor = min(screenWidth / 390, 1.3)
        return base * scaleFactor
    }
    
    private func dynamicSpacing(base: CGFloat) -> CGFloat {
        let screenWidth = geometry.size.width
        let scaleFactor = min(screenWidth / 390, 1.3)
        return base * scaleFactor
    }
}