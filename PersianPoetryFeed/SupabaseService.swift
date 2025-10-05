import Foundation
import Combine

class SupabaseService: ObservableObject {
    static let shared = SupabaseService()
    
    private let session = URLSession.shared
    private var cancellables = Set<AnyCancellable>()
    private var accessToken: String?
    
    private init() {}
    
    // MARK: - Authentication
    
    func signOut() {
        accessToken = nil
    }
    
    func restoreAccessToken(_ token: String) {
        accessToken = token
    }
    
    func signIn(email: String, password: String) async throws -> AuthViewModel.User {
        let url = URL(string: "\(SupabaseConfig.baseURL)/auth/v1/token?grant_type=password")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(SupabaseConfig.publicAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(SupabaseConfig.publicAnonKey)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.networkError
        }
        
        print("Supabase auth response status: \(httpResponse.statusCode)")
        print("Supabase auth response data: \(String(data: data, encoding: .utf8) ?? "No data")")
        
        if httpResponse.statusCode != 200 {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("Supabase auth error: \(errorMessage)")
            throw SupabaseError.authenticationFailed
        }
        
        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        
        // Store the access token for authenticated requests
        self.accessToken = authResponse.access_token
        
        return AuthViewModel.User(
            id: authResponse.user.id,
            email: authResponse.user.email,
            name: authResponse.user.userMetadata?["name"] as? String,
            profilePictureURL: authResponse.user.userMetadata?["avatar_url"] as? String,
            accessToken: authResponse.access_token
        )
    }
    
    func signUp(email: String, password: String, name: String) async throws -> AuthViewModel.User {
        let url = URL(string: "\(SupabaseConfig.baseURL)/auth/v1/signup")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(SupabaseConfig.publicAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(SupabaseConfig.publicAnonKey)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "email": email,
            "password": password,
            "data": [
                "name": name
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.networkError
        }
        
        print("Supabase signup response status: \(httpResponse.statusCode)")
        print("Supabase signup response data: \(String(data: data, encoding: .utf8) ?? "No data")")
        
        if httpResponse.statusCode != 200 {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("Supabase signup error: \(errorMessage)")
            throw SupabaseError.authenticationFailed
        }
        
        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
        
        // Store the access token for authenticated requests
        self.accessToken = authResponse.access_token
        
        return AuthViewModel.User(
            id: authResponse.user.id,
            email: authResponse.user.email,
            name: authResponse.user.userMetadata?["name"] as? String,
            profilePictureURL: authResponse.user.userMetadata?["avatar_url"] as? String,
            accessToken: authResponse.access_token
        )
    }
    
    // MARK: - Favorites
    
    func getFavorites(userId: String) async throws -> [Poem] {
        // Use your server endpoint instead of direct database access
        let url = URL(string: "\(SupabaseConfig.baseURL)/functions/v1/make-server-c192d0ee/favorites")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(SupabaseConfig.publicAnonKey, forHTTPHeaderField: "apikey")
        // Use the stored access token for authenticated requests
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            request.setValue("Bearer \(SupabaseConfig.publicAnonKey)", forHTTPHeaderField: "Authorization")
        }
        
        print("Fetching favorites for user: \(userId)")
        print("Favorites URL: \(url)")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.networkError
        }
        
        print("Favorites response status: \(httpResponse.statusCode)")
        print("Favorites response data: \(String(data: data, encoding: .utf8) ?? "No data")")
        
        if httpResponse.statusCode != 200 {
            print("Favorites API error: Status \(httpResponse.statusCode)")
            if httpResponse.statusCode == 404 {
                print("Favorites not found for user - returning empty array")
                return []
            }
            throw SupabaseError.networkError
        }
        
        // Parse the favorites response from your server
        // The server returns {"favorites": [...]} format
        let favoritesResponse = try JSONDecoder().decode(FavoritesResponse.self, from: data)
        let poems = favoritesResponse.favorites.map { $0.toPoem() }
        
