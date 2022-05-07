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
    func getNotificationsAuthorisationStatus(errorHandler: @escaping (Error) -> Void, permissionDeniedHandler: @escaping () -> Void) {
        notificationCentre.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                if(settings.authorizationStatus == .denied) {
                    self.authorisedNotifications = false
                } else if(settings.authorizationStatus == .notDetermined) {
                    self.requestAuthorisation(errorHandler: errorHandler, permissionDeniedHandler: permissionDeniedHandler)
                }
                
                return
            }
            
            self.authorisedNotifications = true
        }
    }
    
    // requestAuthorisation
    // Request notifications authorisation
    private func requestAuthorisation(errorHandler: @escaping (Error) -> Void, permissionDeniedHandler: @escaping () -> Void) {
        notificationCentre.requestAuthorization(options: [.alert]) { granted, error in
            guard error == nil else {
                errorHandler(error!)
                return
            }
            
            if(granted) {
                self.scheduleNotifications()
            } else {
                permissionDeniedHandler()
            }
        }
    }
    
    // scheduleNotifications
    // Schedules notifications based on the user's settings
    func scheduleNotifications() {
        // TODO
    }
}
