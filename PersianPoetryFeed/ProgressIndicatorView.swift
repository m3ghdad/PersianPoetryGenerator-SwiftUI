import SwiftUI

struct ProgressIndicatorView: View {
    let currentIndex: Int
    let totalCount: Int
    
    var body: some View {
        VStack(spacing: 4) {
            // Progress dots
            ForEach(0..<min(5, totalCount), id: \.self) { index in
                let dotIndex = max(0, currentIndex - 2) + index
                let isVisible = dotIndex < totalCount
                let isActive = dotIndex == currentIndex && isVisible
                
                Circle()
                    .fill(isActive ? Color.white : (isVisible ? Color.white.opacity(0.3) : Color.white.opacity(0.1)))
                    .frame(width: 6, height: 16)
                    .opacity(isVisible ? 1 : 0.3)
            }
            
            // Current position
            Text("\(currentIndex + 1)")
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
                .padding(.top, 8)
        }
    }
}

#Preview {
    ProgressIndicatorView(currentIndex: 2, totalCount: 10)
        .background(Color.black)
}
