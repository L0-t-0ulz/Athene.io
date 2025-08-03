import SwiftUI

struct ForYouView: View {
    @State private var posts = [
        NFTPost(
            id: "1",
            username: "@Rayul",
            title: "Slango",
            description: "Heres my latest piece that I created, I hope you guys like it!",
            imageName: "Trending",
            hashtags: ["#newrelease"],
            creatorName: "@Rayul",
            creatorImage: "profile-image",
            timePosted: "1h ago",
            likes: 124
        ),
        NFTPost(
            id: "2",
            username: "@johnbricks",
            title: "The Wanderer of The Cosmos",
            description: "Just added a new classic collectible piece to my collection! #space",
            imageName: "New",
            hashtags: [],
            creatorName: "@CryptoJack",
            creatorImage: "profile-image",
            timePosted: "3h ago",
            likes: 95
        ),
        NFTPost(
            id: "3",
            username: "@galaxystargirl",
            title: "Chroma",
            description: "Just copped @wizardbull's latest NFT for my collection! #NFTCollector #DigitalArtIsTheFuture",
            imageName: "Celebrities",
            hashtags: [],
            creatorName: "@wizardbull",
            creatorImage: "profile-image",
            timePosted: "5h ago",
            likes: 187
        ),
        NFTPost(
            id: "4",
            username: "@dogepunklover",
            title: "Rare Doge Alert",
            description: "Got this amazing Dogepunk! #dogepunk #nft #rare",
            imageName: "Doge",
            hashtags: ["#dogepunk", "#nft", "#rare"],
            creatorName: "@dogepunks",
            creatorImage: "profile-image",
            timePosted: "7h ago",
            likes: 342
        ),
        NFTPost(
            id: "5",
            username: "@gifmaster",
            title: "Animated Magic",
            description: "Check out this mesmerizing animated NFT! #animated #gif #art",
            imageName: "Gifs",
            hashtags: ["#animated", "#gif", "#art"],
            creatorName: "@cryptogrin",
            creatorImage: "profile-image",
            timePosted: "9h ago",
            likes: 256
        )
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Header
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(height: 88)
                            .background(.black)
                        
                        HStack {
                            Text("For You")
                                .font(Font.custom("Noto Sans", size: 20).weight(.bold))
                                .foregroundColor(.white)
                            
                            Image(systemName: "chevron.down")
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                        }
                        .offset(y: 22)
                        
                        // Status bar with carrier info
                        HStack(alignment: .top, spacing: 144) {
                            HStack(alignment: .top, spacing: 4) {
                                Text("Carrier")
                                    .font(Font.custom("Noto Sans", size: 12))
                                    .lineSpacing(14)
                                    .foregroundColor(.white)
                            }
                            .padding(EdgeInsets(top: 1, leading: 0, bottom: 1, trailing: 0))
                            
                            HStack(spacing: 4) {
                                Image(systemName: "wifi")
                                    .foregroundColor(.white)
                                Image(systemName: "battery.100")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                        .frame(width: 343)
                        .background(.black)
                        .offset(x: 0.50, y: -16)
                    }
                    .frame(height: 88)
                    
                    // Content
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(posts) { post in
                                NFTFeedPostView(post: post)
                                
                                Divider()
                                    .background(Color.gray.opacity(0.2))
                                    .padding(.vertical, 8)
                            }
                            
                            // Bottom spacing
                            Spacer(minLength: 80)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct NFTPost: Identifiable {
    let id: String
    let username: String
    let title: String
    let description: String
    let imageName: String
    let hashtags: [String]
    let creatorName: String
    let creatorImage: String
    let timePosted: String
    let likes: Int
}

struct NFTFeedPostView: View {
    let post: NFTPost
    @State private var isLiked = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // User info header
            HStack {
                // Profile photo  
                FallbackAsyncImage(
                    imageName: "Profile",
                    size: CGSize(width: 32, height: 32),
                    cornerRadius: 16
                )
                
                Text(post.username)
                    .font(Font.custom("Noto Sans", size: 14).weight(.semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Options button
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 16)
            
            // NFT Image
            FallbackAsyncImage(
                imageName: post.imageName,
                size: CGSize(width: 343, height: 343),
                cornerRadius: 8
            )
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: .infinity)
            
            // Action buttons
            HStack(spacing: 16) {
                Button(action: { isLiked.toggle() }) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .foregroundColor(isLiked ? .red : .white)
                }
                
                Button(action: {}) {
                    Image(systemName: "bubble.right")
                        .foregroundColor(.white)
                }
                
                Button(action: {}) {
                    Image(systemName: "arrow.up")
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .font(.system(size: 22))
            
            // Title and description
            VStack(alignment: .leading, spacing: 4) {
                Text(post.title)
                    .font(Font.custom("Noto Sans", size: 16).weight(.bold))
                    .foregroundColor(.white)
                
                Text(post.description)
                    .font(Font.custom("Noto Sans", size: 14))
                    .foregroundColor(.white)
                
                // Hashtags
                ForEach(post.hashtags, id: \.self) { hashtag in
                    Text(hashtag)
                        .font(Font.custom("Noto Sans", size: 14))
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 16)
            
            // Creator info
            HStack {
                Text("Created by")
                    .font(Font.custom("Noto Sans", size: 12))
                    .foregroundColor(Color(red: 0.50, green: 0.50, blue: 0.50))
                
                FallbackAsyncImage(
                    imageName: "Profile",
                    size: CGSize(width: 20, height: 20),
                    cornerRadius: 10
                )
                .padding(.horizontal, 4)
                
                Text(post.creatorName)
                    .font(Font.custom("Noto Sans", size: 12))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
        }
        .padding(.vertical, 8)
    }
}

// ProfileImageView removed - replaced with FallbackAsyncImage throughout the app

struct ForYouView_Previews: PreviewProvider {
    static var previews: some View {
        ForYouView()
    }
}