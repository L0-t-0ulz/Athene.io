import SwiftUI
import UIKit
import Combine

/// A centralized, thread-safe utility for loading images with caching and async support
@MainActor
class ImageLoader: ObservableObject {
    
    /// Shared singleton instance
    static let shared = ImageLoader()
    
    /// Thread-safe image cache with memory management
    private let imageCache = NSCache<NSString, UIImage>()
    
    /// Set to track currently loading images to prevent duplicate requests
    private var loadingImages = Set<String>()
    
    /// Published property for SwiftUI reactive updates
    @Published private(set) var loadedImages: [String: UIImage] = [:]
    
    private init() {
        configureCache()
    }
    
    /// Configure cache settings for optimal memory usage
    private func configureCache() {
        imageCache.countLimit = 100 // Limit number of cached images
        imageCache.totalCostLimit = 50 * 1024 * 1024 // 50MB memory limit
    }
    
    /// Main synchronous image loading function with enhanced fallback logic
    func loadImage(named name: String) -> UIImage? {
        guard !name.isEmpty else { return nil }
        
        let cacheKey = name as NSString
        
        // Check cache first
        if let cachedImage = imageCache.object(forKey: cacheKey) {
            return cachedImage
        }
        
        // Attempt to find and load the image
        guard let image = findImage(for: name) else {
            print("❌ Failed to load image: \(name)")
            return loadFallbackImage()
        }
        
        // Cache the successfully loaded image
        cacheImage(image, forKey: cacheKey)
        
        return image
    }
    
    /// Async image loading for better performance in lists/grids
    func loadImageAsync(named name: String) async -> UIImage? {
        // Check if already loading
        if loadingImages.contains(name) {
            // Wait a bit and try cache again
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            return imageCache.object(forKey: name as NSString)
        }
        
        loadingImages.insert(name)
        defer { loadingImages.remove(name) }
        
        return await Task.detached {
            return await MainActor.run {
                self.loadImage(named: name)
            }
        }.value
    }
    
    /// Enhanced image finding with comprehensive path resolution
    private func findImage(for name: String) -> UIImage? {
        let searchPaths = generateSearchPaths(for: name)
        
        // Try each path in order of priority
        for path in searchPaths {
            if let image = UIImage(named: path) {
                print("✅ Successfully loaded image: \(path)")
                return image
            }
        }
        
        // Special handling for animated images (GIFs)
        if let gifImage = loadAnimatedImage(for: name) {
            return gifImage
        }
        
        return nil
    }
    
    /// Generate comprehensive list of possible image paths
    private func generateSearchPaths(for name: String) -> [String] {
        var paths = [String]()
        
        // Original name variations
        paths.append(contentsOf: [
            name,
            name.replacingOccurrences(of: "@", with: "-"),
            name.replacingOccurrences(of: "-", with: "@")
        ])
        
        // Add common file extensions
        let extensions = ["png", "jpg", "jpeg", "gif", "heic"]
        for ext in extensions {
            paths.append("\(name).\(ext)")
        }
        
        // Extract components for folder-based searches
        let components = name.components(separatedBy: "/")
        let filename = components.last ?? name
        
        // Category-based paths
        let categories = [
            "Cards", "Celebrities", "Doge", "Gifs", "Trending", "New", "NFTs", "Images"
        ]
        
        for category in categories {
            paths.append(contentsOf: [
                "\(category)/\(filename)",
                "\(category).imageset/\(filename)",
                "\(category)/\(name)",
                "\(category).imageset/\(name)"
            ])
        }
        
        // Extract image numbers for numbered assets
        if let imageNumber = extractImageNumber(from: filename) {
            // Add numbered variations
            for category in categories {
                paths.append(contentsOf: [
                    "\(category)/Image@\(imageNumber)",
                    "\(category)/Image-\(imageNumber)",
                    "\(category).imageset/Image@\(imageNumber)",
                    "\(category).imageset/Image-\(imageNumber)"
                ])
                
                // Add with extensions
                for ext in extensions {
                    paths.append(contentsOf: [
                        "\(category)/Image@\(imageNumber).\(ext)",
                        "\(category)/Image-\(imageNumber).\(ext)"
                    ])
                }
            }
            
            // Direct numbered paths
            paths.append(contentsOf: [
                "Image@\(imageNumber)",
                "Image-\(imageNumber)"
            ])
        }
        
        // Remove duplicates while preserving order
        return Array(OrderedSet(paths))
    }
    
    /// Extract image number from filename using improved logic
    private func extractImageNumber(from filename: String) -> String? {
        let patterns = [
            ("Image-", 6),
            ("Image@", 6),
            ("image-", 6),
            ("image@", 6)
        ]
        
        for (pattern, offset) in patterns {
            if filename.lowercased().hasPrefix(pattern.lowercased()) {
                let startIndex = filename.index(filename.startIndex, offsetBy: offset)
                let remaining = String(filename[startIndex...])
                
                // Find the number part (before extension or end)
                let numberString = remaining.components(separatedBy: CharacterSet.decimalDigits.inverted).first ?? ""
                
                if !numberString.isEmpty {
                    return numberString
                }
            }
        }
        
        return nil
    }
    
