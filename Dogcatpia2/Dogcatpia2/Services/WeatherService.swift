//
//  WeatherService.swift
//  Dogcatpia
//
//  Created by 訪客使用者 on 2025/12/16.
//

import Foundation

final class WeatherService {
    static let shared = WeatherService()

    // Default to Taipei for demo purposes
    private let defaultLat = 25.0330
    private let defaultLon = 121.5654

    func fetchWeather(lat: Double? = nil, lon: Double? = nil) async throws -> WeatherInfo {
        let latitude = lat ?? defaultLat
        let longitude = lon ?? defaultLon

        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,relative_humidity_2m,is_day,precipitation,weather_code,wind_speed_10m&timezone=auto"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(WeatherResponse.self, from: data)

        return WeatherInfo(from: response.current)
    }
}

