//
//  AlertFactory.swift
//  happierReminders
//
//  Created by Shir Bar Lev on 24/04/2022.
//

import Foundation
import UIKit

class AlertFactory {
    static var activeAlert: UIAlertController?
    
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
    
    // createInputAlert
    // Creates an input alert
    static func createInputAlert(title: String, message: String, cancelHandler: @escaping () -> Void, completionHandler: @escaping (String) -> Void, errorMessage: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            cancelHandler()
        }))
        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { _ in
            completionHandler(alert.textFields!.first!.text!)
        }))
        alert.actions.last?.isEnabled = false
        alert.addTextField { textField in
            textField.placeholder = message
        }
        
        return alert
    }
    
    // createConfirmAlert
    // Creates an alert to confirm before an action is taken
    static func createConfirmAlert(title: String, cancelHandler: @escaping () -> Void, completionHandler: @escaping () -> Void) -> UIAlertController {
        let alert = UIAlertController(title: title, message: "This action is irreversible!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            cancelHandler()
        }))
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { _ in
            completionHandler()
        }))
        
        return alert
    }
}
