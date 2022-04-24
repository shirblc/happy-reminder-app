//
//  AlertFactory.swift
//  happierReminders
//
//  Created by Shir Bar Lev on 24/04/2022.
//

import Foundation
import UIKit

class AlertFactory {
    init() {
        
    }
    
    // createErrorAlert
    // Creates an error alert
    static func createErrorAlert(error: Error, dismissHandler: @escaping (UIAlertAction) -> Void, retryHandler: (() -> Void)?) -> UIAlertController {
        let errorAlert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: dismissHandler))
        
        if let retryHandler = retryHandler {
            errorAlert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { action in
                retryHandler()
            }))
        }
        
        return errorAlert
    }
}
