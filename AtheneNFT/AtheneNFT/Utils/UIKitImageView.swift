import SwiftUI
import UIKit
import Combine

// MARK: - UIImage Extension
extension UIImage {
    static func loadWithFallback(from imageName: String) -> UIImage? {
        // Try different file extensions
        let extensions = ["", ".png", ".jpg", ".jpeg", ".gif", ".webp"]
        
        for ext in extensions {
            let fullName = imageName + ext
            if let image = UIImage(named: fullName) {
                print("✅ Successfully loaded image: \(fullName)")
                return image
            }
        }
        
        print("❌ Failed to load image: \(imageName)")
        return nil
    }
    
    static func createPlaceholder(size: CGSize, backgroundColor: UIColor = UIColor.systemGray5) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            backgroundColor.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Add placeholder icon
            let iconSize = min(size.width, size.height) * 0.3
            let iconRect = CGRect(
                x: (size.width - iconSize) / 2,
                y: (size.height - iconSize) / 2,
                width: iconSize,
                height: iconSize
            )
            
            UIColor.systemGray3.setFill()
            context.cgContext.fillEllipse(in: iconRect)
            
            // Add smaller inner circle
            let innerSize = iconSize * 0.5
            let innerRect = CGRect(
                x: (size.width - innerSize) / 2,
                y: (size.height - innerSize) / 2,
                width: innerSize,
                height: innerSize
            )
            
            UIColor.systemGray4.setFill()
            context.cgContext.fillEllipse(in: innerRect)
        }
    }
}

// MARK: - Shadow Configuration
struct ShadowConfig {
    let color: UIColor
    let offset: CGSize
    let opacity: Float
    let radius: CGFloat
    
    static let `default` = ShadowConfig(
        color: .black,
        offset: CGSize(width: 0, height: 4),
        opacity: 0.25,
        radius: 4
    )
    
    static let subtle = ShadowConfig(
        color: .black,
        offset: CGSize(width: 0, height: 2),
        opacity: 0.1,
        radius: 2
    )
    
    static let dramatic = ShadowConfig(
        color: .black,
        offset: CGSize(width: 0, height: 8),
        opacity: 0.4,
        radius: 8
    )
    
    static let nftCard = ShadowConfig(
        color: .black,
        offset: CGSize(width: 0, height: 6),
        opacity: 0.15,
        radius: 12
    )
}

// MARK: - Main UIKitImageView Component
struct UIKitImageView: UIViewRepresentable {
    let imageName: String
    let width: CGFloat
    let height: CGFloat
    let leadingOffset: CGFloat
    let topOffset: CGFloat
    let contentMode: UIView.ContentMode
    let transform: CGAffineTransform?
    let cornerRadius: CGFloat
    let shadowConfig: ShadowConfig?
    let animationDuration: TimeInterval
    
    init(
        imageName: String,
        width: CGFloat = 220.4,
        height: CGFloat = 243.6,
        leadingOffset: CGFloat = 70,
        topOffset: CGFloat = 72.6,
        contentMode: UIView.ContentMode = .scaleAspectFill,
        transform: CGAffineTransform? = nil,
        cornerRadius: CGFloat = 0,
        shadowConfig: ShadowConfig? = nil,
        animationDuration: TimeInterval = 0.3
    ) {
        self.imageName = imageName
        self.width = width
        self.height = height
        self.leadingOffset = leadingOffset
        self.topOffset = topOffset
        self.contentMode = contentMode
        self.transform = transform
        self.cornerRadius = cornerRadius
        self.shadowConfig = shadowConfig
        self.animationDuration = animationDuration
    }
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .clear
        
        // Create and configure the image view
        let imageView = createImageView()
        styleImageView(imageView)
        positionImageView(imageView, in: containerView)
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Find the image view and update it
        if let imageView = findImageView(in: uiView) {
            updateImageContent(imageView)
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func createImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        imageView.contentMode = contentMode
        imageView.clipsToBounds = true
        imageView.tag = 999 // Tag for easy identification
        
        loadImageContent(into: imageView)
        return imageView
    }
    
    private func loadImageContent(into imageView: UIImageView) {
        if let image = loadImageWithFallbacks() {
            imageView.image = image
            imageView.backgroundColor = .clear
        } else {
            // Set enhanced placeholder
            let placeholderSize = CGSize(width: width, height: height)
            imageView.image = UIImage.createPlaceholder(
                size: placeholderSize,
                backgroundColor: UIColor(red: 0.5, green: 0.23, blue: 0.27, alpha: 0.5)
            )
        }
    }
    
