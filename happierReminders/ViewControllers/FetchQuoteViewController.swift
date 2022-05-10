//
//  FetchQuoteViewController.swift
//  happierReminders
//
//  Created by Shir Bar Lev on 09/05/2022.
//

import UIKit

class FetchQuoteViewController: UIViewController {
    // MARK: Variables & Constants
    let optionsMapping: [Int: APIClient.apis] = [0: .Affirmation, 1: .Insperational, 2: .Motivational]
    var dataManager: DataManager!
    var collection: Collection!
    @IBOutlet weak var typeSelect: Select!
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        typeSelect.setSelectData(menuTitle: "Select Quote Type", multipleSelect: false, options: ["Affirmation": 0, "Insperational": 1, "Motivational": 2])
        typeSelect.addTarget(self, action: #selector(fetchQuote), for: .valueChanged)
    }
    
    // MARK: Functionality
    // fetchQuote
    // Fetches a new quote based on the selected option
    @objc func fetchQuote(_ sender: Select) {
        let selectedQuoteType = optionsMapping[sender.selectedDays[0]]
        
        Task {
            do {
                let quote = try await APIClient.shared.executeDataTask(type: selectedQuoteType!)
                
                DispatchQueue.main.async {
                    self.quoteLabel.text = quote.text
                    self.sourceLabel.text = quote.source
                }
            } catch {
                if let error = error as? HTTPError, let errorDescription = error.errorDescription {
                    self.showErrorAlert(error: errorDescription)
                } else {
                    self.showErrorAlert(error: error.localizedDescription)
                }
            }
            
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
