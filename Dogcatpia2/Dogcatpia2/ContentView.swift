//
//  ContentView.swift
//  Dogcatpia2
//
//  Created by 訪客使用者 on 2025/12/16.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false

    var body: some View {
        if hasSeenWelcome {
            DashboardView()
        } else {
            WelcomeView {
                withAnimation {
                    hasSeenWelcome = true
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
