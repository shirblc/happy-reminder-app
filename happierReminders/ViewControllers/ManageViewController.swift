//
//  ManageViewController.swift
//  happierReminders
//
//  Created by Shir Bar Lev on 05/05/2022.
//

import UIKit

class ManageViewController: UIViewController {
    // MARK: Variables & Constants
    var dataManager: DataManager!
    var collection: Collection!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var sendNotificationsSwitch: UISwitch!
    @IBOutlet weak var timeSelectionPicker: UIDatePicker!
    @IBOutlet var dayCheckboxes: [Checkbox]!
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.navigationItem.rightBarButtonItems = []
        nameTextField.text = collection.name
        sendNotificationsSwitch.isOn = collection.sendNotifications
        sendNotificationsSwitch.addTarget(self, action: #selector(toggleNotificationUI), for: .valueChanged)
        toggleNotificationUI()
        NotificationCenter.default.addObserver(self, selector: #selector(toggleSaveButton(textFieldNotification:)), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    // MARK: UI/Controls Handling
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
    
    // saveSettings
    // Saves the settings
    @IBAction func saveSettings(_ sender: UIButton) {
        // TODO
    }
}
