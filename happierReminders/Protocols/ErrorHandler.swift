//
//  ErrorHandler.swift
//  happierReminders
//
//  Created by Shir Bar Lev on 10/05/2022.
//

import Foundation
import UIKit

protocol ErrorHandler where Self: UIViewController {
    
}

extension ErrorHandler {
    // showErrorAlert
    // Shows an error alert
    func showErrorAlert(error: String, retryHandler: (() -> Void)?) {
        DispatchQueue.main.async {
            let errorAlert = AlertFactory.createErrorAlert(error: error, dismissHandler: { _ in
                AlertFactory.activeAlert = nil
                self.dismiss(animated: true)
            }, retryHandler: retryHandler)
            AlertFactory.activeAlert = errorAlert
            self.present(errorAlert, animated: false)
        }
    }
}
