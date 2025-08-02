import SwiftUI
import UIKit

// MARK: - Font Extensions
extension Font {
    
    /// Primary Noto Sans font with fallback
    static func notoSans(size: CGFloat) -> Font {
        return Font.custom("Noto Sans", size: size, relativeTo: .body)
    }
    
    /// Bold Noto Sans with improved weight handling
    static func notoSansBold(size: CGFloat) -> Font {
        return Font.custom("Noto Sans", size: size, relativeTo: .body).weight(.bold)
    }
    
    /// Black weight Noto Sans
    static func notoSansBlack(size: CGFloat) -> Font {
        return Font.custom("Noto Sans", size: size, relativeTo: .body).weight(.black)
    }
    
    /// Medium weight Noto Sans
    static func notoSansMedium(size: CGFloat) -> Font {
        return Font.custom("Noto Sans", size: size, relativeTo: .body).weight(.medium)
    }
    
    /// Semibold weight Noto Sans
    static func notoSansSemibold(size: CGFloat) -> Font {
        return Font.custom("Noto Sans", size: size, relativeTo: .body).weight(.semibold)
    }
    
    /// Light weight Noto Sans
    static func notoSansLight(size: CGFloat) -> Font {
        return Font.custom("Noto Sans", size: size, relativeTo: .body).weight(.light)
    }
    
    /// Noto Sans with custom line spacing (deprecated - use View modifier instead)
    @available(*, deprecated, message: "Use withNotoSansStyle modifier for line spacing")
    static func notoSansWithLineSpacing(size: CGFloat, lineSpacing: CGFloat = 12) -> Font {
        return Font.custom("Noto Sans", size: size, relativeTo: .body)
    }
}

// MARK: - Safe Font Loading
extension View {
    
    /// Safe font loading with automatic fallback to system font
    func safeFont(_ fontName: String, size: CGFloat, weight: Font.Weight = .regular) -> some View {
        self.modifier(SafeFontModifier(fontName: fontName, size: size, weight: weight))
    }
    
    /// Comprehensive Noto Sans styling with all typography options
    func withNotoSansStyle(
        size: CGFloat,
        weight: Font.Weight = .regular,
        lineSpacing: CGFloat = 0,
        foregroundColor: Color = .white,
        multilineTextAlignment: TextAlignment = .leading,
        lineLimit: Int? = nil
    ) -> some View {
        self.modifier(
            NotoSansStyleModifier(
                size: size,
                weight: weight,
                lineSpacing: lineSpacing,
                foregroundColor: foregroundColor,
                multilineTextAlignment: multilineTextAlignment,
                lineLimit: lineLimit
            )
        )
    }
    
    /// Dynamic font size based on device and accessibility settings
    func adaptiveFont(
        baseSize: CGFloat,
        weight: Font.Weight = .regular,
        category: Font.TextStyle = .body
    ) -> some View {
        self.modifier(AdaptiveFontModifier(baseSize: baseSize, weight: weight, category: category))
    }
}

// MARK: - Font Modifiers
struct SafeFontModifier: ViewModifier {
    let fontName: String
    let size: CGFloat
    let weight: Font.Weight
    
    func body(content: Content) -> some View {
        content
            .font(isFontAvailable(fontName) ? 
                  Font.custom(fontName, size: size).weight(weight) : 
                  Font.system(size: size, weight: weight))
    }
    
    private func isFontAvailable(_ fontName: String) -> Bool {
        return UIFont(name: fontName, size: size) != nil
    }
}

struct NotoSansStyleModifier: ViewModifier {
    let size: CGFloat
    let weight: Font.Weight
    let lineSpacing: CGFloat
    let foregroundColor: Color
    let multilineTextAlignment: TextAlignment
    let lineLimit: Int?
    
    func body(content: Content) -> some View {
        content
            .font(Font.custom("Noto Sans", size: size, relativeTo: .body).weight(weight))
            .lineSpacing(lineSpacing > 0 ? lineSpacing : 0)
            .foregroundColor(foregroundColor)
            .multilineTextAlignment(multilineTextAlignment)
            .lineLimit(lineLimit)
    }
}

struct AdaptiveFontModifier: ViewModifier {
    let baseSize: CGFloat
    let weight: Font.Weight
    let category: Font.TextStyle
    
    @Environment(\.sizeCategory) var sizeCategory
    
