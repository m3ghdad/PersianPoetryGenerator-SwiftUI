import Foundation
import SwiftUI
import Combine

@MainActor
class LanguageViewModel: ObservableObject {
    @Published var currentLanguage: String = "fa" // Default to Persian
    @Published var isRTL: Bool = true
    
    let supportedLanguages = ["fa", "en"]
    
    init() {
        updateRTLStatus()
    }
    
    func setLanguage(_ language: String) {
        currentLanguage = language
        updateRTLStatus()
    }
    
    private func updateRTLStatus() {
        isRTL = currentLanguage == "fa"
    }
    
    func localizedString(for key: String) -> String {
        switch key {
        case "loading":
            return currentLanguage == "fa" ? "در حال بارگذاری..." : "Loading..."
        case "mockDataSubtitle":
            return currentLanguage == "fa" ? "حالت نمونه" : "Sample Mode"
        case "apiUnavailable":
            return currentLanguage == "fa" ? "API در دسترس نیست" : "API Unavailable"
        case "favorite":
            return currentLanguage == "fa" ? "علاقه‌مندی" : "Favorite"
        case "unfavorite":
            return currentLanguage == "fa" ? "حذف از علاقه‌مندی‌ها" : "Remove from Favorites"
        case "settings":
            return currentLanguage == "fa" ? "تنظیمات" : "Settings"
        case "signIn":
            return currentLanguage == "fa" ? "ورود" : "Sign In"
        case "signUp":
            return currentLanguage == "fa" ? "ثبت‌نام" : "Sign Up"
        case "signOut":
            return currentLanguage == "fa" ? "خروج" : "Sign Out"
        case "favorites":
            return currentLanguage == "fa" ? "علاقه‌مندی‌ها" : "Favorites"
        case "language":
            return currentLanguage == "fa" ? "زبان" : "Language"
        default:
            return key
        }
    }
}
