//
//  ManageViewController.swift
//  happierReminders
//
//  Created by Shir Bar Lev on 05/05/2022.
//

import UIKit

class ManageViewController: UIViewController {
    // MARK: Variables & Constants
    let checkboxToDayMapping = [1: "Sunday", 2: "Monday", 3: "Tuesday", 4: "Wednesday", 5: "Thursday", 6: "Friday", 7: "Saturday"]
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var sendNotificationsSwitch: UISwitch!
    @IBOutlet weak var timeSelectionPicker: UIDatePicker!
    @IBOutlet var dayCheckboxes: [Checkbox]!
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.navigationItem.rightBarButtonItems = []
        setupControlsValues()
        toggleNotificationUI()
        sendNotificationsSwitch.addTarget(self, action: #selector(toggleNotificationUI), for: .valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(toggleSaveButton(textFieldNotification:)), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    // MARK: UI/Controls Handling
    // setupControlsValues
    // Sets up the controls to reflect the Collection's values
    func setupControlsValues() {
        nameTextField.text = (tabBarController as? CollectionTabBarViewController)!.collection.name
        sendNotificationsSwitch.isOn = (tabBarController as? CollectionTabBarViewController)!.collection.sendNotifications
        let notificationTime = (tabBarController as? CollectionTabBarViewController)!.collection.notificationTime?.split(separator: ":")
        
        if let hour = notificationTime?[0], let minutes = notificationTime?[1] {
            let date = DateComponents(calendar: .current, timeZone: nil, era: nil, year: nil, month: nil, day: nil, hour: Int(hour), minute: Int(minutes), second: 0, nanosecond: 0, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
            timeSelectionPicker.date = date.date ?? Date()
        }
        
        for checkbox in dayCheckboxes {
            let checkboxDay = checkboxToDayMapping[checkbox.tag]
            let notificationDays: [String] = ((tabBarController as? CollectionTabBarViewController)!.collection.notificationDays ?? []) as! [String]
            checkbox.isSelected = notificationDays.contains(checkboxDay!) ? true : false
        }
    }
    
    // toggleNotificationUI
    // Disables/enables the notification-related UI controls depending on whether sendNotifications is true or false
    @objc func toggleNotificationUI() {
        for checkbox in dayCheckboxes {
            checkbox.isEnabled = sendNotificationsSwitch.isOn ? true : false
        }
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
        let dataManager = (tabBarController as? CollectionTabBarViewController)!.dataManager
        let collectionID = (self.tabBarController as? CollectionTabBarViewController)!.collection.objectID
        let newName = nameTextField.text
        let sendNotifications = sendNotificationsSwitch.isOn
        let notificationTime = timeSelectionPicker.date
        var selectedDays: [String] = []
        
        for checkbox in dayCheckboxes {
            if(checkbox.isSelected) {
                selectedDays.append(checkboxToDayMapping[checkbox.tag]!)
            }
        }
        
        dataManager?.backgroundContext.perform {
            let collection = dataManager?.backgroundContext.object(with: collectionID) as! Collection
            collection.name = newName
            collection.sendNotifications = sendNotifications
            
            if(sendNotifications) {
                collection.notificationTime = self.translateDateTimeToString(date: notificationTime)
                collection.notificationDays = selectedDays as NSArray
            }
            
            dataManager?.saveContext(useViewContext: false, errorCallback: { error in
                DispatchQueue.main.async {
                    let alert = AlertFactory.createErrorAlert(error: error, dismissHandler: { _ in
                        self.dismiss(animated: true)
                        AlertFactory.activeAlert = nil
                    }, retryHandler: nil)
                    AlertFactory.activeAlert = alert
                    self.present(alert, animated: true)
                }
            })
        }
    }
}