    func body(content: Content) -> some View {
        let adaptedSize = adaptSize(baseSize, for: sizeCategory)
        
        content
            .font(Font.custom("Noto Sans", size: adaptedSize, relativeTo: category).weight(weight))
    }
    
    private func adaptSize(_ baseSize: CGFloat, for sizeCategory: ContentSizeCategory) -> CGFloat {
        let scaleFactor: CGFloat
        
        switch sizeCategory {
        case .extraSmall:
            scaleFactor = 0.8
        case .small:
            scaleFactor = 0.9
        case .medium:
            scaleFactor = 1.0
        case .large:
            scaleFactor = 1.1
        case .extraLarge:
            scaleFactor = 1.2
        case .extraExtraLarge:
            scaleFactor = 1.3
        case .extraExtraExtraLarge:
            scaleFactor = 1.4
        case .accessibilityMedium:
            scaleFactor = 1.6
        case .accessibilityLarge:
            scaleFactor = 1.8
        case .accessibilityExtraLarge:
            scaleFactor = 2.0
        case .accessibilityExtraExtraLarge:
            scaleFactor = 2.2
        case .accessibilityExtraExtraExtraLarge:
            scaleFactor = 2.4
        @unknown default:
            scaleFactor = 1.0
        }
        
        return baseSize * scaleFactor
    }
}

// MARK: - Font Manager
@MainActor
class FontManager: ObservableObject {
    
    static let shared = FontManager()
    
    @Published private(set) var isNotoSansAvailable = false
    
    private init() {
        checkFontAvailability()
    }
    
    /// Check if Noto Sans font is available
    private func checkFontAvailability() {
        isNotoSansAvailable = UIFont(name: "Noto Sans", size: 12) != nil
        
        if !isNotoSansAvailable {
            print("⚠️ Noto Sans font not available, falling back to system font")
            printAvailableFonts()
        }
    }
    
    /// Debug helper to print available fonts
    private func printAvailableFonts() {
        #if DEBUG
        print("📝 Available font families:")
        for family in UIFont.familyNames.sorted() {
            print("Family: \(family)")
            for fontName in UIFont.fontNames(forFamilyName: family) {
                print("  - \(fontName)")
            }
        }
        #endif
    }
    
    /// Get the best available font for a given weight
    func getBestFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        if isNotoSansAvailable {
            return Font.custom("Noto Sans", size: size, relativeTo: .body).weight(weight)
        } else {
            return Font.system(size: size, weight: weight)
        }
    }
}

// MARK: - Typography Scale
struct TypographyScale {
    static let h1: CGFloat = 32
    static let h2: CGFloat = 28
    static let h3: CGFloat = 24
    static let h4: CGFloat = 20
    static let h5: CGFloat = 18
    static let h6: CGFloat = 16
    
    static let bodyLarge: CGFloat = 16
    static let body: CGFloat = 14
    static let bodySmall: CGFloat = 12
    
    static let caption: CGFloat = 11
    static let overline: CGFloat = 10
    
    /// Get font size for specific use cases
    static func fontSize(for style: FontStyle) -> CGFloat {
        switch style {
        case .largeTitle: return h1
        case .title: return h2
        case .title2: return h3
        case .title3: return h4
        case .headline: return h5
        case .subheadline: return h6
        case .body: return body
        case .callout: return bodySmall
        case .footnote: return caption
        case .caption: return overline
        case .caption2: return overline
        @unknown default: return body
        }
    }
}

enum FontStyle {
    case largeTitle, title, title2, title3, headline, subheadline
    case body, callout, footnote, caption, caption2
}

// MARK: - Predefined Text Styles
extension View {
    
    /// Apply NFT app specific text styles
    func nftTitleStyle() -> some View {
        self.withNotoSansStyle(
            size: TypographyScale.h3,
            weight: .bold,
            foregroundColor: .white
        )
    }
    
    func nftSubtitleStyle() -> some View {
        self.withNotoSansStyle(
            size: TypographyScale.bodySmall,
            weight: .medium,
            foregroundColor: Color(red: 0.50, green: 0.50, blue: 0.50)
        )
    }
    
    func nftCreatorStyle() -> some View {
        self.withNotoSansStyle(
            size: TypographyScale.caption,
            weight: .regular,
            foregroundColor: .white
        )
    }
    
    func nftUsernameStyle() -> some View {
        self.withNotoSansStyle(
            size: TypographyScale.bodySmall,
            weight: .medium,
            foregroundColor: .white
        )
    }
}