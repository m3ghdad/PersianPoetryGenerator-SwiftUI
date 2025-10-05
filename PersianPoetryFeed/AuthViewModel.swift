import Foundation
import SwiftUI
import Combine

extension Notification.Name {
    static let userAuthenticated = Notification.Name("userAuthenticated")
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var user: User?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let supabaseService = SupabaseService.shared
    
    struct User: Identifiable, Codable {
        let id: String
        let email: String
        let name: String?
        let profilePictureURL: String?
        let accessToken: String?
    }
    
    init() {
        // Check if user is already authenticated
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        // Check if we have stored user data
        if let userData = UserDefaults.standard.data(forKey: "storedUser"),
           let storedUser = try? JSONDecoder().decode(User.self, from: userData) {
            self.user = storedUser
            self.isAuthenticated = true
            print("User restored from storage: \(storedUser.email)")
            // Restore the access token to SupabaseService
            if let accessToken = storedUser.accessToken {
                supabaseService.restoreAccessToken(accessToken)
            }
            // Load fresh profile data
            loadUserProfile()
            // Notify that user is authenticated (this will trigger favorites loading)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Small delay to ensure the UI has updated
                NotificationCenter.default.post(name: .userAuthenticated, object: storedUser.id)
            }
        } else {
            isAuthenticated = false
            user = nil
        }
    }
    
    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let user = try await supabaseService.signIn(email: email, password: password)
                await MainActor.run {
                    self.isAuthenticated = true
                    self.user = user
                    self.isLoading = false
                    // Save user data for persistence
                    self.saveUserData(user)
                    // Load user profile after successful authentication
                    self.loadUserProfile()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Sign in failed: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    func signUp(email: String, password: String, name: String) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let user = try await supabaseService.signUp(email: email, password: password, name: name)
                await MainActor.run {
                    self.isAuthenticated = true
                    self.user = user
                    self.isLoading = false
                    // Save user data for persistence
                    self.saveUserData(user)
                    // Load user profile after successful authentication
                    self.loadUserProfile()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Sign up failed: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    func signOut() {
        isAuthenticated = false
        user = nil
        // Clear stored user data
        clearUserData()
        supabaseService.signOut()
    }
    
    func loadUserProfile() {
        guard let userId = user?.id else { return }
        
        Task {
            do {
                let profile = try await supabaseService.getProfile(userId: userId)
                await MainActor.run {
                    // Update user with profile data
                    if let currentUser = self.user {
                        self.user = User(
                            id: currentUser.id,
                            email: currentUser.email,
                            name: profile.name ?? currentUser.name,
                            profilePictureURL: profile.profile_picture_url ?? currentUser.profilePictureURL,
                            accessToken: currentUser.accessToken
                        )
                    }
                }
            } catch {
                print("Failed to load user profile: \(error)")
            }
        }
    }
    
    // MARK: - Persistence Methods
    
    private func saveUserData(_ user: User) {
        do {
            let userData = try JSONEncoder().encode(user)
            UserDefaults.standard.set(userData, forKey: "storedUser")
            print("User data saved for persistence")
        } catch {
            print("Failed to save user data: \(error)")
        }
    }
    
    private func clearUserData() {
        UserDefaults.standard.removeObject(forKey: "storedUser")
        print("User data cleared")
    }
}
