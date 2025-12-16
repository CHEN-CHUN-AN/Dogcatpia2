//
//  PetCareWidgetView.swift
//  Dogcatpia
//
//  Created by 訪客使用者 on 2025/12/16.
//

import SwiftUI
import WidgetKit

struct PetCareWidgetView: View {
    let entry: PetCareEntry

    var body: some View {
        VStack {
            Text("🐾 毛孩環境")
                .font(.headline)

            if let r = entry.record {
                Text("🌡 \(r.temperature) °C")
                Text("💧 \(r.humidity) %")
            } else {
                Text("尚無資料")
            }
        }
        .padding()
    }
}