        print("Decoded \(poems.count) favorite poems from server")
        return poems
    }
    
    func addFavorite(userId: String, poemId: Int) async throws {
        // Use your server endpoint for adding favorites
        let url = URL(string: "\(SupabaseConfig.baseURL)/functions/v1/make-server-c192d0ee/favorites")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(SupabaseConfig.publicAnonKey, forHTTPHeaderField: "apikey")
        // Use the stored access token for authenticated requests
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            request.setValue("Bearer \(SupabaseConfig.publicAnonKey)", forHTTPHeaderField: "Authorization")
        }
        
        // Create a simple favorite entry with minimal data
        // Your server should handle getting the full poem data
        let favorite = KVFavorite(
            id: poemId,
            title: "Poem \(poemId)", // Server should replace this with actual data
            text: "",
            htmlText: "",
            poet: KVFavorite.KVPoet(id: 0, name: "Unknown", fullName: "Unknown Poet"),
            favoritedAt: ISO8601DateFormatter().string(from: Date()),
            userId: userId
        )
        
        request.httpBody = try JSONEncoder().encode(favorite)
        
        print("Adding favorite: user_id=\(userId), poem_id=\(poemId)")
        print("Add favorite URL: \(url)")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.networkError
        }
        
        print("Add favorite response status: \(httpResponse.statusCode)")
        print("Add favorite response data: \(String(data: data, encoding: .utf8) ?? "No data")")
        
        if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 {
            throw SupabaseError.custom("Failed to add favorite: Status \(httpResponse.statusCode)")
        }
    }
    
    func removeFavorite(userId: String, poemId: Int) async throws {
        // Use your server endpoint for removing favorites
        let url = URL(string: "\(SupabaseConfig.baseURL)/functions/v1/make-server-c192d0ee/favorites/\(poemId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue(SupabaseConfig.publicAnonKey, forHTTPHeaderField: "apikey")
        // Use the stored access token for authenticated requests
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            request.setValue("Bearer \(SupabaseConfig.publicAnonKey)", forHTTPHeaderField: "Authorization")
        }
        
        print("Removing favorite: user_id=\(userId), poem_id=\(poemId)")
        print("Remove favorite URL: \(url)")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.networkError
        }
        
        print("Remove favorite response status: \(httpResponse.statusCode)")
        print("Remove favorite response data: \(String(data: data, encoding: .utf8) ?? "No data")")
        
        if httpResponse.statusCode != 200 && httpResponse.statusCode != 204 {
            throw SupabaseError.custom("Failed to remove favorite: Status \(httpResponse.statusCode)")
        }
    }
    
    // MARK: - Profile
    
    func getProfile(userId: String) async throws -> UserProfile {
        // Use your server endpoint for profile
        let url = URL(string: "\(SupabaseConfig.baseURL)/functions/v1/make-server-c192d0ee/profile")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(SupabaseConfig.publicAnonKey, forHTTPHeaderField: "apikey")
        // Use the stored access token for authenticated requests
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            request.setValue("Bearer \(SupabaseConfig.publicAnonKey)", forHTTPHeaderField: "Authorization")
        }
        
        print("Fetching profile for user: \(userId)")
        print("Profile URL: \(url)")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.networkError
        }
        
        print("Profile response status: \(httpResponse.statusCode)")
        print("Profile response data: \(String(data: data, encoding: .utf8) ?? "No data")")
        
        if httpResponse.statusCode != 200 {
            print("Profile API error: Status \(httpResponse.statusCode)")
            if httpResponse.statusCode == 404 {
                print("Profile not found for user - returning default profile")
                return UserProfile(name: nil, profileImage: nil, userId: nil, updatedAt: nil)
            }
            throw SupabaseError.networkError
        }
        
        // Parse the profile response from your server
        // The server returns {"profile": {...}} format
        let profileResponse = try JSONDecoder().decode(ProfileResponse.self, from: data)
        
        print("Decoded profile from server: \(profileResponse.profile)")
        return profileResponse.profile
    }
}

// MARK: - Data Models

struct AuthResponse: Decodable {
    let user: SupabaseUser
    let access_token: String
    let refresh_token: String
}

struct SupabaseUser: Decodable {
    let id: String
    let email: String
    let userMetadata: [String: Any]?
    
    enum CodingKeys: String, CodingKey {
        case id, email
        case userMetadata = "user_metadata"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        
        // Handle user_metadata as a flexible dictionary
        if let metadataContainer = try? container.nestedContainer(keyedBy: AnyCodingKey.self, forKey: .userMetadata) {
            var metadata: [String: Any] = [:]
            for key in metadataContainer.allKeys {
                if let stringValue = try? metadataContainer.decode(String.self, forKey: key) {
                    metadata[key.stringValue] = stringValue
                } else if let boolValue = try? metadataContainer.decode(Bool.self, forKey: key) {
                    metadata[key.stringValue] = boolValue
                }
            }
            userMetadata = metadata
        } else {
            userMetadata = nil
        }
    }
}

struct AnyCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?
    
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = "\(intValue)"
    }
}

struct FavoriteItem: Codable {
    let poem_id: Int
}

struct KVStoreResponse: Codable {
    let key: String
    let value: String
}

struct KVFavorite: Codable {
    let id: Int
    let title: String
    let text: String
    let htmlText: String
    let poet: KVPoet
    let favoritedAt: String
    let userId: String
    
    struct KVPoet: Codable {
        let id: Int
        let name: String
        let fullName: String
    }
    
    // Convert to Poem struct for the app
    func toPoem() -> Poem {
        return Poem(
            id: self.id,
            title: self.title,
            text: self.text,
            htmlText: self.htmlText,
            poet: Poem.Poet(
                id: self.poet.id,
                name: self.poet.name,
                fullName: self.poet.fullName
            )
        )
    }
}

struct UserProfile: Codable {
    let name: String?
    let profileImage: String? // Base64 encoded image data
    let userId: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case profileImage
        case userId
        case updatedAt
    }
    
    // Computed property to get the profile picture URL for display
    var profile_picture_url: String? {
        return profileImage
    }
}

struct ProfileResponse: Codable {
    let profile: UserProfile
}

struct FavoritesResponse: Codable {
    let favorites: [KVFavorite]
}

enum SupabaseError: Error, LocalizedError {
    case authenticationFailed
    case networkError
    case invalidResponse
    case custom(String)
    
    var errorDescription: String? {
        switch self {
        case .authenticationFailed: return "Authentication failed. Please check your credentials."
        case .networkError: return "Network error. Please check your internet connection."
        case .invalidResponse: return "Invalid response from server."
        case .custom(let message): return message
        }
    }
}