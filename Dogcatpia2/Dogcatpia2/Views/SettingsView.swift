//
//  SettingsView.swift
//  Dogcatpia
//
//  Created by 訪客使用者 on 2025/12/16.
//


import SwiftUI

struct SettingsView: View {
    @AppStorage("blynkToken") private var blynkToken = ""
    @AppStorage("tempPin") private var tempPin = "V0"
    @AppStorage("humPin") private var humPin = "V1"

    var body: some View {
        Form {
            Section("Blynk 設定") {
                TextField("Auth Token", text: $blynkToken)
                TextField("溫度 Pin (例如 V0)", text: $tempPin)
                TextField("濕度 Pin (例如 V1)", text: $humPin)
            }

            Section("說明") {
                Text("請輸入 Blynk 專案的 Auth Token 與對應的虛擬腳位，以獲取正確的溫濕度資訊。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("設定")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
