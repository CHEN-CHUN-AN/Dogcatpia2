//
//  Dogcatpia2App.swift
//  Dogcatpia2
//
//  Created by 訪客使用者 on 2025/12/16.
//

import SwiftUI
import SwiftData

@main
struct Dogcatpia2App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            DiaryEntry.self,
            EnvironmentRecord.self,
            TodoItem.self
        ])
    }
}
