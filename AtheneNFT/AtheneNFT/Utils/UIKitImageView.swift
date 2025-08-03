import SwiftUI
import UIKit

// MARK: - Image Loading Utility
struct ImageLoader {
    static func loadImage(named imageName: String) -> UIImage? {
        // Direct asset name lookup first
        if let image = UIImage(named: imageName) {
            return image
        }
        
        // Map common names to actual assets
        let assetMapping: [String: String] = [
            "Profile": "Profile",
            "profile": "Profile", 
            "profile-image": "Profile",
            "New": "New",
            "new": "New",
            "Trending": "Trending", 
            "trending": "Trending",
            "Cards": "Cards",
            "cards": "Cards",
            "Doge": "Doge",
            "doge": "Doge",
            "Gifs": "Gifs", 
            "gifs": "Gifs",
            "Celebrities": "Celebrities",
            "celebrities": "Celebrities"
        ]
        
        // Try mapped asset name
        if let mappedName = assetMapping[imageName] {
            if let image = UIImage(named: mappedName) {
                return image
            }
        }
        
        // Try various fallback combinations
        let variations = [
            imageName,
            imageName.components(separatedBy: "/").last ?? imageName,
            imageName.replacingOccurrences(of: "/", with: ""),
            imageName.replacingOccurrences(of: "Image@", with: ""),
            imageName.replacingOccurrences(of: "@", with: ""),
            "New", "Trending", "Cards", "Doge", "Gifs", "Celebrities", "Profile"
        ]
        
        for variation in variations {
            if let image = UIImage(named: variation) {
                return image
            }
        }
        
        return nil
    }
    
    static func createPlaceholder(size: CGSize = CGSize(width: 200, height: 200)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            // Background gradient
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                    colors: [
                                        UIColor(red: 0.2, green: 0.15, blue: 0.3, alpha: 1.0).cgColor,
                                        UIColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0).cgColor
                                    ] as CFArray,
                                    locations: [0.0, 1.0])!
            
            context.cgContext.drawLinearGradient(gradient,
                                               start: CGPoint(x: 0, y: 0),
                                               end: CGPoint(x: size.width, y: size.height),
                                               options: [])
            
            // Add icon
            let iconSize = min(size.width, size.height) * 0.3
            let iconRect = CGRect(
                x: (size.width - iconSize) / 2,
                y: (size.height - iconSize) / 2,
                width: iconSize,
                height: iconSize
            )
            
            UIColor.white.withAlphaComponent(0.6).setFill()
            context.cgContext.fillEllipse(in: iconRect)
        }
    }
}

// MARK: - Dynamic Sizing Utility
struct DynamicSizing {
    static func fontSize(base: CGFloat, geometry: GeometryProxy) -> CGFloat {
        let screenWidth = geometry.size.width
        let scaleFactor = min(screenWidth / 390, 1.3)
        return base * scaleFactor
    }
    
    static func size(base: CGFloat, geometry: GeometryProxy) -> CGFloat {
        let screenWidth = geometry.size.width
        let scaleFactor = min(screenWidth / 390, 1.3)
        return base * scaleFactor
    }
    
    static func padding(base: CGFloat, geometry: GeometryProxy) -> CGFloat {
        let screenWidth = geometry.size.width
        let scaleFactor = min(screenWidth / 390, 1.3)
        return base * scaleFactor
    }
    
    static func spacing(base: CGFloat, geometry: GeometryProxy) -> CGFloat {
        let screenWidth = geometry.size.width
        let scaleFactor = min(screenWidth / 390, 1.3)
        return base * scaleFactor
    }
}

// MARK: - Enhanced AsyncImage with Fallback
struct FallbackAsyncImage: View {
    let imageName: String
    let size: CGSize?
    let contentMode: ContentMode
    let cornerRadius: CGFloat
    
    init(
        imageName: String, 
        size: CGSize? = nil, 
        contentMode: ContentMode = .fill,
        cornerRadius: CGFloat = 0
    ) {
        self.imageName = imageName
        self.size = size
        self.contentMode = contentMode
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        Group {
            if let image = ImageLoader.loadImage(named: imageName) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                // Placeholder with gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.2, green: 0.15, blue: 0.3),
                        Color(red: 0.1, green: 0.1, blue: 0.2)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay(
                    VStack(spacing: 8) {
                        Image(systemName: "photo.artframe")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.6))
                        Text(imageName.components(separatedBy: "/").last?.components(separatedBy: "@").last ?? "NFT")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                )
            }
        }
        .if(size) { view, size in
            view.frame(width: size.width, height: size.height)
        }
        .clipped()
        .cornerRadius(cornerRadius)
    }
}

// MARK: - Conditional View Modifier
extension View {
    @ViewBuilder
    func `if`<T, Content: View>(_ optionalValue: T?, transform: (Self, T) -> Content) -> some View {
        if let value = optionalValue {
            transform(self, value)
        } else {
            self
        }
    }
}