    private func loadImageWithFallbacks() -> UIImage? {
        // Try UIImage extension with fallbacks
        if let image = UIImage.loadWithFallback(from: imageName) {
            return image
        }
        
        // If that fails, create a placeholder
        return UIImage.createPlaceholder(
            size: CGSize(width: width, height: height),
            backgroundColor: UIColor(red: 0.5, green: 0.23, blue: 0.27, alpha: 0.5)
        )
    }
    
    private func styleImageView(_ imageView: UIImageView) {
        // Apply corner radius
        if cornerRadius > 0 {
            imageView.layer.cornerRadius = cornerRadius
            imageView.layer.masksToBounds = true
        }
        
        // Apply transform with animation
        let finalTransform = transform ?? CGAffineTransform(a: 1, b: 0, c: 0, d: 1.36, tx: 0, ty: -0.18)
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut) {
            imageView.transform = finalTransform
        }
        
        // Apply shadow (shadows need to be on a parent view when using masksToBounds)
        if let shadowConfig = shadowConfig {
            applyShadow(to: imageView, config: shadowConfig)
        }
        
        // Add subtle border
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor(red: 0.90, green: 0.91, blue: 0.92, alpha: 1.0).cgColor
    }
    
    private func positionImageView(_ imageView: UIImageView, in container: UIView) {
        let wrapperView = UIView()
        wrapperView.backgroundColor = .clear
        wrapperView.tag = 998 // Tag for easy identification
        
        // For shadows to work properly with clipped content
        if shadowConfig != nil {
            wrapperView.layer.shadowColor = shadowConfig?.color.cgColor
            wrapperView.layer.shadowOffset = shadowConfig?.offset ?? CGSize.zero
            wrapperView.layer.shadowOpacity = shadowConfig?.opacity ?? 0
            wrapperView.layer.shadowRadius = shadowConfig?.radius ?? 0
            wrapperView.layer.masksToBounds = false
        }
        
        wrapperView.addSubview(imageView)
        container.addSubview(wrapperView)
        
        // Setup Auto Layout constraints
        imageView.translatesAutoresizingMaskIntoConstraints = false
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Image view constraints (centered in wrapper)
            imageView.widthAnchor.constraint(equalToConstant: width),
            imageView.heightAnchor.constraint(equalToConstant: height),
            imageView.centerXAnchor.constraint(equalTo: wrapperView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: wrapperView.centerYAnchor),
            
            // Wrapper view constraints (positioned in container)
            wrapperView.widthAnchor.constraint(equalToConstant: width),
            wrapperView.heightAnchor.constraint(equalToConstant: height),
            wrapperView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: leadingOffset),
            wrapperView.topAnchor.constraint(equalTo: container.topAnchor, constant: topOffset)
        ])
    }
    
    private func findImageView(in containerView: UIView) -> UIImageView? {
        // Search for the image view by tag
        return containerView.viewWithTag(999) as? UIImageView ??
               containerView.subviews.compactMap { $0.viewWithTag(999) as? UIImageView }.first
    }
    
    private func updateImageContent(_ imageView: UIImageView) {
        // Smooth image transition animation
        UIView.transition(
            with: imageView,
            duration: animationDuration,
            options: [.transitionCrossDissolve, .allowUserInteraction]
        ) {
            self.loadImageContent(into: imageView)
        }
    }
    
    private func applyShadow(to view: UIImageView, config: ShadowConfig) {
        // Note: This applies shadow directly to the image view
        // For better shadow rendering with corner radius, consider applying to parent view
        view.layer.shadowColor = config.color.cgColor
        view.layer.shadowOffset = config.offset
        view.layer.shadowOpacity = config.opacity
        view.layer.shadowRadius = config.radius
        
        // Create shadow path for better performance
        if cornerRadius > 0 {
            view.layer.shadowPath = UIBezierPath(
                roundedRect: view.bounds,
                cornerRadius: cornerRadius
            ).cgPath
        }
    }
}

// MARK: - Convenience Factory Methods
extension UIKitImageView {
    
    /// NFT card optimized for marketplace display
    static func nftCard(
        imageName: String,
        size: CGSize = CGSize(width: 343, height: 253)
    ) -> UIKitImageView {
        return UIKitImageView(
            imageName: imageName,
            width: size.width,
            height: size.height,
            leadingOffset: 0,
            topOffset: 0,
            contentMode: .scaleAspectFill,
            cornerRadius: 12,
            shadowConfig: .nftCard
        )
    }
    
