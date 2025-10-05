import SwiftUI

struct PoemCardView: View {
    let poem: Poem
    @EnvironmentObject var languageViewModel: LanguageViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color.gray.opacity(0.3),
                        Color.black
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Poet name at the top
                    VStack {
                        Text(poem.poet.name)
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.top, 60)
                    }
                    
                    Spacer()
                    
                    // Poem content
                    ScrollView {
                        VStack(spacing: 16) {
                            Text(poem.title)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                            
                            // Convert HTML to attributed text for better display
                            Text(poem.text)
                                .font(.title2)
                                .fontWeight(.light)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .lineSpacing(8)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 20)
                        }
                    }
                    .frame(maxHeight: geometry.size.height * 0.7)
                    
                    Spacer()
                }
            }
        }
        .clipped()
    }
}

#Preview {
    PoemCardView(poem: Poem.mockPoemsFa[0])
        .environmentObject(LanguageViewModel())
}
