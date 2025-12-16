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
