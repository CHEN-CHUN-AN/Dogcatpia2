//
//  PetType.swift
//  Dogcatpia
//
//  Created by 訪客使用者 on 2025/12/16.
//

enum PetType: String, CaseIterable, Identifiable {
    case cat = "貓咪"
    case dog = "狗狗"

    var id: String { rawValue }

    var highTempLimit: Double {
        self == .cat ? 32 : 30
    }

    func comfortStatus(temp: Double, humidity: Double) -> (isComfortable: Bool, message: String, detail: String) {
        let tempRange: ClosedRange<Double>
        let humidityRange: ClosedRange<Double> = 40...70

        switch self {
        case .cat:
            tempRange = 20...28
        case .dog:
            tempRange = 18...26
        }

        if !tempRange.contains(temp) {
            if temp < tempRange.lowerBound {
                return (false, "太冷了！建議開暖氣 🥶", "目前 \(temp)°C，低於\(rawValue)舒適溫度 (\(Int(tempRange.lowerBound))~\(Int(tempRange.upperBound))°C)。\n建議準備保暖墊或開啟暖氣，以免感冒。")
            } else {
                return (false, "太熱了！建議開冷氣 🥵", "目前 \(temp)°C，高於\(rawValue)舒適溫度 (\(Int(tempRange.lowerBound))~\(Int(tempRange.upperBound))°C)。\n請注意通風、補充水分，避免中暑風險。")
            }
        }

        if !humidityRange.contains(humidity) {
            if humidity < humidityRange.lowerBound {
                return (false, "太乾燥了！建議加濕 🌵", "目前濕度 \(Int(humidity))%，低於建議範圍 (40~70%)。\n空氣乾燥可能影響呼吸道或皮膚，建議使用加濕器。")
            } else {
                return (false, "太潮濕了！建議除濕 💧", "目前濕度 \(Int(humidity))%，高於建議範圍 (40~70%)。\n潮濕容易滋生黴菌與塵蟎，建議開啟除濕機。")
            }
        }

        return (true, "環境舒適，適合\(rawValue)休息 😴", "溫濕度皆在舒適範圍內！\n(溫度 \(Int(tempRange.lowerBound))~\(Int(tempRange.upperBound))°C，濕度 40~70%)\n\(rawValue)現在應該感到很放鬆。")
    }
}
