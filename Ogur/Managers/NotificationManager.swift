import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Notification permission error: \(error)")
                }
                completion(granted)
            }
        }
    }
    
    func checkAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    func scheduleReminder(_ reminder: Reminder, plantName: String) {
        guard reminder.isEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "GrowLog 🌱"
        
        switch reminder.type {
        case .watering:
            content.body = "Time to water \(plantName) 💧"
        case .feeding:
            content.body = "Time to feed \(plantName) 🌿"
        case .photo:
            content.body = "Take a photo of \(plantName) 📷"
        case .measurement:
            content.body = "Measure \(plantName)'s growth 📏"
        }
        
        content.sound = .default
        content.badge = 1
        
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: reminder.time)
        
        let trigger: UNNotificationTrigger
        
        switch reminder.repeatInterval {
        case .daily:
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        case .everyTwoDays, .everyThreeDays, .weekly, .biweekly:
            let interval = TimeInterval(reminder.repeatInterval.days * 24 * 60 * 60)
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: true)
        }
        
        let request = UNNotificationRequest(
            identifier: reminder.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification add error: \(error)")
            }
        }
    }
    
    func cancelReminder(_ id: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [id.uuidString]
        )
    }
    
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func cancelReminders(for plantId: UUID, reminders: [Reminder]) {
        let identifiers = reminders
            .filter { $0.plantId == plantId }
            .map { $0.id.uuidString }
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: identifiers
        )
    }
    
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests)
            }
        }
    }
    
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
}
