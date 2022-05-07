//
//  NotificationArrayTransformer.swift
//  happierReminders
//
//  Created by Shir Bar Lev on 06/05/2022.
//

import Foundation
import CoreData

final class NotificationArrayTransformer: NSSecureUnarchiveFromDataTransformer {
    override static var allowedTopLevelClasses: [AnyClass] {
        return [NSArray.self]
    }
    
    public static func register() {
        ValueTransformer.setValueTransformer(NotificationArrayTransformer(), forName: NSValueTransformerName(rawValue: "NotificationArrayTransformer"))
    }
}
