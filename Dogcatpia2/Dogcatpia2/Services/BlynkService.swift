//
//  BlynkService.swift
//  Dogcatpia
//
//  Created by 訪客使用者 on 2025/12/16.
//

import Foundation

final class BlynkService {

    static let shared = BlynkService()

    private var token: String {
        UserDefaults.standard.string(forKey: "blynkToken") ?? "JyGCQW9FRjI7AMHb1Io95P4YZVWh49Is"
    }


    private var tempPin: String {
        UserDefaults.standard.string(forKey: "tempPin") ?? "V0"
    }

    private var humPin: String {
        UserDefaults.standard.string(forKey: "humPin") ?? "V1"
    }

    func fetchData() async throws -> (Double, Double) {
        async let temp = fetch(pin: tempPin)
        async let hum  = fetch(pin: humPin)
        return try await (temp, hum)
    }

    private func fetch(pin: String) async throws -> Double {
        let url = URL(
            string: "https://blynk.cloud/external/api/get?token=\(token)&\(pin)"
        )!

        let (data, _) = try await URLSession.shared.data(from: url)
        let stringValue = String(decoding: data, as: UTF8.self)

        guard let value = Double(stringValue) else {
            throw URLError(.cannotParseResponse)
        }

        return value
    }
}
