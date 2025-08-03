import SwiftUI
import UIKit

// MARK: - Font Utilities
struct FontUtility {
    
    // MARK: - Font Names
    static let primaryFontFamily = "Noto Sans"
    static let secondaryFontFamily = "System"
    
    // MARK: - Common Font Styles
    static func primaryFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return Font.custom(primaryFontFamily, size: size).weight(weight)
    }
    
    static func titleFont(size: CGFloat = 24) -> Font {
        return Font.custom(primaryFontFamily, size: size).weight(.bold)
    }
    
    static func subtitleFont(size: CGFloat = 18) -> Font {
        return Font.custom(primaryFontFamily, size: size).weight(.semibold)
    }
    
    static func bodyFont(size: CGFloat = 16) -> Font {
        return Font.custom(primaryFontFamily, size: size).weight(.regular)
    }
    
    static func captionFont(size: CGFloat = 12) -> Font {
        return Font.custom(primaryFontFamily, size: size).weight(.medium)
    }
    
    // MARK: - Responsive Font Sizes
    static func responsiveFont(baseSize: CGFloat, geometry: GeometryProxy, weight: Font.Weight = .regular) -> Font {
        let responsiveSize = DynamicSizing.fontSize(base: baseSize, geometry: geometry)
        return Font.custom(primaryFontFamily, size: responsiveSize).weight(weight)
    }
    
    // MARK: - NFT Specific Font Styles
    static func nftTitleFont(geometry: GeometryProxy) -> Font {
        return responsiveFont(baseSize: 20, geometry: geometry, weight: .bold)
    }
    
    static func nftCreatorFont(geometry: GeometryProxy) -> Font {
        return responsiveFont(baseSize: 14, geometry: geometry, weight: .medium)
    }
    
    static func nftPriceFont(geometry: GeometryProxy) -> Font {
        return responsiveFont(baseSize: 16, geometry: geometry, weight: .semibold)
    }
}

// MARK: - Text Style Extensions
extension Text {
    func nftTitle(geometry: GeometryProxy) -> some View {
        self
            .font(FontUtility.nftTitleFont(geometry: geometry))
            .foregroundColor(.white)
    }
    
    func nftCreator(geometry: GeometryProxy) -> some View {
        self
            .font(FontUtility.nftCreatorFont(geometry: geometry))
            .foregroundColor(.gray)
    }
    
    func nftPrice(geometry: GeometryProxy) -> some View {
        self
            .font(FontUtility.nftPriceFont(geometry: geometry))
            .foregroundColor(.blue)
    }
    
    func sectionHeader() -> some View {
        self
            .font(FontUtility.titleFont(size: 24))
            .foregroundColor(.white)
    }
    
    func sectionSubheader() -> some View {
        self
            .font(FontUtility.subtitleFont(size: 18))
            .foregroundColor(.gray)
    }
}

// MARK: - Font Loading Utilities
extension FontUtility {
    
    /// Preload custom fonts if needed
    static func preloadFonts() {
        // If you have custom font files, load them here
        // For now, we're using system fonts with Noto Sans fallback
    }
    
    /// Check if a custom font is available
    static func isFontAvailable(_ fontName: String) -> Bool {
        return UIFont.familyNames.contains { family in
            UIFont.fontNames(forFamilyName: family).contains(fontName)
        }
    }
    
    /// Get available font families for debugging
    static func getAvailableFontFamilies() -> [String] {
        return UIFont.familyNames.sorted()
    }
}