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
        28
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
                return (false, "🥶 哎呀，有點冷呢！", "現在 \(temp)°C，對\(rawValue)來說有點太冷囉！\n快幫牠準備暖暖的窩或開個暖氣吧，小心別著涼了～")
            } else {
                return (false, "🥵 呼～好熱喔！", "現在 \(temp)°C，\(rawValue)可能會覺得悶熱不舒服。\n記得保持通風、多給牠喝水，或者開冷氣涼快一下，小心別中暑喔！")
            }
        }

        if !humidityRange.contains(humidity) {
            if humidity < humidityRange.lowerBound {
                return (false, "🌵 空氣有點乾乾的～", "濕度只有 \(Int(humidity))%，鼻子和皮膚可能會乾乾癢癢的。\n可以開加濕器幫\(rawValue)保濕一下喔！")
            } else {
                return (false, "💧 濕氣太重啦～", "濕度高達 \(Int(humidity))%，這種天氣容易長黴菌，\(rawValue)皮膚也容易出問題。\n趕快開除濕機乾爽一下吧！")
            }
        }

        return (true, "✨ 完美！超舒服的環境～", "溫度和濕度都剛剛好！\(rawValue)現在一定覺得很放鬆、很開心。\n是個適合睡懶覺的好時光呢 💤")
    }
}
