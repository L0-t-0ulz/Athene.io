import Foundation
import Combine

// MARK: - Custom Errors
enum NFTServiceError: Error, LocalizedError {
    case networkError(String)
    case invalidURL
    case decodingError
    case uploadFailed
    case notImplemented
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidURL:
            return "Invalid URL"
        case .decodingError:
            return "Failed to decode response"
        case .uploadFailed:
            return "Failed to upload image"
        case .notImplemented:
            return "Feature not implemented"
        case .unauthorized:
            return "Unauthorized access"
        }
    }
}

// MARK: - API Response Models
struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let message: String?
    let error: String?
}

struct PaginatedResponse<T: Codable>: Codable {
    let items: [T]
    let totalCount: Int
    let page: Int
    let pageSize: Int
    let hasMore: Bool
}

// MARK: - Request/Response Models
struct CreateNFTRequest: Codable {
    let title: String
    let description: String
    let price: Double
    let blockchain: String
    let imageData: String? // Base64 encoded image
}

struct LikeResponse: Codable {
    let isLiked: Bool
    let likeCount: Int
}

struct FollowResponse: Codable {
    let isFollowing: Bool
    let followerCount: Int
}

// MARK: - Network Configuration
struct NetworkConfig {
    static let baseURL = "https://api.yourbackend.com"
    static let timeout: TimeInterval = 30.0
    static let retryAttempts = 3
}

// MARK: - NFT Service
@MainActor
class NFTService: ObservableObject {
    static let shared = NFTService()
    
    private let baseURL = NetworkConfig.baseURL
    private var cancellables = Set<AnyCancellable>()
    private let session: URLSession
    
    // MARK: - Published Properties for SwiftUI
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = NetworkConfig.timeout
        config.timeoutIntervalForResource = NetworkConfig.timeout * 2
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Network Helper Methods
    private enum HTTPMethod: String {
        case GET = "GET"
        case POST = "POST"
        case PUT = "PUT"
        case DELETE = "DELETE"
    }
    
    private func makeRequest(endpoint: String, method: HTTPMethod = .GET, body: Data? = nil) -> URLRequest? {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer YOUR_API_TOKEN", forHTTPHeaderField: "Authorization")
        
        if let body = body {
            request.httpBody = body
        }
        
        return request
    }
    
    private func performRequest<T: Codable>(_ request: URLRequest, responseType: T.Type) -> AnyPublisher<T, Error> {
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> T in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NFTServiceError.networkError("Invalid response")
                }
                
