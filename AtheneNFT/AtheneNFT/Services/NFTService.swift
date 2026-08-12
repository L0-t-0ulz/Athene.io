import Foundation
import os
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
/// Placeholder configuration — no real backend exists yet. Every public
/// NFTService method returns mock data; the URLSession layer below is unwired.
struct NetworkConfig {
    static let baseURL = "https://api.yourbackend.com" // placeholder, replace when the API exists
    static let shareBaseURL = "https://your-app.com"   // placeholder share-link domain
    static let timeout: TimeInterval = 30.0
    static let retryAttempts = 3

    /// Auth token for API requests. Must be loaded from the Keychain once a
    /// real backend exists — never hardcode credentials here.
    static var authToken: String? { nil }
}

/// Simulated network latency (seconds) used by the mock layer while no backend
/// exists. Named so views don't sprinkle magic numbers.
enum MockLatency {
    static let fetch: TimeInterval = 0.5
    static let userNFTs: TimeInterval = 0.3
    static let search: TimeInterval = 0.4
    static let interaction: TimeInterval = 0.2
    static let follow: TimeInterval = 0.25
    static let notifications: TimeInterval = 0.3
    static let markRead: TimeInterval = 0.1
    static let create: TimeInterval = 2.0
    static let walletConnect: TimeInterval = 0.3
    static let transfer: TimeInterval = 2.0
    static let uploadSettle: TimeInterval = 1.0
}

// MARK: - NFT Service
/// Main-actor bound because it publishes `isLoading`/`errorMessage` straight
/// into SwiftUI views and all mock publishers deliver on the main queue.
/// Revisit the isolation (move networking off-main) when a real backend lands.
@MainActor
class NFTService: ObservableObject {
    static let shared = NFTService()
    static let logger = Logger(subsystem: "com.zayankhan12.AtheneNFT", category: "NFTService")
    /// Largest image accepted by createNFT (raw bytes, before base64 inflation).
    static let maxImageBytes = 10 * 1024 * 1024

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
        if let token = NetworkConfig.authToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
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
                    Self.logger.error("Decoding error: \(error, privacy: .public)")
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
            .delay(for: .seconds(MockLatency.fetch), scheduler: DispatchQueue.main)
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
            .delay(for: .seconds(MockLatency.userNFTs), scheduler: DispatchQueue.main)
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
        
        // Guard the range construction itself: for an out-of-range page,
        // startIndex exceeds endIndex and `startIndex..<endIndex` would trap
        // before the safe subscript could clamp anything.
        let startIndex = (page - 1) * pageSize
        let endIndex = min(startIndex + pageSize, filteredNFTs.count)
        let pageItems = startIndex < endIndex ? Array(filteredNFTs[safe: startIndex..<endIndex]) : []
        
        let mockResponse = PaginatedResponse<NFT>(
            items: pageItems,
            totalCount: filteredNFTs.count,
            page: page,
            pageSize: pageSize,
            hasMore: endIndex < filteredNFTs.count
        )
        
