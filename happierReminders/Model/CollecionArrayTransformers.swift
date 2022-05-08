//
//  CollecionArrayTransformers.swift
//  happierReminders
//
//  Created by Shir Bar Lev on 06/05/2022.
//

import Foundation
import CoreData

final class NotificationDaysArrayTransformer: NSSecureUnarchiveFromDataTransformer {
    override static var allowedTopLevelClasses: [AnyClass] {
        return [NSArray.self, NSNumber.self]
    }
    
    public static func register() {
        ValueTransformer.setValueTransformer(NotificationDaysArrayTransformer(), forName: NSValueTransformerName(rawValue: "NotificationDaysArrayTransformer"))
    }
}

final class ScheduledNotificationArrayTransformer: NSSecureUnarchiveFromDataTransformer {
    override static var allowedTopLevelClasses: [AnyClass] {
        return [NSArray.self, NSString.self]
    }
    
    public static func register() {
        ValueTransformer.setValueTransformer(ScheduledNotificationArrayTransformer(), forName: NSValueTransformerName(rawValue: "ScheduledNotificationArrayTransformer"))
    }
}
