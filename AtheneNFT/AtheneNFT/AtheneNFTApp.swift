import SwiftUI
import Combine
import UIKit
import os

@main
struct AtheneNFTApp: App {

    @StateObject private var fontManager = FontManager.shared

    private static let logger = Logger(subsystem: "com.zayankhan12.AtheneNFT", category: "App")

     var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(fontManager)
                .preferredColorScheme(.dark) // Ensure dark mode for NFT theme
                .onAppear {
                    setupApp()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)) { _ in
                    Self.logger.info("Memory warning received — clearing URL cache")
                    URLCache.shared.removeAllCachedResponses()
                }
        }
    }

    /// Initialize app-wide configurations
    private func setupApp() {
        // Configure app appearance
        configureAppearance()
    }
    
    /// Configure global app appearance
    private func configureAppearance() {
        // Navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = .black
        navBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 18, weight: .medium)
        ]
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        
        // Tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .black
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
}

// MARK: - Font management for the app
class FontManager: ObservableObject {
    static let shared = FontManager()
    
    @Published var fontsLoaded = false
    
    private init() {
        loadCustomFonts()
    }
    
    private func loadCustomFonts() {
        // Noto Sans is not bundled, so every Font.custom("Noto Sans", …) call
        // silently falls back to the system font. Bundle the font files and
        // register them here to render the real typeface.
        DispatchQueue.main.async {
            self.fontsLoaded = true
        }
    }
    
    func primaryFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return .system(size: size, weight: weight, design: .default)
    }
    
    func titleFont(size: CGFloat = 20) -> Font {
        return .system(size: size, weight: .bold, design: .default)
    }
}

// MARK: - Custom View Modifiers and Extensions

extension Text {
    func nftTitleStyle() -> some View {
        self
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.white)
    }
    
    func nftSubtitleStyle() -> some View {
        self
            .font(.subheadline)
            .foregroundColor(.gray)
    }
    
    func nftCreatorStyle() -> some View {
        self
            .font(.caption)
            .foregroundColor(.white.opacity(0.8))
    }
}
