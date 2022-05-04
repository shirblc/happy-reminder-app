//
//  QuotesViewController.swift
//  happierReminders
//
//  Created by Shir Bar Lev on 03/05/2022.
//

import UIKit
import CoreData


class QuotesViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    // MARK: Variables & Constants
    var dataManager: DataManager!
    var collection: Collection!
    var quotesFRC: NSFetchedResultsController<Quote>!
    let reuseIdentifier = "quoteCellView"
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupFetchedResultsController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        quotesFRC = nil
    }
    
    // MARK: Setup
    // setupFetchedResultsController
    // Sets up the fetched results controller for the current collection
    func setupFetchedResultsController() {
        quotesFRC = dataManager.setupFRC(managedClass: "Quote", predicate: NSPredicate(format: "collection == %@", collection), sortDescriptors: [NSSortDescriptor(key: "addedAt", ascending: false), NSSortDescriptor(key: "text", ascending: false)], cacheName: "collection\(String(describing: collection.name))Quotes")
        
        do {
            try quotesFRC.performFetch()
            quotesFRC.delegate = self
        } catch {
            showErrorAlert(error: error, retryHandler: setupFetchedResultsController)
        }
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let quoteForCellView = quotesFRC.object(at: indexPath)
        let cellView = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        var cellContent = cellView.defaultContentConfiguration()
        cellContent.text = quoteForCellView.text
        cellContent.secondaryText = quoteForCellView.source
        
        return cellView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quotesFRC?.sections?[section].numberOfObjects ?? 0
    }
    
    // MARK: Utils
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
