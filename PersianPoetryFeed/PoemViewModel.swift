import Foundation
import SwiftUI
import Combine

@MainActor
class PoemViewModel: ObservableObject {
    @Published var poems: [Poem] = []
    @Published var currentIndex: Int = 0
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var usingMockData: Bool = false
    @Published var favoritePoems: Set<Int> = []
    @Published var favoritePoemsList: [Poem] = []
    @Published var hasMore: Bool = true
    
    private var usedPoemIds: Set<Int> = []
    private let supabaseService = SupabaseService.shared
    
    func loadInitialPoems(language: String) {
        isLoading = true
        
        // For English, always use mock data
        if language == "en" {
            loadMockPoems(language: language)
            return
        }
        
        // For Persian, try API first, then fallback to mock
        Task {
            do {
                let apiPoems = try await fetchRandomPoems(count: 5)
                if apiPoems.count >= 2 {
                    poems = apiPoems
                    usingMockData = false
                    apiPoems.forEach { poem in
                        usedPoemIds.insert(poem.id)
                    }
                } else {
                    loadMockPoems(language: language)
                }
            } catch {
                loadMockPoems(language: language)
            }
            isLoading = false
        }
    }
    
    func loadMorePoems(language: String) {
        guard !isLoadingMore && hasMore else { return }
        
        isLoadingMore = true
        
        Task {
            do {
                if usingMockData || language == "en" {
                    let mockPoems = language == "fa" ? Poem.mockPoemsFa : Poem.mockPoemsEn
                    let shuffledMock = mockPoems.shuffled()
                    poems.append(contentsOf: shuffledMock)
                } else {
                    let newPoems = try await fetchRandomPoems(count: 3)
                    if newPoems.count >= 1 {
                        poems.append(contentsOf: newPoems)
                    } else {
                        // Fallback to mock data
                        let mockPoems = language == "fa" ? Poem.mockPoemsFa : Poem.mockPoemsEn
                        let shuffledMock = mockPoems.shuffled()
                        poems.append(contentsOf: shuffledMock)
                        usingMockData = true
                    }
                }
            } catch {
                // Fallback to mock data
                let mockPoems = language == "fa" ? Poem.mockPoemsFa : Poem.mockPoemsEn
                let shuffledMock = mockPoems.shuffled()
                poems.append(contentsOf: shuffledMock)
                usingMockData = true
            }
            isLoadingMore = false
        }
    }
    
    private func loadMockPoems(language: String) {
        let mockPoems = language == "fa" ? Poem.mockPoemsFa : Poem.mockPoemsEn
        poems = mockPoems.shuffled()
        usingMockData = true
        mockPoems.forEach { poem in
            usedPoemIds.insert(poem.id)
        }
    }
    
    private func fetchRandomPoems(count: Int) async throws -> [Poem] {
        var fetchedPoems: [Poem] = []
        let maxAttempts = min(count * 2, 10)
        
        for i in 0..<maxAttempts {
            guard fetchedPoems.count < count else { break }
            
            do {
                let poem = try await fetchSinglePoem()
                if !usedPoemIds.contains(poem.id) {
                    fetchedPoems.append(poem)
                    usedPoemIds.insert(poem.id)
                }
            } catch {
                // If API fails, break and use mock data
                break
            }
        }
        
        return fetchedPoems
    }
    
    private func fetchSinglePoem() async throws -> Poem {
        guard let url = URL(string: "https://api.ganjoor.net/api/ganjoor/poem/random") else {
            throw NSError(domain: "InvalidURL", code: 1, userInfo: nil)
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Persian Poetry App", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 5.0
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "HTTPError", code: 1, userInfo: nil)
        }
        
        let jsonData = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let json = jsonData else {
            throw NSError(domain: "JSONError", code: 1, userInfo: nil)
        }
        
        // Parse the API response
        guard let poemId = json["id"] as? Int,
              let title = json["title"] as? String,
              let plainText = json["plainText"] as? String ?? json["text"] as? String else {
            throw NSError(domain: "ParseError", code: 1, userInfo: nil)
        }
        
