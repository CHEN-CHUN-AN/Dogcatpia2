//
//  DashboardViewModel.swift
//  Dogcatpia
//
//  Created by 訪客使用者 on 2025/12/16.
//

import SwiftUI
import SwiftData
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {

    @Published var temperature = 0.0
    @Published var humidity = 0.0
    @Published var pet: PetType = .cat
    @Published var errorMessage: String?

    private var timerTask: Task<Void, Never>?

    func startAutoRefresh(context: ModelContext) {
        // 防止重複啟動
        stopAutoRefresh()

        timerTask = Task {
            while !Task.isCancelled {
                await refresh(context: context)
                // 等待 2 秒
                try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
            }
        }
    }

    func stopAutoRefresh() {
        timerTask?.cancel()
        timerTask = nil
    }

    func refresh(context: ModelContext) async {
        do {
            let (t, h) = try await BlynkService.shared.fetchData()
            temperature = t
            humidity = h

            context.insert(
                EnvironmentRecord(
                    timestamp: .now,
                    temperature: t,
                    humidity: h,
                    petType: pet.rawValue
                )
            )

            NotificationService.shared.sendHighTemp(
                temp: t, pet: pet
            )

        } catch {
            errorMessage = "無法取得資料：\(error.localizedDescription)"
        }
    }
}
