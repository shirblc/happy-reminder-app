//
//  NotificationController.swift
//  happierReminders
//
//  Created by Shir Bar Lev on 07/05/2022.
//

import Foundation
import UserNotifications

struct UserNotificationData {
    let daysOfWeek: [Int]
    let time: String
    let collection: Collection
}

class NotificationController {
    let notificationCentre = UNUserNotificationCenter.current()
    static let shared = NotificationController()
    
    private init() {
        
    }
    
    // getNotificationsAuthorisationStatus
    // Checks whether the user authorised notifications
    private func getNotificationsAuthorisationStatus() async throws -> Bool {
        let settings = await notificationCentre.notificationSettings()
        
        if(settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional) {
            return true
        } else if(settings.authorizationStatus == .notDetermined) {
            do {
                let granted = try await self.requestAuthorisation()
                return granted
            } catch {
                throw error
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
    private func buildNotificationRequest(daysOfWeek: [Int], time: String, collection: Collection) -> [UNNotificationRequest] {
        var notificationRequests: [UNNotificationRequest] = []
        
        for dayOfWeek in daysOfWeek {
            let quote = collection.getRandomQuote()
            
            if let quote = quote {
                // Set the notification's content
                let notificationContent = UNMutableNotificationContent()
                notificationContent.title = "\(quote.type!) Reminder:"
                notificationContent.body = (quote.text)!
                
                // Set the notification's trigger, one per day the user selected
                let scheduleDateComponents = DateComponents(calendar: .current, timeZone: .current, era: nil, year: nil, month: nil, day: nil, hour: Int(time.split(separator: ":")[0]), minute: Int(time.split(separator: ":")[1]), second: 00, nanosecond: 0, weekday: dayOfWeek, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
                let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: scheduleDateComponents, repeats: true)
                let identifier = UUID().uuidString
                
                notificationRequests.append(UNNotificationRequest(identifier: identifier, content: notificationContent, trigger: notificationTrigger))
            }
        }
        
        return notificationRequests
    }
    
    // scheduleNotifications
    // Schedules notifications based on the user's settings
    func scheduleNotifications(notificationsData: UserNotificationData, errorHandler: @escaping (String) -> Void, existingNotifications: [String]?) async -> [String] {
        do {
            let authorisedNotifications = try await getNotificationsAuthorisationStatus()
            
            // make sure we have permission to send notifications
            guard authorisedNotifications else {
                errorHandler("Notifications permissions denied. In order to receive notifications, allow notifications in your device's settings.")
                return []
            }
        } catch {
            errorHandler(error.localizedDescription)
        }
        
        var scheduledNotifications: [String] = []
        let notificationRequests = buildNotificationRequest(daysOfWeek: notificationsData.daysOfWeek, time: notificationsData.time, collection: notificationsData.collection)
        
        // if there are existing scheduled notifications in Core Data, delete them
        if let existingNotifications = existingNotifications {
            deleteScheduledNotifications(existingNotifications: existingNotifications)
        }
        
        // add the requests and keep track of sent notification IDs
        for request in notificationRequests {
            do {
                try await notificationCentre.add(request)
                scheduledNotifications.append(request.identifier)
            } catch {
                errorHandler(error.localizedDescription)
            }
        }
        
        return scheduledNotifications
    }
    
    // deleteScheduledNotifications
    // Deletes the given notification IDs from scheduled notifications 
    func deleteScheduledNotifications(existingNotifications: [String]) {
        notificationCentre.removePendingNotificationRequests(withIdentifiers: existingNotifications)
    }
}
