//
//  DiaryEntry.swift
//  Dogcatpia
//
//  Created by 訪客使用者 on 2025/12/16.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class DiaryEntry {
    var id: UUID
    var date: Date
    var content: String
    @Attribute(.externalStorage) var imageData: Data?

    init(date: Date = Date(), content: String, imageData: Data? = nil) {
        self.id = UUID()
        self.date = date
        self.content = content
        self.imageData = imageData
    }
}

