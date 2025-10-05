import Foundation

struct Poem: Identifiable, Codable {
    let id: Int
    let title: String
    let text: String
    let htmlText: String
    let poet: Poet
    
    struct Poet: Codable {
        let id: Int
        let name: String
        let fullName: String
    }
}

// Mock data matching your React app
extension Poem {
    static let mockPoemsFa: [Poem] = [
        Poem(
            id: 1,
            title: "غزل شماره ۱",
            text: "الا یا ایها الساقی ادر کاسا و ناولها\nکه عشق آسان نمود اول ولی افتاد مشکل‌ها",
            htmlText: "الا یا ایها الساقی ادر کاسا و ناولها<br/>که عشق آسان نمود اول ولی افتاد مشکل‌ها",
            poet: Poet(id: 1, name: "حافظ", fullName: "خواجه شمس‌الدین محمد حافظ شیرازی")
        ),
        Poem(
            id: 2,
            title: "رباعی",
            text: "این کوزه چو من عاشق زاری بوده است\nدر بند سر زلف نگاری بوده است\nاین دسته که بر گردن او می‌بینی\nدستی است که بر گردن یاری بوده است",
            htmlText: "این کوزه چو من عاشق زاری بوده است<br/>در بند سر زلف نگاری بوده است<br/>این دسته که بر گردن او می‌بینی<br/>دستی است که بر گردن یاری بوده است",
            poet: Poet(id: 2, name: "عمر خیام", fullName: "غیاث‌الدین ابوالفتح عمر بن ابراهیم خیام نیشابوری")
        ),
        Poem(
            id: 3,
            title: "غزل",
            text: "بنی آدم اعضای یک پیکرند\nکه در آفرینش ز یک گوهرند\nچو عضوی به درد آورد روزگار\nدگر عضوها را نماند قرار",
            htmlText: "بنی آدم اعضای یک پیکرند<br/>که در آفرینش ز یک گوهرند<br/>چو عضوی به درد آورد روزگار<br/>دگر عضوها را نماند قرار",
            poet: Poet(id: 3, name: "سعدی", fullName: "ابومحمد مصلح‌الدین بن عبدالله شیرازی")
        )
    ]
    
    static let mockPoemsEn: [Poem] = [
        Poem(
            id: 101,
            title: "Ghazal No. 1",
            text: "Come, O cup-bearer, bring wine and offer it\nFor love seemed easy at first, but difficulties arose",
            htmlText: "Come, O cup-bearer, bring wine and offer it<br/>For love seemed easy at first, but difficulties arose",
            poet: Poet(id: 1, name: "Hafez", fullName: "Khwaja Shams-ud-Din Muhammad Hafez-e Shirazi")
        ),
        Poem(
            id: 102,
            title: "Quatrain",
            text: "This jug, like me, was once a lover in despair\nCaught in the bonds of some beloved's hair\nThis handle that you see upon its neck\nWas once an arm around a lover fair",
            htmlText: "This jug, like me, was once a lover in despair<br/>Caught in the bonds of some beloved's hair<br/>This handle that you see upon its neck<br/>Was once an arm around a lover fair",
            poet: Poet(id: 2, name: "Omar Khayyam", fullName: "Ghiyath al-Din Abu'l-Fath Umar ibn Ibrahim al-Khayyam al-Nishapuri")
        ),
        Poem(
            id: 103,
            title: "Ghazal",
            text: "Human beings are members of a whole\nIn creation of one essence and soul\nIf a member is afflicted with pain\nOther members uneasy will remain",
            htmlText: "Human beings are members of a whole<br/>In creation of one essence and soul<br/>If a member is afflicted with pain<br/>Other members uneasy will remain",
            poet: Poet(id: 3, name: "Saadi", fullName: "Abu-Muhammad Muslih al-Din bin Abdallah Shirazi")
        )
    ]
}