        return Just(mockResponse)
            .setFailureType(to: Error.self)
            .delay(for: .seconds(MockLatency.search), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // Create NFT
    func createNFT(title: String, description: String, price: Double, image: Data, blockchain: BlockchainType) -> AnyPublisher<NFT, Error> {
        // Validate input
        guard !title.isEmpty, !description.isEmpty, price > 0 else {
            return Fail(error: NFTServiceError.networkError("Invalid input parameters"))
                .eraseToAnyPublisher()
        }

        guard image.count <= Self.maxImageBytes else {
            return Fail(error: NFTServiceError.networkError("Image is too large (max 10 MB)"))
                .eraseToAnyPublisher()
        }

        // Mock successful creation
        let mockNFT = NFT(
            id: UUID().uuidString,
            title: title,
            description: description,
            imageURL: Self.mockAssetNames[title.count % Self.mockAssetNames.count],
            price: price,
            creator: getMockUser(),
            createdAt: Date(),
            blockchain: blockchain,
            contract: "0x123abc",
            tokenId: String((title.count * 37) % 1000 + 1)
        )
        
        return Just(mockNFT)
            .setFailureType(to: Error.self)
            .delay(for: .seconds(MockLatency.create), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // Share NFT
    func shareNFT(nft: NFT) -> URL? {
        var components = URLComponents(string: NetworkConfig.shareBaseURL)
        components?.path = "/nft/\(nft.id)"
        components?.queryItems = [URLQueryItem(name: "title", value: nft.title)]
        return components?.url
    }
    
    // Like NFT
    func likeNFT(nftId: String) -> AnyPublisher<LikeResponse, Error> {
        let mockResponse = LikeResponse(isLiked: true, likeCount: 42)

        return Just(mockResponse)
            .setFailureType(to: Error.self)
            .delay(for: .seconds(MockLatency.interaction), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // Unlike NFT
    func unlikeNFT(nftId: String) -> AnyPublisher<LikeResponse, Error> {
        let mockResponse = LikeResponse(isLiked: false, likeCount: 41)

        return Just(mockResponse)
            .setFailureType(to: Error.self)
            .delay(for: .seconds(MockLatency.interaction), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // Follow user
    func followUser(userId: String) -> AnyPublisher<FollowResponse, Error> {
        let mockResponse = FollowResponse(isFollowing: true, followerCount: 1200)

        return Just(mockResponse)
            .setFailureType(to: Error.self)
            .delay(for: .seconds(MockLatency.follow), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // Unfollow user
    func unfollowUser(userId: String) -> AnyPublisher<FollowResponse, Error> {
        let mockResponse = FollowResponse(isFollowing: false, followerCount: 1199)

        return Just(mockResponse)
            .setFailureType(to: Error.self)
            .delay(for: .seconds(MockLatency.follow), scheduler: DispatchQueue.main)
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
            .delay(for: .seconds(MockLatency.notifications), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // Mark notification as read
    func markNotificationAsRead(notificationId: String) -> AnyPublisher<Bool, Error> {
        return Just(true)
            .setFailureType(to: Error.self)
            .delay(for: .seconds(MockLatency.markRead), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - Safe Array Access
// Both safe-subscript forms live here (index form previously duplicated in
// ProfileView.swift).
extension Array {
    subscript(safe range: Range<Index>) -> ArraySlice<Element> {
        let start = Swift.max(range.lowerBound, startIndex)
        let end = Swift.min(range.upperBound, endIndex)
        return start < end ? self[start..<end] : ArraySlice<Element>()
    }

    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Mock Data Extension
// All factories are deterministic (index-derived, no randomness) so the UI is
// stable run to run and unit tests can assert on the output.
extension NFTService {
    /// Bundled asset names used by mock content instead of external image services.
    static let mockAssetNames = ["New", "Trending", "Cards", "Doge", "Gifs", "Celebrities"]

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
                    id: "mock-nft-\(i)",
                    title: "\(titles[titleIndex]) #\(i + 1)",
                    description: descriptions[descIndex],
                    imageURL: Self.mockAssetNames[i % Self.mockAssetNames.count],
                    price: 0.1 + Double(i % 20) * 0.5,
                    creator: getMockUser(seed: i),
                    createdAt: Date().addingTimeInterval(-Double(i * 86400)),
                    blockchain: BlockchainType.allCases[i % BlockchainType.allCases.count],
                    contract: "0x\(String(format: "%06x", (i * 0x1F3B) % 0xFFFFFF))",
                    tokenId: String(i + 1),
                    isLiked: i % 3 == 0,
                    likeCount: (i * 37) % 500,
                    isCollected: i % 4 == 0
                )
            )
        }

        return nfts
    }

    func getMockUser(id: String? = nil, seed: Int = 0) -> User {
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

        let index = abs(seed) % usernames.count

        return User(
            id: id ?? "mock-user-\(index)",
            username: "@\(usernames[index])\(100 + index)",
            displayName: displayNames[index],
            profileImage: "Profile",
            bio: bios[index % bios.count],
            location: locations[index],
            followerCount: 100 + (seed * 613) % 49900,
            followingCount: 10 + (seed * 89) % 990,
            isVerified: seed % 2 == 0
        )
    }

    func getMockNotifications(count: Int) -> [Notification] {
        var notifications = [Notification]()
        let types = NotificationType.allCases

        for i in 0..<count {
            let type = types[i % types.count]
            let mockNFTs = getMockNFTs(count: 1)

            notifications.append(
                Notification(
                    id: "mock-notification-\(i)",
                    type: type,
                    user: getMockUser(seed: i),
                    nft: type == .follow ? nil : mockNFTs.first,
                    timestamp: Date().addingTimeInterval(-Double(i * 5 * 3600)),
                    isRead: i % 2 == 0
                )
            )
        }

        return notifications.sorted { $0.timestamp > $1.timestamp }
    }
}