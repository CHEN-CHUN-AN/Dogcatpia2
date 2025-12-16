//
//  WeatherInfo.swift
//  Dogcatpia
//
//  Created by 訪客使用者 on 2025/12/16.
//

import Foundation

struct WeatherResponse: Codable {
    let current: CurrentWeather
}

struct CurrentWeather: Codable {
    let temperature2m: Double
    let relativeHumidity2m: Int
    let isDay: Int
    let precipitation: Double
    let weatherCode: Int
    let windSpeed10m: Double

    enum CodingKeys: String, CodingKey {
        case temperature2m = "temperature_2m"
        case relativeHumidity2m = "relative_humidity_2m"
        case isDay = "is_day"
        case precipitation
        case weatherCode = "weather_code"
        case windSpeed10m = "wind_speed_10m"
    }
}

struct WeatherInfo {
    let temperature: Double
    let humidity: Int
    let isDay: Bool
    let isRaining: Bool
    let condition: String
    let windSpeed: Double

    init(from response: CurrentWeather) {
        self.temperature = response.temperature2m
        self.humidity = response.relativeHumidity2m
        self.isDay = response.isDay == 1
        self.windSpeed = response.windSpeed10m

        // WMO Weather interpretation codes (WW)
        // 0: Clear sky
        // 1, 2, 3: Mainly clear, partly cloudy, and overcast
        // 45, 48: Fog and depositing rime fog
        // 51, 53, 55: Drizzle: Light, moderate, and dense intensity
        // 56, 57: Freezing Drizzle: Light and dense intensity
        // 61, 63, 65: Rain: Slight, moderate and heavy intensity
        // 66, 67: Freezing Rain: Light and heavy intensity
        // 71, 73, 75: Snow fall: Slight, moderate, and heavy intensity
        // 77: Snow grains
        // 80, 81, 82: Rain showers: Slight, moderate, and violent
        // 85, 86: Snow showers slight and heavy
        // 95 *: Thunderstorm: Slight or moderate
        // 96, 99 *: Thunderstorm with slight and heavy hail

        let code = response.weatherCode
        self.isRaining = [51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82, 95, 96, 99].contains(code)

        switch code {
        case 0: self.condition = "晴朗"
        case 1...3: self.condition = "多雲"
        case 45, 48: self.condition = "有霧"
        case 51...57: self.condition = "毛毛雨"
        case 61...67: self.condition = "下雨"
        case 71...77: self.condition = "下雪"
        case 80...82: self.condition = "陣雨"
        case 85...86: self.condition = "陣雪"
        case 95...99: self.condition = "雷雨"
        default: self.condition = "未知"
        }
    }
}

