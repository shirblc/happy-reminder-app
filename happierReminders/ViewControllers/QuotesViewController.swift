//
//  QuotesViewController.swift
//  happierReminders
//
//  Created by Shir Bar Lev on 03/05/2022.
//

import UIKit
import CoreData

class QuotesViewController: UIViewController, NSFetchedResultsControllerDelegate {
    // MARK: Variables & Constants
    var dataManager: DataManager!
    var collection: Collection!
    var quotesFRC: NSFetchedResultsController<Quote>!

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewWillDisappear(animated)
        quotesFRC = nil
    }
    
    // MARK: Setup
    // setupFetchedResultsController
    // Sets up the fetched results controller for the current collection
    func setupFetchedResultsController() {
        let fetchRequest = Quote.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "collection == %@", collection)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "addedAt", ascending: false), NSSortDescriptor(key: "text", ascending: false)]
        
        quotesFRC = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataManager.viewContext, sectionNameKeyPath: nil, cacheName: "collection\(String(describing: collection.name))Quotes")
        
        do {
            try quotesFRC.performFetch()
            quotesFRC.delegate = self
        } catch {
            showErrorAlert(error: error, retryHandler: setupFetchedResultsController)
        }
    }
    
    // showErrorAlert
    // Shows an error alert
    func showErrorAlert(error: Error, retryHandler: (() -> Void)?) {
        DispatchQueue.main.async {
            let alert = AlertFactory.createErrorAlert(error: error, dismissHandler: { _ in
                self.dismiss(animated: true)
            }, retryHandler: retryHandler)
            AlertFactory.activeAlert = alert
            self.present(alert, animated: true)
        }
    }
}
