import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var poemViewModel: PoemViewModel
    @EnvironmentObject var languageViewModel: LanguageViewModel
    @Environment(\.dismiss) private var dismiss
    
    var favoritePoems: [Poem] {
        poemViewModel.getFavoritePoems()
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if favoritePoems.isEmpty {
                    EmptyFavoritesView()
                } else {
                    List {
                        ForEach(favoritePoems, id: \.id) { poem in
                            FavoritesRowView(poem: poem)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle(languageViewModel.localizedString(for: "favorites"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FavoritesRowView: View {
    let poem: Poem
    @EnvironmentObject var poemViewModel: PoemViewModel
    @EnvironmentObject var languageViewModel: LanguageViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(poem.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(poem.poet.name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(poem.text.components(separatedBy: "\n").prefix(2).joined(separator: " "))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
                                Button(action: {
                                    // Get userId from AuthViewModel - for now using placeholder
                                    let userId = "current-user-id" // This should come from AuthViewModel
                                    poemViewModel.toggleFavorite(poem: poem, userId: userId)
                                }) {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 8)
    }
}

struct EmptyFavoritesView: View {
    @EnvironmentObject var languageViewModel: LanguageViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(languageViewModel.currentLanguage == "fa" ? "هیچ شعر مورد علاقه‌ای ندارید" : "No favorite poems yet")
                .font(.title2)
                .foregroundColor(.primary)
            
            Text(languageViewModel.currentLanguage == "fa" ? 
                 "شعرهای مورد علاقه خود را با ضربه زدن روی دکمه قلب ذخیره کنید" : 
                 "Tap the heart button to save your favorite poems")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    FavoritesView()
        .environmentObject(PoemViewModel())
        .environmentObject(LanguageViewModel())
}
