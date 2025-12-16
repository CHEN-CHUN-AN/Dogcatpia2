//
//  NotificationService.swift
//  Dogcatpia
//
//  Created by 訪客使用者 on 2025/12/16.
//

import UserNotifications

final class NotificationService {

    static let shared = NotificationService()

    func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func sendHighTemp(temp: Double, pet: PetType) {
        guard temp >= pet.highTempLimit else { return }

        let content = UNMutableNotificationContent()
        content.title = "⚠️ 高溫警告"
        content.body = "\(pet.rawValue) 環境溫度 \(temp)°C"

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 1, repeats: false
        )

        UNUserNotificationCenter.current().add(
            UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: trigger
            )
        )
    }

    func scheduleReminder(id: UUID, title: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "待辦事項提醒"
        content.body = title
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func cancelReminder(id: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }
}
