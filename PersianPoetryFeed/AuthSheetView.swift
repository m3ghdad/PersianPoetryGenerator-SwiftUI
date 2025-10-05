import SwiftUI

struct AuthSheetView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var languageViewModel: LanguageViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text(isSignUp ? languageViewModel.localizedString(for: "signUp") : languageViewModel.localizedString(for: "signIn"))
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Persian Poetry TikTok")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Form
                VStack(spacing: 16) {
                    if isSignUp {
                        TextField("Name", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal, 20)
                
                // Action Button
                Button(action: {
                    if isSignUp {
                        authViewModel.signUp(email: email, password: password, name: name)
                    } else {
                        authViewModel.signIn(email: email, password: password)
                    }
                }) {
                    HStack {
                        if authViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        
                        Text(isSignUp ? languageViewModel.localizedString(for: "signUp") : languageViewModel.localizedString(for: "signIn"))
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(authViewModel.isLoading ? Color.gray : Color.blue)
                    .cornerRadius(10)
                }
                .disabled(authViewModel.isLoading || email.isEmpty || password.isEmpty)
                .padding(.horizontal, 20)
                
                // Toggle between sign in and sign up
                Button(action: {
                    isSignUp.toggle()
                }) {
                    Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onChange(of: authViewModel.isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                dismiss()
            }
        }
    }
}

#Preview {
    AuthSheetView()
        .environmentObject(AuthViewModel())
        .environmentObject(LanguageViewModel())
}