    /// Profile image with circular clipping
    static func profileImage(
        imageName: String,
        size: CGFloat = 36
    ) -> UIKitImageView {
        return UIKitImageView(
            imageName: imageName,
            width: size,
            height: size,
            leadingOffset: 0,
            topOffset: 0,
            contentMode: .scaleAspectFill,
            cornerRadius: size / 2,
            shadowConfig: .subtle
        )
    }
    
    /// Thumbnail with rounded corners
    static func thumbnail(
        imageName: String,
        size: CGFloat = 60
    ) -> UIKitImageView {
        return UIKitImageView(
            imageName: imageName,
            width: size,
            height: size,
            leadingOffset: 0,
            topOffset: 0,
            contentMode: .scaleAspectFill,
            cornerRadius: 8,
            shadowConfig: .subtle
        )
    }
    
    /// Hero image for large displays
    static func heroImage(
        imageName: String,
        width: CGFloat = 375,
        height: CGFloat = 200
    ) -> UIKitImageView {
        return UIKitImageView(
            imageName: imageName,
            width: width,
            height: height,
            leadingOffset: 0,
            topOffset: 0,
            contentMode: .scaleAspectFill,
            cornerRadius: 16,
            shadowConfig: .dramatic
        )
    }
    
    /// Card image with standard proportions
    static func cardImage(
        imageName: String,
        aspectRatio: CGFloat = 1.0
    ) -> UIKitImageView {
        let size: CGFloat = 150
        return UIKitImageView(
            imageName: imageName,
            width: size,
            height: size * aspectRatio,
            leadingOffset: 0,
            topOffset: 0,
            contentMode: .scaleAspectFill,
            cornerRadius: 10,
            shadowConfig: .default
        )
    }
}

// MARK: - Error Handling and Debugging
extension UIKitImageView {
    
    /// Debug version that prints loading attempts
    static func debug(
        imageName: String,
        width: CGFloat = 220.4,
        height: CGFloat = 243.6
    ) -> UIKitImageView {
        print("🔍 Creating UIKitImageView for: \(imageName)")
        return UIKitImageView(
            imageName: imageName,
            width: width,
            height: height,
            cornerRadius: 8,
            shadowConfig: .subtle
        )
    }
}

// MARK: - SwiftUI Preview
struct UIKitImageView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 30) {
                // NFT Card Example
                VStack(alignment: .leading, spacing: 8) {
                    Text("NFT Card")
                        .font(.headline)
                        .foregroundColor(.white)
                    UIKitImageView.nftCard(imageName: "sample-nft")
                }
                
                // Profile Images Row
                VStack(alignment: .leading, spacing: 8) {
                    Text("Profile Images")
                        .font(.headline)
                        .foregroundColor(.white)
                    HStack(spacing: 16) {
                        UIKitImageView.profileImage(imageName: "profile1", size: 40)
                        UIKitImageView.profileImage(imageName: "profile2", size: 50)
                        UIKitImageView.profileImage(imageName: "profile3", size: 60)
                    }
                }
                
                // Thumbnails Row
                VStack(alignment: .leading, spacing: 8) {
                    Text("Thumbnails")
                        .font(.headline)
                        .foregroundColor(.white)
                    HStack(spacing: 12) {
                        UIKitImageView.thumbnail(imageName: "thumb1", size: 60)
                        UIKitImageView.thumbnail(imageName: "thumb2", size: 80)
                        UIKitImageView.thumbnail(imageName: "thumb3", size: 100)
                    }
                }
                
                // Hero Image
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hero Image")
                        .font(.headline)
                        .foregroundColor(.white)
                    UIKitImageView.heroImage(imageName: "hero-image")
                }
                
                // Custom Configuration Example
                VStack(alignment: .leading, spacing: 8) {
                    Text("Custom Configuration")
                        .font(.headline)
                        .foregroundColor(.white)
                    UIKitImageView(
                        imageName: "custom-image",
                        width: 200,
                        height: 150,
                        contentMode: .scaleAspectFit,
                        transform: CGAffineTransform(rotationAngle: .pi / 12),
                        cornerRadius: 20,
                        shadowConfig: .dramatic,
                        animationDuration: 0.5
                    )
                }
                
                Spacer(minLength: 50)
            }
            .padding()
        }
        .background(
            LinearGradient(
                colors: [Color.black, Color(red: 0.1, green: 0.1, blue: 0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .onAppear {
            // Preload test images
            let _ = [
                "sample-nft", "profile1", "profile2", "profile3",
                "thumb1", "thumb2", "thumb3", "hero-image", "custom-image"
            ].forEach { UIImage.loadWithFallback(from: $0) }
        }
    }
}