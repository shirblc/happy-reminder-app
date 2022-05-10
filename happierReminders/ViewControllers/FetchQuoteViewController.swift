//
//  FetchQuoteViewController.swift
//  happierReminders
//
//  Created by Shir Bar Lev on 09/05/2022.
//

import UIKit

class FetchQuoteViewController: UIViewController, ErrorHandler {
    // MARK: Variables & Constants
    let optionsMapping: [Int: APIClient.apis] = [0: .Affirmation, 1: .Insperational, 2: .Motivational]
    var dataManager: DataManager!
    var collection: Collection!
    var currentQuote: QuoteData?
    var quoteSaved: Bool = true
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
                self.currentQuote = quote
                
                DispatchQueue.main.async {
                    self.quoteLabel.text = quote.text
                    self.sourceLabel.text = quote.source
                }
            } catch {
                if let error = error as? HTTPError, let errorDescription = error.errorDescription {
                    self.showErrorAlert(error: errorDescription, retryHandler: nil)
                } else {
                    self.showErrorAlert(error: error.localizedDescription, retryHandler: nil)
                }
            }
        }
    }
    
    // addQuote
    // Adds the selected quote to the collection
    @IBAction func addQuote(_ sender: Any) {
        guard let currentQuote = currentQuote else { return }

        dataManager.backgroundContext.perform {
            let bgContextCollection = self.dataManager.backgroundContext.object(with: self.collection.objectID) as! Collection
            let quote = Quote(context: self.dataManager.backgroundContext)
            quote.text = currentQuote.text
            quote.source = currentQuote.source
            quote.type = currentQuote.type
            quote.collection = bgContextCollection
            
            self.dataManager.saveContext(useViewContext: false, errorCallback: {
                error in
                self.quoteSaved = false
                self.showErrorAlert(error: error.localizedDescription, retryHandler: nil)
            })
            
            // if the quote was saved, go back to the quotes VC
            if(self.quoteSaved) {
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
}
