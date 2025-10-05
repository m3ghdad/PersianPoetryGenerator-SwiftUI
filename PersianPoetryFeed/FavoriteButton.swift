import SwiftUI

struct FavoriteButton: View {
    let poem: Poem?
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var poemViewModel: PoemViewModel
    @State private var showingAuthSheet: Bool = false
    
    private var isFavorited: Bool {
        guard let poem = poem else { return false }
        return poemViewModel.isFavorite(poem: poem)
    }
    
    var body: some View {
        Button(action: {
            if authViewModel.isAuthenticated {
                toggleFavorite()
            } else {
                showingAuthSheet = true
            }
        }) {
            Image(systemName: isFavorited ? "heart.fill" : "heart")
                .font(.title2)
                .foregroundColor(isFavorited ? .red : .white)
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(0.2))
                .clipShape(Circle())
        }
        .sheet(isPresented: $showingAuthSheet) {
            AuthSheetView()
        }
    }
    
    private func toggleFavorite() {
        guard let poem = poem, let userId = authViewModel.user?.id else { return }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            poemViewModel.toggleFavorite(poem: poem, userId: userId)
        }
        
        print("Toggled favorite for: \(poem.title)")
    }
}

#Preview {
    FavoriteButton(poem: Poem.mockPoemsFa[0])
        .environmentObject(AuthViewModel())
}
