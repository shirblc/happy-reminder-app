//
//  ManageViewController.swift
//  happierReminders
//
//  Created by Shir Bar Lev on 05/05/2022.
//

import UIKit

class ManageViewController: UIViewController {
    // MARK: Variables & Constants
    var collection: Collection!
    var dataManager: DataManager!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var sendNotificationsSwitch: UISwitch!
    @IBOutlet weak var timeSelectionPicker: UIDatePicker!
    @IBOutlet weak var daysSelect: Select!
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        dataManager = (tabBarController as? CollectionTabBarViewController)?.dataManager
        collection = (tabBarController as? CollectionTabBarViewController)?.collection
        tabBarController?.navigationItem.rightBarButtonItems = []
        sendNotificationsSwitch.addTarget(self, action: #selector(toggleNotificationUI), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupControlsValues()
        toggleNotificationUI()
        NotificationCenter.default.addObserver(self, selector: #selector(toggleSaveButton(textFieldNotification:)), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
    }
    
    // MARK: UI/Controls Handling
    // setupControlsValues
    // Sets up the controls to reflect the Collection's values
    func setupControlsValues() {
        nameTextField.text = collection.name
        sendNotificationsSwitch.isOn = collection.sendNotifications
        let notificationTime = collection.notificationTime?.split(separator: ":")
        
        if let notificationTime = notificationTime, notificationTime.count > 0 {
            let date = DateComponents(calendar: .current, timeZone: nil, era: nil, year: nil, month: nil, day: nil, hour: Int(notificationTime[0]), minute: Int(notificationTime[1]), second: 0, nanosecond: 0, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
            timeSelectionPicker.date = date.date ?? Date()
        }
        
        daysSelect.selectedDays = (collection.notificationDays ?? []) as! [Int]
    }
    
    // toggleNotificationUI
    // Disables/enables the notification-related UI controls depending on whether sendNotifications is true or false
    @objc func toggleNotificationUI() {
        daysSelect.isEnabled = sendNotificationsSwitch.isOn ? true : false
        timeSelectionPicker.isEnabled = sendNotificationsSwitch.isOn ? true : false
    }
    
    // toggleSaveButton
    // Disables/enables the save button depending on whether there's text
    @objc func toggleSaveButton(textFieldNotification: NSNotification) {
        let textField = textFieldNotification.object as! UITextField
        
        // make sure there's a name; otherwise disable the button
        guard let text = textField.text, text.count > 0 else {
            saveButton.isEnabled = false
            return
        }
        
        saveButton.isEnabled = true
    }
    
    // MARK: Data Handling
    // translateDateTimeToString
    // Translates the datetime selected to the required CoreData dict
    func translateDateTimeToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .full
        let stringTimeParts = formatter.string(from: date).split(separator: ":")
        
        return String(stringTimeParts[0]) + ":" + String(stringTimeParts[1])
    }
    
    // saveSettings
    // Saves the settings
    @IBAction func saveSettings(_ sender: UIButton) {
        Task {
            let newName = nameTextField.text
            var sendNotifications = sendNotificationsSwitch.isOn
            var notificationTimeStr: String = ""
            var selectedDays: [Int] = []
            var notificationIDs: [String] = []
            
            // If sendNotifications is true, set up the notifications
            if(sendNotifications) {
                let notificationTime = timeSelectionPicker.date
                notificationTimeStr = translateDateTimeToString(date: notificationTime)
                selectedDays = daysSelect.selectedDays
                notificationIDs = await scheduleNotifications(selectedDays: selectedDays, time: notificationTimeStr, collectionID: collection.uuid!.uuidString, existingNotifications: collection.scheduledNotifications as? [String])
                
                if(notificationIDs.count > 0) {
                    sendNotifications = false
                }
            } else {
                // if the user turned notifications off, delete any pending requests
                if let scheduledNotifications = collection.scheduledNotifications {
                    NotificationController.shared.deleteScheduledNotifications(existingNotifications: scheduledNotifications as! [String])
                }
            }
            
            // Then save all the data
            await dataManager.backgroundContext.perform {
                let bgContextCollection = self.dataManager?.backgroundContext.object(with: self.collection!.objectID) as! Collection
                bgContextCollection.name = newName
                bgContextCollection.sendNotifications = sendNotifications
                bgContextCollection.notificationTime = notificationTimeStr
                bgContextCollection.notificationDays = selectedDays as NSArray
                bgContextCollection.scheduledNotifications = notificationIDs as NSArray
                
                self.dataManager.saveContext(useViewContext: false, errorCallback: { error in
                    self.showErrorAlert(error: error.localizedDescription)
                })
            }
        }
    }
    
    // scheduleNotifications
    // Build the notification data and trigger sending notifications
    func scheduleNotifications(selectedDays: [Int], time: String, collectionID: String, existingNotifications: [String]?) async -> [String] {
        // if there's a quote, try to schedule it
        let notificationData = UserNotificationData(daysOfWeek: selectedDays, time: time, collection: collection)
        let notificationIDs = await NotificationController.shared.scheduleNotifications(notificationsData: notificationData, errorHandler: { errorStr in
            self.showErrorAlert(error: errorStr)
        }, existingNotifications: existingNotifications)
        
        if(notificationIDs.count > 0) {
            return notificationIDs
        // otherwise alert the user we can't schedule notifications, but save the preferences anyway
        } else {
            showErrorAlert(error: "Warning: Can't schedule notifications without quotes. Your preferences will be saved, but no notifications will be sent until quotes are added.")
            return []
        }
    }
    
    // showErrorAlert
    // Shows an error alert
    func showErrorAlert(error: String) {
        DispatchQueue.main.async {
            let alert = AlertFactory.createErrorAlert(error: error, dismissHandler: { _ in
                self.dismiss(animated: true)
                AlertFactory.activeAlert = nil
            }, retryHandler: nil)
            AlertFactory.activeAlert = alert
            self.present(alert, animated: true)
        }
    }
}
