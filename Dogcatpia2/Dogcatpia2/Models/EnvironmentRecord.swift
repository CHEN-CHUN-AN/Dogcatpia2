//
//  Untitled.swift
//  Dogcatpia
//
//  Created by 訪客使用者 on 2025/12/16.
//

import Foundation
import SwiftData

@Model
class EnvironmentRecord {
    var timestamp: Date
    var temperature: Double
    var humidity: Double
    var petType: String

    init(timestamp: Date,
         temperature: Double,
         humidity: Double,
         petType: String) {
        self.timestamp = timestamp
        self.temperature = temperature
        self.humidity = humidity
        self.petType = petType
    }
}
