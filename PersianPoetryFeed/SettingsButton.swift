import SwiftUI

struct SettingsButton: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingSettingsSheet = false
    
    var body: some View {
        Button(action: {
            showingSettingsSheet = true
        }) {
            Image(systemName: "gearshape")
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(0.2))
                .clipShape(Circle())
        }
        .sheet(isPresented: $showingSettingsSheet) {
            SettingsSheetView()
        }
    }
}

struct SettingsSheetView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var languageViewModel: LanguageViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingFavorites = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if authViewModel.isAuthenticated {
                    // User is authenticated
                    VStack(spacing: 16) {
                        // User info
                        VStack {
                            if let profilePictureURL = authViewModel.user?.profilePictureURL, !profilePictureURL.isEmpty {
                                AsyncImage(url: URL(string: profilePictureURL)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 60, height: 60)
                                        .clipShape(Circle())
                                } placeholder: {
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.blue)
                                }
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.blue)
                            }
                            
                            Text(authViewModel.user?.name ?? "User")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text(authViewModel.user?.email ?? "")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        
                        // Settings options
                        VStack(spacing: 12) {
                            SettingsRowView(
                                icon: "heart.fill",
                                title: languageViewModel.localizedString(for: "favorites"),
                                action: {
                                    showingFavorites = true
                                }
                            )
                            
                            SettingsRowView(
                                icon: "globe",
                                title: languageViewModel.localizedString(for: "language"),
                                action: {
                                    // Show language picker
                                }
                            )
                            
                            SettingsRowView(
                                icon: "arrow.right.square",
                                title: languageViewModel.localizedString(for: "signOut"),
                                action: {
                                    authViewModel.signOut()
                                    dismiss()
                                }
                            )
                        }
                    }
                } else {
                    // User is not authenticated
                    VStack(spacing: 20) {
                        Image(systemName: "person.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text(languageViewModel.localizedString(for: "signIn"))
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Sign in to save your favorite poems")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            dismiss()
                            // Show auth sheet
                        }) {
                            Text(languageViewModel.localizedString(for: "signIn"))
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingFavorites) {
                FavoritesView()
            }
        }
    }
}

struct SettingsRowView: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }
}

#Preview {
    SettingsButton()
        .environmentObject(AuthViewModel())
}