    /// Enhanced GIF loading with multiple fallback strategies
    private func loadAnimatedImage(for name: String) -> UIImage? {
        let gifSearchPaths = [
            name,
            "\(name).gif",
            "Gifs/\(name)",
            "Gifs.imageset/\(name)",
            "Gifs/\(name).gif",
            "Gifs.imageset/\(name).gif"
        ]
        
        for gifPath in gifSearchPaths {
            // Try bundle URL approach
            let pathComponents = gifPath.components(separatedBy: "/")
            let resourceName = pathComponents.last?.replacingOccurrences(of: ".gif", with: "") ?? gifPath
            let subdirectory = pathComponents.count > 1 ? pathComponents.dropLast().joined(separator: "/") : nil
            
            if let url = Bundle.main.url(forResource: resourceName, withExtension: "gif", subdirectory: subdirectory),
               let data = try? Data(contentsOf: url),
               let gifImage = UIImage(data: data) {
                print("✅ Successfully loaded GIF: \(gifPath)")
                return gifImage
            }
        }
        
        return nil
    }
    
    /// Load fallback image with multiple options
    private func loadFallbackImage() -> UIImage? {
        let fallbacks = ["nft-image", "placeholder", "default-image", "missing-image"]
        
        for fallback in fallbacks {
            if let image = UIImage(named: fallback) {
                print("⚠️ Using fallback image: \(fallback)")
                return image
            }
        }
        
        // Create a programmatic fallback if no fallback images exist
        return createProgrammaticFallback()
    }
    
    /// Create a simple programmatic fallback image
    private func createProgrammaticFallback() -> UIImage? {
        let size = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Gray background
            UIColor.systemGray4.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Simple icon
            UIColor.systemGray2.setStroke()
            let rect = CGRect(x: 20, y: 20, width: 60, height: 60)
            context.cgContext.strokeEllipse(in: rect)
        }
    }
    
    /// Cache image with cost calculation
    private func cacheImage(_ image: UIImage, forKey key: NSString) {
        let cost = Int(image.size.width * image.size.height * 4) // Approximate memory cost
        imageCache.setObject(image, forKey: key, cost: cost)
        
        // Update published property for SwiftUI
        loadedImages[key as String] = image
    }
    
    /// Get random image from category with improved selection
    func randomImage(from category: String) -> UIImage? {
        let cleanCategory = category.replacingOccurrences(of: ".imageset", with: "")
        let availableNumbers = getAvailableImageNumbers(for: cleanCategory)
        
        guard let randomNumber = availableNumbers.randomElement() else {
            return loadFallbackImage()
        }
        
        let imagePath = "\(cleanCategory)/Image@\(randomNumber)"
        return loadImage(named: imagePath)
    }
    
    /// Get available image numbers for each category
    private func getAvailableImageNumbers(for category: String) -> [Int] {
        switch category.lowercased() {
        case "doge":
            return Array(15...18)
        case "cards":
            return [9, 10, 12, 13]
        case "gifs":
            return [1, 3, 6, 7, 8, 22, 23, 25]
        case "celebrities":
            return Array(2...5)
        case "trending":
            return Array(19...21)
        case "new":
            return [24]
        case "nfts":
            return Array(1...30)
        default:
            return Array(1...25)
        }
    }
    
    /// Clear cache when memory pressure occurs
    func clearCache() {
        imageCache.removeAllObjects()
        loadedImages.removeAll()
        print("🧹 Image cache cleared")
    }
    
    /// Preload images for better user experience
    func preloadImages(_ imageNames: [String]) {
        Task {
            for imageName in imageNames {
                _ = await loadImageAsync(named: imageName)
            }
        }
    }
}

/// Helper for maintaining order in sets
private struct OrderedSet<T: Hashable>: Sequence {
    private var elements: [T] = []
    private var elementSet: Set<T> = []
    
    init(_ sequence: some Sequence<T>) {
        for element in sequence {
            if elementSet.insert(element).inserted {
                elements.append(element)
            }
        }
    }
    
    func makeIterator() -> Array<T>.Iterator {
        return elements.makeIterator()
    }
}

/// SwiftUI-friendly async image view
struct AsyncImageView: View {
    let imageName: String
    let placeholder: Image?
    
    @StateObject private var loader = ImageLoader.shared
    @State private var loadedImage: UIImage?
    @State private var isLoading = true
    
    init(imageName: String, placeholder: Image? = nil) {
        self.imageName = imageName
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let image = loadedImage {
                Image(uiImage: image)
                    .resizable()
            } else if isLoading {
                placeholder ?? Image(systemName: "photo")
                    .foregroundColor(.gray)
            } else {
                placeholder ?? Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.red)
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        loadedImage = await loader.loadImageAsync(named: imageName)
        isLoading = false
    }
}