        // Extract poet information
        var poet: Poem.Poet
        if let poetData = json["poet"] as? [String: Any],
           let poetId = poetData["id"] as? Int,
           let poetName = poetData["name"] as? String {
            poet = Poem.Poet(
                id: poetId,
                name: poetName,
                fullName: poetData["fullName"] as? String ?? poetName
            )
        } else if let fullTitle = json["fullTitle"] as? String {
            let titleParts = fullTitle.components(separatedBy: " » ")
            poet = Poem.Poet(
                id: Int.random(in: 1...1000000),
                name: titleParts.first?.trimmingCharacters(in: .whitespaces) ?? "Unknown",
                fullName: titleParts.first?.trimmingCharacters(in: .whitespaces) ?? "Unknown"
            )
        } else {
            throw NSError(domain: "PoetParseError", code: 1, userInfo: nil)
        }
        
        let htmlText = json["htmlText"] as? String ?? plainText.replacingOccurrences(of: "\n", with: "<br/>")
        
        return Poem(
            id: poemId,
            title: title,
            text: plainText,
            htmlText: htmlText,
            poet: poet
        )
    }
    
    func navigateToPoem(_ index: Int) {
        guard index >= 0 && index < poems.count else { return }
        currentIndex = index
        
        // Load more poems if we're near the end
        if index >= poems.count - 3 && !isLoadingMore && hasMore {
            loadMorePoems(language: "fa")
        }
    }
    
    func nextPoem() {
        let nextIndex = min(currentIndex + 1, poems.count - 1)
        navigateToPoem(nextIndex)
    }
    
    func previousPoem() {
        let prevIndex = max(currentIndex - 1, 0)
        navigateToPoem(prevIndex)
    }
    
    func toggleFavorite(poem: Poem, userId: String) {
        if favoritePoems.contains(poem.id) {
            favoritePoems.remove(poem.id)
            removeFavoriteFromSupabase(poemId: poem.id, userId: userId)
        } else {
            favoritePoems.insert(poem.id)
            addFavoriteToSupabase(poemId: poem.id, userId: userId)
        }
    }
    
    private func addFavoriteToSupabase(poemId: Int, userId: String) {
        Task {
            do {
                try await supabaseService.addFavorite(userId: userId, poemId: poemId)
                print("Successfully added favorite to Supabase: \(poemId)")
            } catch {
                print("Failed to add favorite to Supabase: \(error)")
                // Revert the local change if Supabase call failed
                await MainActor.run {
                    favoritePoems.remove(poemId)
                }
            }
        }
    }
    
    private func removeFavoriteFromSupabase(poemId: Int, userId: String) {
        Task {
            do {
                try await supabaseService.removeFavorite(userId: userId, poemId: poemId)
                print("Successfully removed favorite from Supabase: \(poemId)")
            } catch {
                print("Failed to remove favorite from Supabase: \(error)")
                // Revert the local change if Supabase call failed
                await MainActor.run {
                    favoritePoems.insert(poemId)
                }
            }
        }
    }
    
    func loadFavoritesFromSupabase(userId: String) {
        print("PoemViewModel: Loading favorites for user: \(userId)")
        Task {
            do {
                let favoritePoems = try await supabaseService.getFavorites(userId: userId)
                await MainActor.run {
                    self.favoritePoemsList = favoritePoems
                    self.favoritePoems = Set(favoritePoems.map { $0.id })
                    print("PoemViewModel: Loaded \(favoritePoems.count) favorites from Supabase")
                    print("PoemViewModel: Current favoritePoems set: \(self.favoritePoems)")
                }
            } catch {
                print("PoemViewModel: Failed to load favorites from Supabase: \(error)")
            }
        }
    }
    
    func isFavorite(poem: Poem) -> Bool {
        return favoritePoems.contains(poem.id)
    }
    
    func getFavoritePoems() -> [Poem] {
        return favoritePoemsList
    }
}
