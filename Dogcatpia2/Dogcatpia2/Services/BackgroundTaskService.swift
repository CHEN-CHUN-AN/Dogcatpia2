//
//  BackgroundTaskService.swift
//  Dogcatpia2
//
//  Created by 訪客使用者 on 2025/12/18.
//

import BackgroundTasks
import UIKit

final class BackgroundTaskService {

    static let shared = BackgroundTaskService()
    static let taskIdentifier = "com.dogcatpia2.tempCheck"

    private init() {}

    func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.taskIdentifier, using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }

    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: Self.taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 最快 15 分鐘後執行

        do {
            try BGTaskScheduler.shared.submit(request)
            print("背景任務已排程")
        } catch {
            print("無法排程背景任務: \(error)")
        }
    }

    private func handleAppRefresh(task: BGAppRefreshTask) {
        // 排程下一次背景更新
        scheduleAppRefresh()

        let operationTask = Task {
            do {
                let (temp, _) = try await BlynkService.shared.fetchData()
                let pet = PetType(rawValue: UserDefaults.standard.string(forKey: "selectedPet") ?? "貓咪") ?? .cat
                NotificationService.shared.sendHighTemp(temp: temp, pet: pet)
                task.setTaskCompleted(success: true)
            } catch {
                task.setTaskCompleted(success: false)
            }
        }

        task.expirationHandler = {
            operationTask.cancel()
        }
    }
}

