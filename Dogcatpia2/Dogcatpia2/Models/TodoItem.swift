//
//  TodoItem.swift
//  Dogcatpia
//
//  Created by 訪客使用者 on 2025/12/16.
//

import Foundation
import SwiftData

@Model
final class TodoItem {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    var reminderTime: Date?
    var sortOrder: Int

    init(title: String, isCompleted: Bool = false, createdAt: Date = .now, reminderTime: Date? = nil, sortOrder: Int = 0) {
        self.id = UUID()
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.reminderTime = reminderTime
        self.sortOrder = sortOrder
    }
}

