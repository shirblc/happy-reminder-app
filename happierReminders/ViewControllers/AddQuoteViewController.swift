//
//  AddQuoteViewController.swift
//  happierReminders
//
//  Created by Shir Bar Lev on 04/05/2022.
//

import UIKit

class AddQuoteViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    let datePickerOptions = ["Affirmation", "Insperational", "Motivational", "Personal", "Zen"]
    @IBOutlet weak var quoteTextTextField: UITextField!
    @IBOutlet weak var quoteSourceTextField: UITextField!
    @IBOutlet weak var quoteTypePicker: UIPickerView!
    @IBOutlet weak var addButton: UIButton!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        quoteTypePicker.dataSource = self
        quoteTypePicker.delegate = self
        addButton.isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextfieldChange), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: nil)
    }
    
    // MARK: UIPickerViewDataSource & UIPickerViewDelegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return datePickerOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return datePickerOptions[row]
    }
    
    // MARK: Functionality
    // handleTextfieldChange
    // Handles changes to the text fields
    @objc func handleTextfieldChange(textFieldNotification: NSNotification) {
        let textField = textFieldNotification.object as! UITextField
        
        if(textField == quoteTextTextField) {
            if let text = textField.text, text.count > 0 {
                addButton.isEnabled = true
            } else {
                addButton.isEnabled = false
            }
        }
    }
}
