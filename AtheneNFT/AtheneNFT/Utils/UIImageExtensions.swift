import SwiftUI
import UIKit

extension UIImage {
    
    /// A robust image loading function with multiple fallbacks and improved error handling
    static func loadWithFallback(from path: String) -> UIImage? {
        guard !path.isEmpty else {
            print("❌ Empty path provided")
            return nil
        }
        
        let components = path.components(separatedBy: "/")
        let filename = components.last ?? ""
        
        var folderName = ""
        var imageNumber: String?
        
        if components.count >= 2 {
            folderName = components[components.count - 2].replacingOccurrences(of: ".imageset", with: "")
        }
        
        // Improved regex-like extraction for image numbers
        imageNumber = extractImageNumber(from: filename)
        
        // Build comprehensive list of possible paths
        let possiblePaths = buildPossiblePaths(
            originalPath: path,
            filename: filename,
            folderName: folderName,
            imageNumber: imageNumber
        )
        
        // Try each path sequentially
        for tryPath in possiblePaths {
            if let image = UIImage(named: tryPath) {
                print("✅ Successfully loaded image with path: \(tryPath)")
                return image
            }
        }
        
        // Special GIF handling
        if let gifImage = tryLoadGif(imageNumber: imageNumber, folderName: folderName) {
            return gifImage
        }
        
        // Final fallback chain
        return loadFallbackImage(originalPath: path)
    }
    
    /// Extracts image number from various filename formats
    private static func extractImageNumber(from filename: String) -> String? {
        let patterns = ["Image-", "Image@"]
        
        for pattern in patterns {
            if filename.hasPrefix(pattern) {
                let startIndex = filename.index(filename.startIndex, offsetBy: pattern.count)
                let remaining = String(filename[startIndex...])
                
                if let dotIndex = remaining.firstIndex(of: ".") {
                    return String(remaining[..<dotIndex])
                } else {
                    return remaining
                }
            }
        }
        return nil
    }
    
    /// Builds comprehensive list of possible image paths
    private static func buildPossiblePaths(
        originalPath: String,
        filename: String,
        folderName: String,
        imageNumber: String?
    ) -> [String] {
        var paths = [String]()
        
        // Primary paths
        paths.append(originalPath)
        paths.append(filename)
        
        // Priority paths for known folders
        if !folderName.isEmpty, let imgNum = imageNumber {
            paths.append(contentsOf: [
                "\(folderName)/Image@\(imgNum)",
                "\(folderName)/Image-\(imgNum)",
                "\(folderName).imageset/Image@\(imgNum)",
                "\(folderName).imageset/Image-\(imgNum)"
            ])
        }
        
        // Standard category paths
        let categories = ["Cards", "Celebrities", "Doge", "Gifs", "Trending", "New", "NFTs", "Images"]
        
        for category in categories {
            paths.append(contentsOf: [
                "\(category).imageset/\(filename)",
                "\(category)/\(filename)"
            ])
            
            // With image number variations
            if let imgNum = imageNumber {
                let extensions = ["", ".png", ".jpg", ".jpeg", ".gif"]
                for ext in extensions {
                    paths.append(contentsOf: [
                        "\(category)/Image@\(imgNum)\(ext)",
                        "\(category)/Image-\(imgNum)\(ext)",
                        "\(category).imageset/Image@\(imgNum)\(ext)",
                        "\(category).imageset/Image-\(imgNum)\(ext)"
                    ])
                }
            }
        }
        
        // NFT-specific nested paths
        if !folderName.isEmpty, let imgNum = imageNumber {
            let extensions = ["", ".png", ".jpg", ".jpeg", ".gif"]
            for ext in extensions {
                paths.append(contentsOf: [
                    "NFTs/\(folderName)/Image@\(imgNum)\(ext)",
                    "NFTs/\(folderName)/Image-\(imgNum)\(ext)",
                    "NFTs.imageset/\(folderName)/Image@\(imgNum)\(ext)",
                    "NFTs.imageset/\(folderName)/Image-\(imgNum)\(ext)"
                ])
            }
        }
        
        // Generic fallback paths
        if let imgNum = imageNumber {
            paths.append(contentsOf: [
                "Image@\(imgNum)",
                "Image-\(imgNum)"
            ])
        }
        
        return Array(Set(paths)) // Remove duplicates while preserving order
    }
    
    /// Specialized GIF loading with proper error handling
    private static func tryLoadGif(imageNumber: String?, folderName: String) -> UIImage? {
        guard let imgNum = imageNumber, folderName.lowercased() == "gifs" else { return nil }
        
        let gifVariations = ["Image@\(imgNum)", "Image-\(imgNum)"]
        let subdirectories = ["Gifs.imageset", "Gifs", nil]
        
        for gifName in gifVariations {
            for subdirectory in subdirectories {
                if let url = Bundle.main.url(forResource: gifName, withExtension: "gif", subdirectory: subdirectory),
                   let data = try? Data(contentsOf: url),
                   let gifImage = UIImage(data: data) {
                    print("✅ Loaded GIF: \(gifName) from \(subdirectory ?? "root")")
                    return gifImage
                }
            }
        }
        
        return nil
    }
    
    /// Provides fallback images with logging
    private static func loadFallbackImage(originalPath: String) -> UIImage? {
        let fallbacks = ["nft-image", "placeholder", "default-nft"]
        
        for fallback in fallbacks {
            if let image = UIImage(named: fallback) {
                print("⚠️ Using fallback image '\(fallback)' for: \(originalPath)")
                return image
            }
        }
        
        print("❌ No fallback available for: \(originalPath)")
        return nil
    }
    
    /// Gets a random image from a specific category with improved logic
    static func randomImage(from category: String) -> UIImage? {
        let baseFolderName = category.replacingOccurrences(of: ".imageset", with: "")
        let imageNumber = getRandomImageNumber(for: baseFolderName)
        
        let possibleFormats = ["Image@\(imageNumber)", "Image-\(imageNumber)"]
        let possibleFolders = [baseFolderName, "\(baseFolderName).imageset"]
        
        // Try different combinations
        for folder in possibleFolders {
            for format in possibleFormats {
                let imagePath = "\(folder)/\(format)"
                if let image = loadWithFallback(from: imagePath) {
                    print("✅ Loaded random image: \(imagePath)")
                    return image
                }
            }
        }
        
        // Final fallback
        print("⚠️ Using fallback for random image from category: \(category)")
        return loadWithFallback(from: "nft-image")
    }
    
    /// Centralized random number generation for categories
    private static func getRandomImageNumber(for category: String) -> Int {
        switch category.lowercased() {
        case "doge":
            return Int.random(in: 15...18)
        case "cards":
            return [9, 10, 12, 13].randomElement() ?? 9
        case "gifs":
            return [1, 3, 6, 7, 8, 22, 23, 25].randomElement() ?? 1
        case "celebrities":
            return Int.random(in: 2...5)
        case "trending":
            return Int.random(in: 19...21)
        case "new":
            return 24
        case "nfts":
            return Int.random(in: 1...30)
        default:
            return Int.random(in: 1...25)
        }
    }
    
    /// Convenience method to check if image exists without loading
    static func imageExists(named name: String) -> Bool {
        return UIImage(named: name) != nil
    }
    
    /// Preload images for better performance
    static func preloadImages(_ imageNames: [String]) {
        DispatchQueue.global(qos: .background).async {
            for imageName in imageNames {
                _ = loadWithFallback(from: imageName)
            }
        }
    }
}