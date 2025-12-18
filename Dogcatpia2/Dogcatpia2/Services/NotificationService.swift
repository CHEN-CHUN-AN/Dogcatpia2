//
//  NotificationService.swift
//  Dogcatpia
//
//  Created by 訪客使用者 on 2025/12/16.
//

import UserNotifications

final class NotificationService: NSObject, UNUserNotificationCenterDelegate {

    static let shared = NotificationService()

    override private init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    // 在 App 內不顯示通知，只有背景執行時才通知
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([])
    }

    func sendHighTemp(temp: Double, pet: PetType) {
        guard temp >= pet.highTempLimit else { return }

        let content = UNMutableNotificationContent()
        content.title = "🥵 哎呀！太熱了"
        content.body = "現在 \(temp)°C，\(pet.rawValue) 快熱暈了！趕快開冷氣或通風喔！"
        content.sound = .default

        // 立即傳送通知 (trigger = nil)
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: nil
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
