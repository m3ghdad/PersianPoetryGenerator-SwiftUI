import SwiftUI

struct LanguageButton: View {
    @EnvironmentObject var languageViewModel: LanguageViewModel
    @State private var showingLanguagePicker = false
    
    var body: some View {
        Button(action: {
            showingLanguagePicker = true
        }) {
            Image(systemName: "globe")
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(0.2))
                .clipShape(Circle())
        }
        .sheet(isPresented: $showingLanguagePicker) {
            LanguagePickerView()
        }
    }
}

struct LanguagePickerView: View {
    @EnvironmentObject var languageViewModel: LanguageViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(languageViewModel.localizedString(for: "language"))
                    .font(.title)
                    .padding(.top, 20)
                
                ForEach(languageViewModel.supportedLanguages, id: \.self) { language in
                    Button(action: {
                        languageViewModel.setLanguage(language)
                        dismiss()
                    }) {
                        HStack {
                            Text(language == "fa" ? "فارسی" : "English")
                                .font(.title2)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if languageViewModel.currentLanguage == language {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                
                Spacer()
            }
            .padding()
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

#Preview {
    LanguageButton()
        .environmentObject(LanguageViewModel())
}
