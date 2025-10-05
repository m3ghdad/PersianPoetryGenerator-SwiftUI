import Foundation
import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var user: User?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let supabaseService = SupabaseService.shared
    
    struct User: Identifiable {
        let id: String
        let email: String
        let name: String?
        let profilePictureURL: String?
    }
    
    init() {
        // Check if user is already authenticated
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        // For now, we'll start as unauthenticated
        // In a real app, you'd check for stored session tokens
        isAuthenticated = false
        user = nil
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
                            profilePictureURL: profile.profile_picture_url ?? currentUser.profilePictureURL
                        )
                    }
                }
            } catch {
                print("Failed to load user profile: \(error)")
            }
        }
    }
}
