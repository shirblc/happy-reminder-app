//
//  AddQuoteViewController.swift
//  happierReminders
//
//  Created by Shir Bar Lev on 04/05/2022.
//

import UIKit

class AddQuoteViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, ErrorHandler {
    // MARK: Variables & Constants
    var dataManager: DataManager!
    var collection: Collection!
    var quote: Quote?
    var quoteSaved: Bool = true
    let datePickerOptions = ["Affirmation", "Insperational", "Motivational", "Personal"]
    @IBOutlet weak var quoteTextTextField: UITextField!
    @IBOutlet weak var quoteSourceTextField: UITextField!
    @IBOutlet weak var quoteTypePicker: UIPickerView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        quoteTextTextField.delegate = self
        quoteSourceTextField.delegate = self
        quoteTypePicker.dataSource = self
        quoteTypePicker.delegate = self
        addButton.isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextfieldChange), name: UITextField.textDidChangeNotification, object: nil)
        setupScreenData()
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
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: UI/Controls Handling
    // setupScreenData
    // Sets up the inputs, title and button depending on whether we're editing or creating a quote
    func setupScreenData() {
        // If there's a quote, set up the screen for edit
        if let quote = quote {
            quoteTextTextField.text = quote.text
            quoteSourceTextField.text = quote.source
            
            if let type = quote.type {
                quoteTypePicker.selectRow(datePickerOptions.firstIndex(of: type) ?? 0, inComponent: 0, animated: true)
            }
            
            navigationController?.title = "Edit Quote"
            addButton.setTitle("Save Quote", for: .normal)
            addButton.addTarget(self, action: #selector(editQuote(_:)), for: .touchUpInside)
            addButton.isEnabled = true
        // Otherwise set it up for create
        } else {
            navigationController?.title = "Add Quote"
            addButton.setTitle("Add Quote", for: .normal)
            addButton.addTarget(self, action: #selector(addQuote(_:)), for: .touchUpInside)
        }
    }
    
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
    
    // MARK: Quote Manipulation
    // addQuote
    // Adds a new quote
    @objc func addQuote(_ sender: Any) {
        activityIndicator.startAnimating()
        
        dataManager.backgroundContext.perform {
            let newQuote = Quote(context: self.dataManager.backgroundContext)
            newQuote.collection = self.dataManager.backgroundContext.object(with: self.collection.objectID) as? Collection
            self.setUpAndSaveQuote(quoteToSave: newQuote)
        }
    }
    
    // editQuote
    // Edits an existing quote
    @objc func editQuote(_ sender: Any) {
        guard let quote = quote else { return }
        
        activityIndicator.startAnimating()

        dataManager.backgroundContext.perform {
            let editedQuote = self.dataManager.backgroundContext.object(with: quote.objectID) as! Quote
            self.setUpAndSaveQuote(quoteToSave: editedQuote)
        }
    }
    
    // saveQuote
    // Sets up the new/edited Quote's properties and saves t
    func setUpAndSaveQuote(quoteToSave: Quote) {
        DispatchQueue.main.async {
            let quoteText = self.quoteTextTextField.text
            let quoteSource = self.quoteSourceTextField.text
            let quoteType = self.datePickerOptions[self.quoteTypePicker.selectedRow(inComponent: 0)]
            
            self.dataManager.backgroundContext.perform {
                quoteToSave.text = quoteText
                quoteToSave.source = quoteSource
                quoteToSave.type = quoteType
                
                self.dataManager.saveContext(useViewContext: false, errorCallback: {
                    error in
                    self.quoteSaved = false
                    self.showErrorAlert(error: error.localizedDescription, retryHandler: nil)
                })
                
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
                
                // if the quote was saved, go back to the quotes VC
                if(self.quoteSaved) {
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
}
