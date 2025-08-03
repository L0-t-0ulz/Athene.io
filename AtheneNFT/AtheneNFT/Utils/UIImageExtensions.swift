import UIKit
import SwiftUI

// MARK: - UIImage Extensions
extension UIImage {
    
    /// Create a image with given color and size
    static func create(withColor color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
    
    /// Resize image to specific size
    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    /// Create circular image
    func circularImage() -> UIImage {
        let size = CGSize(width: min(self.size.width, self.size.height), height: min(self.size.width, self.size.height))
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            context.cgContext.addEllipse(in: rect)
            context.cgContext.clip()
            self.draw(in: rect)
        }
    }
    
    /// Add corner radius to image
    func withRoundedCorners(radius: CGFloat) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: radius)
            context.cgContext.addPath(path.cgPath)
            context.cgContext.clip()
            self.draw(in: rect)
        }
    }
    
    /// Compress image to specified quality
    func compressed(quality: CGFloat = 0.8) -> Data? {
        return self.jpegData(compressionQuality: quality)
    }
    
    /// Create thumbnail with specified size
    func thumbnail(size: CGSize) -> UIImage {
        let aspectRatio = self.size.width / self.size.height
        var thumbnailSize = size
        
        if aspectRatio > 1 {
            // Landscape
            thumbnailSize.height = size.width / aspectRatio
        } else {
            // Portrait
            thumbnailSize.width = size.height * aspectRatio
        }
        
        return resized(to: thumbnailSize)
    }
}

// MARK: - Image Processing
extension UIImage {
    
    /// Apply blur effect
    func blurred(radius: CGFloat = 10) -> UIImage? {
        guard let ciImage = CIImage(image: self) else { return nil }
        
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(radius, forKey: kCIInputRadiusKey)
        
        guard let outputImage = filter?.outputImage else { return nil }
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    /// Adjust brightness
    func brightness(value: Float) -> UIImage? {
        guard let ciImage = CIImage(image: self) else { return nil }
        
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(value, forKey: kCIInputBrightnessKey)
        
        guard let outputImage = filter?.outputImage else { return nil }
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    /// Convert to grayscale
    func grayscale() -> UIImage? {
        guard let ciImage = CIImage(image: self) else { return nil }
        
        let filter = CIFilter(name: "CIColorMonochrome")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(CIColor.gray, forKey: kCIInputColorKey)
        filter?.setValue(1.0, forKey: kCIInputIntensityKey)
        
        guard let outputImage = filter?.outputImage else { return nil }
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
}

// MARK: - NFT Specific Image Utilities
extension UIImage {
    
    /// Create NFT placeholder image
    static func nftPlaceholder(size: CGSize = CGSize(width: 200, height: 200)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            // Background gradient
            let colors = [
                UIColor(red: 0.2, green: 0.15, blue: 0.3, alpha: 1.0).cgColor,
                UIColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0).cgColor
            ]
            
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                    colors: colors as CFArray,
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
    
    /// Create profile placeholder
    static func profilePlaceholder(size: CGSize = CGSize(width: 40, height: 40), initials: String = "U") -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            // Background circle
            let colors = [
                UIColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0).cgColor,
                UIColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 1.0).cgColor
            ]
            
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                    colors: colors as CFArray,
                                    locations: [0.0, 1.0])!
            
            let rect = CGRect(origin: .zero, size: size)
            context.cgContext.addEllipse(in: rect)
            context.cgContext.clip()
            
            context.cgContext.drawRadialGradient(gradient,
                                               startCenter: CGPoint(x: size.width * 0.3, y: size.height * 0.3),
                                               startRadius: 0,
                                               endCenter: CGPoint(x: size.width * 0.5, y: size.height * 0.5),
                                               endRadius: size.width * 0.7,
                                               options: [])
            
            // Add initials
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: size.width * 0.4, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            
            let text = NSAttributedString(string: initials.uppercased(), attributes: attributes)
            let textSize = text.size()
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            
            text.draw(in: textRect)
        }
    }
}

// MARK: - SwiftUI Integration
extension Image {
    
    /// Initialize from UIImage with fallback
    init?(uiImage: UIImage?) {
        guard let uiImage = uiImage else { return nil }
        self.init(uiImage: uiImage)
    }
    
    /// Apply NFT card styling
    func nftCardStyle() -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fill)
            .clipped()
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
    
    /// Apply profile image styling
    func profileImageStyle(size: CGFloat = 40) -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
}

// MARK: - Image Loading Utilities
struct ImageLoadingUtility {
    
    /// Load image from URL with caching
    static func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            let image = UIImage(data: data)
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
    
    /// Save image to documents directory
    static func saveImage(_ image: UIImage, withName name: String) -> Bool {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return false
        }
        
        let fileName = name + ".jpg"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            return false
        }
        
        do {
            try data.write(to: fileURL)
            return true
        } catch {
            return false
        }
    }
    
    /// Load image from documents directory
    static func loadImage(withName name: String) -> UIImage? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let fileName = name + ".jpg"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        return UIImage(contentsOfFile: fileURL.path)
    }
}