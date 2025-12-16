//
//  DogWalkingWeatherView.swift
//  Dogcatpia
//
//  Created by 訪客使用者 on 2025/12/16.
//

import SwiftUI

struct DogWalkingWeatherView: View {
    @State private var weather: WeatherInfo?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showLocationSearch = false

    @AppStorage("selectedLocationName") private var locationName = "台北市"
    @AppStorage("selectedLat") private var selectedLat = 25.0330
    @AppStorage("selectedLon") private var selectedLon = 121.5654

    var body: some View {
        VStack(spacing: 20) {
            if isLoading {
                ProgressView("取得 \(locationName) 天氣資訊中...")
            } else if let weather = weather {
                WeatherContent(weather: weather, locationName: locationName)
            } else if let error = errorMessage {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundStyle(.orange)
                    Text(error)
                    Button("重試") {
                        loadWeather()
                    }
                    .buttonStyle(.bordered)
                }
            } else {
                ContentUnavailableView("無天氣資訊", systemImage: "cloud.sun", description: Text("點擊重新整理以取得天氣"))
            }
        }
        .navigationTitle("遛狗天氣")
        .onAppear {
            if weather == nil {
                loadWeather()
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(action: { loadWeather() }) {
                        Label("重新整理", systemImage: "arrow.clockwise")
                    }

                    Button(action: { showLocationSearch = true }) {
                        Label("切換地點", systemImage: "mappin.and.ellipse")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showLocationSearch) {
            LocationSearchView { item in
                locationName = item.name
                selectedLat = item.latitude
                selectedLon = item.longitude
                loadWeather(lat: item.latitude, lon: item.longitude)
            }
        }
    }

    private func loadWeather(lat: Double? = nil, lon: Double? = nil) {
        isLoading = true
        errorMessage = nil

        let targetLat = lat ?? selectedLat
        let targetLon = lon ?? selectedLon

        Task {
            do {
                let info = try await WeatherService.shared.fetchWeather(lat: targetLat, lon: targetLon)
                await MainActor.run {
                    self.weather = info
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "無法取得天氣：\(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
}

struct WeatherContent: View {
    let weather: WeatherInfo
    let locationName: String

    var walkingScore: (score: Int, color: Color, advice: String) {
        var score = 100
        var advice = "天氣很棒，快帶毛孩出門吧！"
        var color = Color.green

        // 溫度判斷
        if weather.temperature > 30 {
            score -= 40
            advice = "太熱了！小心毛孩中暑，建議傍晚再出門。"
            color = .red
        } else if weather.temperature > 28 {
            score -= 20
            advice = "有點熱，記得多補充水分。"
            color = .orange
        } else if weather.temperature < 10 {
            score -= 20
            advice = "天氣冷，短毛狗狗記得穿衣服喔！"
            color = .blue
        }

        // 下雨判斷
        if weather.isRaining {
            score -= 50
            advice = "正在下雨，建議在家玩耍或穿雨衣出門。"
            color = .blue
        }

        // 晚上判斷
        if !weather.isDay {
            advice += " (晚上視線不佳，記得用發光項圈)"
        }

        return (max(0, score), color, advice)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 主要天氣卡片
                VStack(spacing: 10) {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                        Text(locationName)
                    }
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.bottom, 4)

                    Image(systemName: weatherIcon(for: weather))
                        .font(.system(size: 60))
                        .foregroundStyle(.white)
                        .shadow(radius: 2)

                    Text("\(Int(weather.temperature))°C")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundStyle(.white)

                    Text(weather.condition)
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.9))

                    HStack(spacing: 20) {
                        Label("\(weather.humidity)%", systemImage: "drop.fill")
                        Label("\(Int(weather.windSpeed)) km/h", systemImage: "wind")
                    }
                    .foregroundStyle(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(
                    LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom)
                )
                .cornerRadius(20)
                .padding(.horizontal)
                .shadow(radius: 5)

                // 遛狗指數
                let status = walkingScore
                VStack(spacing: 16) {
                    Text("遛狗指數")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 15)

                        Circle()
                            .trim(from: 0, to: CGFloat(status.score) / 100)
                            .stroke(status.color, style: StrokeStyle(lineWidth: 15, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .animation(.easeOut, value: status.score)

                        VStack {
                            Text("\(status.score)")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundStyle(status.color)
                            Text("分")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(width: 120, height: 120)

                    Text(status.advice)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(status.color.opacity(0.1))
                        .cornerRadius(10)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(radius: 2)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }

    func weatherIcon(for info: WeatherInfo) -> String {
        if info.isRaining { return "cloud.rain.fill" }
        switch info.condition {
        case "晴朗": return info.isDay ? "sun.max.fill" : "moon.stars.fill"
        case "多雲": return "cloud.fill"
        case "有霧": return "cloud.fog.fill"
        case "下雪", "陣雪": return "snowflake"
        case "雷雨": return "cloud.bolt.rain.fill"
        default: return "cloud.sun.fill"
        }
    }
}

#Preview {
    NavigationStack {
        DogWalkingWeatherView()
    }
}

