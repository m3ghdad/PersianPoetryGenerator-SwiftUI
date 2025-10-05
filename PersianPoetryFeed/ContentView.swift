//
//  ContentView.swift
//  PersianPoetryFeed
//
//  Created by Meghdad Abbaszadegan on 10/4/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var poemViewModel = PoemViewModel()
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var languageViewModel = LanguageViewModel()
    
    var body: some View {
        NavigationView {
            PoemFeedView()
                .environmentObject(poemViewModel)
                .environmentObject(authViewModel)
                .environmentObject(languageViewModel)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    ContentView()
}