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
    let creditMapping = [0: "the Affirmations API (github.com/annthurium/affirmations)", 1: "the Quotable API (github.com/lukePeavey/quotable)", 2: "the Go Quotes API (github.com/amsavarthan/goquotes-api)"]
    var dataManager: DataManager!
    var collection: Collection!
    var currentQuote: QuoteData?
    var quoteSaved: Bool = true
    @IBOutlet weak var typeSelect: Select!
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var apiCreditLabel: UILabel!
    @IBOutlet weak var tryAnotherButton: UIButton!
    @IBOutlet weak var saveQuoteButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var overlayView: UIView!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        typeSelect.setSelectData(menuTitle: "Select Quote Type", multipleSelect: false, options: ["Affirmation": 0, "Insperational": 1, "Motivational": 2])
        typeSelect.addTarget(self, action: #selector(fetchQuote), for: .valueChanged)
        tryAnotherButton.addTarget(self, action: #selector(fetchQuote), for: .touchUpInside)
        saveQuoteButton.titleLabel?.textAlignment = .center
        tryAnotherButton.titleLabel?.textAlignment = .center
    }
    
    // MARK: Functionality
    // fetchQuote
    // Fetches a new quote based on the selected option
    @objc func fetchQuote(_ sender: UIButton) {
        let selectedQuoteType = optionsMapping[typeSelect.selectedDays[0]]
        activityIndicator.startAnimating()
        overlayView.isHidden = false
        apiCreditLabel.text = "Quote provided by \(creditMapping[typeSelect.selectedDays[0]]!)"
        
        Task {
            do {
                let quote = try await APIClient.shared.executeDataTask(type: selectedQuoteType!)
                self.currentQuote = quote
                
                DispatchQueue.main.async {
                    self.quoteLabel.text = quote.text
                    self.sourceLabel.text = quote.source
                    self.tryAnotherButton.isEnabled = true
                    self.saveQuoteButton.isEnabled = true
                    self.activityIndicator.stopAnimating()
                    self.overlayView.isHidden = true
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
        
        activityIndicator.startAnimating()

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
