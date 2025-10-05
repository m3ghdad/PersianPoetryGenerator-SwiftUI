import SwiftUI
import Combine

struct PoemFeedView: View {
    @EnvironmentObject var poemViewModel: PoemViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var languageViewModel: LanguageViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.black
                    .ignoresSafeArea()
                
                if poemViewModel.isLoading {
                    LoadingView()
                } else if poemViewModel.poems.isEmpty {
                    EmptyStateView()
                } else {
                    // Poem cards with vertical scrolling
                    GeometryReader { geometry in
                        ScrollView(.vertical, showsIndicators: false) {
                            LazyVStack(spacing: 0) {
                                ForEach(Array(poemViewModel.poems.enumerated()), id: \.element.id) { index, poem in
                                    PoemCardView(poem: poem)
                                        .frame(width: geometry.size.width, height: geometry.size.height)
                                        .id(index)
                                }
                            }
                        }
                        .scrollTargetBehavior(.paging)
                        .onAppear {
                            // Scroll to current index
                            withAnimation {
                                // This will be handled by the scroll position
                            }
                        }
                        .gesture(
                            DragGesture()
                                .onEnded { value in
                                    let threshold: CGFloat = 50
                                    if value.translation.height > threshold {
                                        // Swipe down - previous poem
                                        poemViewModel.previousPoem()
                                    } else if value.translation.height < -threshold {
                                        // Swipe up - next poem
                                        poemViewModel.nextPoem()
                                    }
                                }
                        )
                    }
                    .onChange(of: poemViewModel.currentIndex) { newIndex in
                        // Load more poems when near the end
                        if newIndex >= poemViewModel.poems.count - 3 {
                            poemViewModel.loadMorePoems(language: languageViewModel.currentLanguage)
                        }
                    }
                }
                
                // UI Overlays
                VStack {
                    // Top progress indicator
                    HStack {
                        Spacer()
                        ProgressIndicatorView(currentIndex: poemViewModel.currentIndex, totalCount: poemViewModel.poems.count)
                    }
                    .padding(.top, 50)
                    .padding(.trailing, 20)
                    
                    Spacer()
                    
                    // Bottom controls
                    HStack {
                        // Language button
                        LanguageButton()
                        
                        Spacer()
                        
                        // Favorite button
                        FavoriteButton(poem: poemViewModel.poems.isEmpty ? nil : poemViewModel.poems[poemViewModel.currentIndex])
                        
                        Spacer()
                        
                        // Settings button
                        SettingsButton()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 50)
                }
                
                // Loading more indicator
                if poemViewModel.isLoadingMore {
                    VStack {
                        Spacer()
                        HStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            Text(languageViewModel.localizedString(for: "loading"))
                                .foregroundColor(.white)
                                .font(.caption)
                        }
                        .padding(.bottom, 100)
                    }
                }
                
                // API status indicator
                if poemViewModel.usingMockData {
                    VStack {
                        HStack {
                            Text(languageViewModel.localizedString(for: "sampleMode"))
                                .font(.caption)
                                .foregroundColor(.yellow)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.yellow.opacity(0.2))
                                .cornerRadius(8)
                            Spacer()
                        }
                        .padding(.leading, 20)
                        .padding(.bottom, 100)
                        Spacer()
                    }
                }
            }
        }
        .onAppear {
            poemViewModel.loadInitialPoems(language: languageViewModel.currentLanguage)
        }
        .onChange(of: languageViewModel.currentLanguage) { newLanguage in
            poemViewModel.currentIndex = 0
            poemViewModel.poems = []
            poemViewModel.loadInitialPoems(language: newLanguage)
        }
        .onChange(of: authViewModel.isAuthenticated) { isAuthenticated in
            if isAuthenticated, let userId = authViewModel.user?.id {
                // Load favorites from Supabase when user logs in
                poemViewModel.loadFavoritesFromSupabase(userId: userId)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .userAuthenticated)) { notification in
            if let userId = notification.object as? String {
                // Load favorites when user is restored from storage
                poemViewModel.loadFavoritesFromSupabase(userId: userId)
            }
        }
    }
}

struct LoadingView: View {
    @EnvironmentObject var languageViewModel: LanguageViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
            
            Text(languageViewModel.localizedString(for: "loading"))
                .foregroundColor(.white)
                .font(.title2)
        }
    }
}

struct EmptyStateView: View {
    @EnvironmentObject var languageViewModel: LanguageViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.6))
            
            Text(languageViewModel.currentLanguage == "fa" ? "هیچ شعری یافت نشد" : "No poems found")
                .foregroundColor(.white)
                .font(.title2)
        }
    }
}

#Preview {
    PoemFeedView()
        .environmentObject(PoemViewModel())
        .environmentObject(AuthViewModel())
        .environmentObject(LanguageViewModel())
}
