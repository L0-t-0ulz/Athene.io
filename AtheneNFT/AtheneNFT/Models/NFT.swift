import Foundation

// MARK: - Core Models
struct NFT: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let imageURL: String
    let price: Double
    var creator: User
    let createdAt: Date
    let blockchain: BlockchainType
    let contract: String?
    let tokenId: String?
    var isLiked: Bool = false
    var likeCount: Int = 0
    var isCollected: Bool = false
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: NFT, rhs: NFT) -> Bool {
        lhs.id == rhs.id
    }
    
    // Computed properties
    var formattedPrice: String {
        return String(format: "%.2f ETH", price)
    }
    
    var validImageURL: URL? {
        return URL(string: imageURL)
    }
    
    var isNew: Bool {
        let daysSinceCreation = Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day ?? 0
        return daysSinceCreation <= 7
    }
}

// MARK: - NFTItem (Simplified NFT model for UI components)
struct NFTItem: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let creator: String
    let creatorUsername: String
    let imageName: String
    
    static func == (lhs: NFTItem, rhs: NFTItem) -> Bool {
        lhs.id == rhs.id
    }
    
    // Create from NFT model
    init(from nft: NFT) {
        self.title = nft.title
        self.creator = nft.creator.displayName
        self.creatorUsername = nft.creator.displayUsername
        self.imageName = nft.imageURL.components(separatedBy: "/").last ?? "nft-image"
    }
    
    // Create directly
    init(title: String, creator: String, creatorUsername: String, imageName: String) {
        self.title = title
        self.creator = creator
        self.creatorUsername = creatorUsername
        self.imageName = imageName
    }
}

// MARK: - Sample Data Generation
func generateSampleNFTItems(count: Int, startIndex: Int = 0) -> [NFTItem] {
    let sampleTitles = [
        "Cryptopunk Heritage", "Digital Dreams", "Neon Genesis", "Pixel Paradise",
        "Cyber Samurai", "Virtual Visions", "Meta Masterpiece", "Blockchain Beauty",
        "Token Treasure", "Digital Dynasty", "NFT Noir", "Pixel Poetry",
        "Crypto Canvas", "Virtual Velocity", "Digital Dimension"
    ]
    
    let sampleCreators = [
        "@ArtMaster", "@CryptoKing", "@PixelPro", "@NFTNinja",
        "@DigitalDreamer", "@BlockchainBoss", "@MetaArtist", "@CyberCreator"
    ]
    
    let sampleUsernames = [
        "@john_doe", "@jane_smith", "@crypto_lover", "@art_enthusiast",
        "@pixel_painter", "@digital_wizard", "@nft_collector", "@meta_master"
    ]
    
    return (0..<count).map { index in
        let adjustedIndex = startIndex + index
        return NFTItem(
            title: sampleTitles[adjustedIndex % sampleTitles.count],
            creator: sampleCreators[adjustedIndex % sampleCreators.count],
            creatorUsername: sampleUsernames[adjustedIndex % sampleUsernames.count],
            imageName: "Image@\(Int.random(in: 1...25))"
        )
    }
}

struct User: Identifiable, Codable, Hashable {
    let id: String
    let username: String
    let displayName: String
    let profileImage: String
    let bio: String?
    let location: String?
    var followerCount: Int = 0
    var followingCount: Int = 0
    var isFollowing: Bool = false
    var isVerified: Bool = false
    
    // Initialize with default values for optional parameters
    init(id: String, username: String, displayName: String, profileImage: String, bio: String? = nil, location: String? = nil, followerCount: Int = 0, followingCount: Int = 0, isFollowing: Bool = false, isVerified: Bool = false) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.profileImage = profileImage
        self.bio = bio
        self.location = location
        self.followerCount = followerCount
        self.followingCount = followingCount
        self.isFollowing = isFollowing
        self.isVerified = isVerified
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
    
    // Computed properties
    var validProfileImageURL: URL? {
        return URL(string: profileImage)
    }
    
    var displayUsername: String {
        return username.hasPrefix("@") ? username : "@\(username)"
    }
    
    var initials: String {
        let components = displayName.components(separatedBy: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1) + components[1].prefix(1)).uppercased()
        } else {
            return String(displayName.prefix(2)).uppercased()
        }
    }
}

enum BlockchainType: String, Codable, CaseIterable {
    case ethereum = "ethereum"
    case solana = "solana"
    case polygon = "polygon"
    case binanceSmartChain = "bsc"
    case tezos = "tezos"
    
    var displayName: String {
        switch self {
        case .ethereum:
            return "Ethereum"
        case .solana:
            return "Solana"
        case .polygon:
            return "Polygon"
        case .binanceSmartChain:
            return "Binance Smart Chain"
        case .tezos:
            return "Tezos"
        }
    }
}

enum NotificationType: String, Codable, CaseIterable {
    case like = "like"
    case follow = "follow"
    case comment = "comment"
    case mention = "mention"
    case view = "view"
    case purchase = "purchase"
    case bid = "bid"
    case share = "share"
    
    var displayName: String {
        switch self {
        case .like: return "Like"
        case .follow: return "Follow"
        case .comment: return "Comment"
        case .mention: return "Mention"
        case .view: return "View"
        case .purchase: return "Purchase"
        case .bid: return "Bid"
        case .share: return "Share"
        }
    }
    
    var iconName: String {
        switch self {
        case .like:
            return "heart.fill"
        case .follow:
            return "person.fill.badge.plus"
        case .comment:
            return "message.fill"
        case .mention:
            return "at"
        case .view:
            return "eye.fill"
        case .purchase:
            return "cart.fill"
        case .bid:
            return "hammer.fill"
        case .share:
            return "square.and.arrow.up.fill"
        }
    }
    
    var color: String {
        switch self {
        case .like:
            return "red"
        case .follow:
            return "blue"
        case .comment:
            return "green"
        case .mention:
            return "orange"
        case .view:
            return "purple"
        case .purchase:
            return "yellow"
        case .bid:
            return "pink"
        case .share:
            return "cyan"
        }
    }
}

struct Notification: Identifiable, Codable {
    let id: String
    let type: NotificationType
    let user: User
    let nft: NFT?
    let timestamp: Date
    var isRead: Bool = false
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        formatter.locale = Locale.current
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
    
    var message: String {
        let userName = user.displayName.isEmpty ? user.username : user.displayName
        switch type {
        case .like:
            return "\(userName) liked your NFT"
        case .follow:
            return "\(userName) started following you"
        case .comment:
            return "\(userName) commented on your NFT"
        case .mention:
            return "\(userName) mentioned you"
        case .view:
            return "\(userName) viewed your listing"
        case .purchase:
            return "\(userName) purchased your NFT"
        case .bid:
            return "\(userName) placed a bid on your NFT"
        case .share:
            return "\(userName) shared your NFT"
        }
    }
}

struct Collection: Identifiable, Codable {
    let id: String
    let name: String
    let description: String?
    let coverImage: String?
    let owner: User
    var nfts: [NFT] = []
    var totalVolume: Double = 0.0
    var floorPrice: Double = 0.0
    
    // Computed property for cover image URL validation
    var validCoverImageURL: URL? {
        guard let coverImage = coverImage else { return nil }
        return URL(string: coverImage)
    }
    
    var nftCount: Int {
        return nfts.count
    }
    
    var isEmpty: Bool {
        return nfts.isEmpty
    }
}