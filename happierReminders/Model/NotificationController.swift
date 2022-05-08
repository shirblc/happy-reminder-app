//
//  NotificationController.swift
//  happierReminders
//
//  Created by Shir Bar Lev on 07/05/2022.
//

import Foundation
import UserNotifications

class NotificationController {
    var authorisedNotifications: Bool? = nil
    let notificationCentre = UNUserNotificationCenter.current()
    static let shared = NotificationController()
    
    private init() {
        
    }
    
    // getNotificationsAuthorisationStatus
    // Checks whether the user authorised notifications
    private func getNotificationsAuthorisationStatus(errorHandler: @escaping (Error) -> Void) async -> Bool {
        let settings = await notificationCentre.notificationSettings()
        
        if(settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional) {
            return true
        } else if(settings.authorizationStatus == .notDetermined) {
            do {
                let granted = try await self.requestAuthorisation()
                return granted
            } catch {
                errorHandler(error)
                return false
            }
        } else {
            return false
        }
    }
    
    // requestAuthorisation
    // Request notifications authorisation
    private func requestAuthorisation() async throws -> Bool {
        do {
            let granted = try await notificationCentre.requestAuthorization(options: [.alert])
            return granted
        } catch {
            throw error
        }
    }
    
    // buildNotificationRequest
    // Builds the UNNotificationRequest to schedule
    func buildNotificationRequest(daysOfWeek: [Int], time: String, quoteText: String, quoteType: String) -> [UNNotificationRequest] {
        // Set the notification's content
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "\(quoteType) Reminder:"
        // TODO: Replace this with randomly generated text
        notificationContent.body = quoteText
        
        var notificationRequests: [UNNotificationRequest] = []
        
        // Set the notification's trigger, one per day the user selected
        for dayOfWeek in daysOfWeek {
            let scheduleDateComponents = DateComponents(calendar: .current, timeZone: .current, era: nil, year: nil, month: nil, day: nil, hour: Int(time.split(separator: ":")[0]), minute: Int(time.split(separator: ":")[1]), second: 00, nanosecond: 0, weekday: dayOfWeek, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
            let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: scheduleDateComponents, repeats: true)
            let identifier = UUID().uuidString
            
            notificationRequests.append(UNNotificationRequest(identifier: identifier, content: notificationContent, trigger: notificationTrigger))
        }
        
        return notificationRequests
    }
    
    // scheduleNotifications
    // Schedules notifications based on the user's settings
    func scheduleNotifications() {
        // TODO
    }
}