                guard 200...299 ~= httpResponse.statusCode else {
                    throw NFTServiceError.networkError("HTTP \(httpResponse.statusCode)")
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    return try decoder.decode(T.self, from: data)
                } catch {
                    print("Decoding error: \(error)")
                    throw NFTServiceError.decodingError
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Public API Methods
    
    // Fetch trending NFTs with pagination
    func fetchTrending(page: Int = 1, pageSize: Int = 20) -> AnyPublisher<PaginatedResponse<NFT>, Error> {
        // Mock implementation for development
        let mockResponse = PaginatedResponse<NFT>(
            items: getMockNFTs(count: pageSize),
            totalCount: 100,
            page: page,
            pageSize: pageSize,
            hasMore: page * pageSize < 100
        )
        
        return Just(mockResponse)
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // Fetch user's NFTs
    func fetchUserNFTs(userId: String, page: Int = 1, pageSize: Int = 20) -> AnyPublisher<PaginatedResponse<NFT>, Error> {
        // Mock implementation
        let mockNFTs = getMockNFTs(count: pageSize).map { nft in
            var updatedNFT = nft
            updatedNFT.creator = getMockUser(id: userId)
            return updatedNFT
        }
        
        let mockResponse = PaginatedResponse<NFT>(
            items: mockNFTs,
            totalCount: 50,
            page: page,
            pageSize: pageSize,
            hasMore: page * pageSize < 50
        )
        
        return Just(mockResponse)
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // Search NFTs
    func searchNFTs(query: String, page: Int = 1, pageSize: Int = 20) -> AnyPublisher<PaginatedResponse<NFT>, Error> {
        // Mock filtered results
        let allMockNFTs = getMockNFTs(count: 100)
        let filteredNFTs = allMockNFTs.filter { nft in
            nft.title.localizedCaseInsensitiveContains(query) ||
            nft.description.localizedCaseInsensitiveContains(query) ||
            nft.creator.displayName.localizedCaseInsensitiveContains(query)
        }
        
        let startIndex = (page - 1) * pageSize
        let endIndex = min(startIndex + pageSize, filteredNFTs.count)
        let pageItems = Array(filteredNFTs[safe: startIndex..<endIndex])
        
        let mockResponse = PaginatedResponse<NFT>(
            items: pageItems,
            totalCount: filteredNFTs.count,
            page: page,
            pageSize: pageSize,
            hasMore: endIndex < filteredNFTs.count
        )
        
        return Just(mockResponse)
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(400), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // Create NFT
    func createNFT(title: String, description: String, price: Double, image: Data, blockchain: BlockchainType) -> AnyPublisher<NFT, Error> {
        // Validate input
        guard !title.isEmpty, !description.isEmpty, price > 0 else {
            return Fail(error: NFTServiceError.networkError("Invalid input parameters"))
                .eraseToAnyPublisher()
        }
        
        let imageBase64 = image.base64EncodedString()
        let _ = CreateNFTRequest(
            title: title,
            description: description,
            price: price,
            blockchain: blockchain.rawValue,
            imageData: imageBase64
        )
        
        // Mock successful creation
        let mockNFT = NFT(
            id: UUID().uuidString,
            title: title,
            description: description,
            imageURL: "https://picsum.photos/500",
            price: price,
            creator: getMockUser(),
            createdAt: Date(),
            blockchain: blockchain,
            contract: "0x123abc",
            tokenId: String(Int.random(in: 1...1000))
        )
        
        return Just(mockNFT)
            .setFailureType(to: Error.self)
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // Share NFT
    func shareNFT(nft: NFT) -> URL {
        let baseShareURL = "https://your-app.com/nft"
        let shareURL = "\(baseShareURL)/\(nft.id)?title=\(nft.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        return URL(string: shareURL) ?? URL(string: baseShareURL)!
    }
    
    // Like NFT
    func likeNFT(nftId: String) -> AnyPublisher<LikeResponse, Error> {
        let mockResponse = LikeResponse(isLiked: true, likeCount: Int.random(in: 1...100))
        
        return Just(mockResponse)
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // Unlike NFT
    func unlikeNFT(nftId: String) -> AnyPublisher<LikeResponse, Error> {
        let mockResponse = LikeResponse(isLiked: false, likeCount: Int.random(in: 0...99))
        
        return Just(mockResponse)
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // Follow user
    func followUser(userId: String) -> AnyPublisher<FollowResponse, Error> {
        let mockResponse = FollowResponse(isFollowing: true, followerCount: Int.random(in: 1...5000))
        
        return Just(mockResponse)
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(250), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // Unfollow user
    func unfollowUser(userId: String) -> AnyPublisher<FollowResponse, Error> {
        let mockResponse = FollowResponse(isFollowing: false, followerCount: Int.random(in: 0...4999))
        
        return Just(mockResponse)
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(250), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // Fetch notifications
    func fetchNotifications(page: Int = 1, pageSize: Int = 20) -> AnyPublisher<PaginatedResponse<Notification>, Error> {
        let mockResponse = PaginatedResponse<Notification>(
            items: getMockNotifications(count: pageSize),
            totalCount: 50,
            page: page,
            pageSize: pageSize,
            hasMore: page * pageSize < 50
        )
        
        return Just(mockResponse)
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // Mark notification as read
    func markNotificationAsRead(notificationId: String) -> AnyPublisher<Bool, Error> {
        return Just(true)
            .setFailureType(to: Error.self)
            .delay(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - Safe Array Extension
extension Array {
    subscript(safe range: Range<Index>) -> ArraySlice<Element> {
        let start = Swift.max(range.lowerBound, startIndex)
        let end = Swift.min(range.upperBound, endIndex)
        return start < end ? self[start..<end] : ArraySlice<Element>()
    }
}

// MARK: - Mock Data Extension
extension NFTService {
    func getMockNFTs(count: Int) -> [NFT] {
        var nfts = [NFT]()
        let titles = ["Amazing Artwork", "Digital Dreams", "Crypto Masterpiece", "Abstract Vision", "Future Art", "Pixel Paradise", "Color Explosion", "Minimal Beauty", "Cosmic Journey", "Urban Landscape"]
        let descriptions = [
            "This is a beautiful piece of digital art created with passion and creativity.",
            "An exploration of color and form in the digital realm.",
            "A unique piece that captures the essence of modern art.",
            "Created using cutting-edge digital techniques and artistic vision.",
            "A masterpiece that represents the future of digital art."
        ]
        
        for i in 0..<count {
            let titleIndex = i % titles.count
            let descIndex = i % descriptions.count
            
            nfts.append(
                NFT(
                    id: UUID().uuidString,
                    title: "\(titles[titleIndex]) #\(i + 1)",
                    description: descriptions[descIndex],
                    imageURL: "https://picsum.photos/id/\(10 + i)/500",
                    price: Double.random(in: 0.1...10.0),
                    creator: getMockUser(),
                    createdAt: Date().addingTimeInterval(-Double(i * 86400)),
                    blockchain: BlockchainType.allCases.randomElement() ?? .ethereum,
                    contract: "0x\(String(format: "%06x", Int.random(in: 0...0xFFFFFF)))",
                    tokenId: String(i + 1),
                    isLiked: Bool.random(),
                    likeCount: Int.random(in: 0...500),
                    isCollected: Bool.random()
                )
            )
        }
        
        return nfts
    }
    
    func getMockUser(id: String? = nil) -> User {
        let usernames = ["artist", "creator", "designer", "collector", "painter", "sculptor", "photographer", "illustrator"]
        let displayNames = ["Digital Artist", "NFT Creator", "Abstract Designer", "Art Collector", "Modern Painter", "3D Sculptor", "Photo Artist", "Vector Illustrator"]
        let locations = ["San Francisco, CA", "New York, NY", "Los Angeles, CA", "Austin, TX", "Seattle, WA", "Miami, FL", "Denver, CO", "Portland, OR"]
        let bios = [
            "Creating digital art and NFTs",
            "Exploring the intersection of art and technology",
            "Passionate about blockchain and digital ownership",
            "Building the future of digital art",
            "Collector and creator of unique digital pieces"
        ]
        
        let randomIndex = Int.random(in: 0..<usernames.count)
        
        return User(
            id: id ?? UUID().uuidString,
            username: "@\(usernames[randomIndex])\(Int.random(in: 100...999))",
            displayName: displayNames[randomIndex],
            profileImage: "https://i.pravatar.cc/150?img=\(Int.random(in: 1...70))",
            bio: bios.randomElement(),
            location: locations.randomElement(),
            followerCount: Int.random(in: 100...50000),
            followingCount: Int.random(in: 10...1000),
            isVerified: Bool.random()
        )
    }
    
    func getMockNotifications(count: Int) -> [Notification] {
        var notifications = [Notification]()
        let types = NotificationType.allCases
        
        for i in 0..<count {
            let randomType = types.randomElement() ?? .like
            let mockNFTs = getMockNFTs(count: 1)
            
            notifications.append(
                Notification(
                    id: UUID().uuidString,
                    type: randomType,
                    user: getMockUser(),
                    nft: randomType == .follow ? nil : mockNFTs.first,
                    timestamp: Date().addingTimeInterval(-Double(i * 3600 + Int.random(in: 0...3600))),
                    isRead: Bool.random()
                )
            )
        }
        
        return notifications.sorted { $0.timestamp > $1.timestamp }
    }
}