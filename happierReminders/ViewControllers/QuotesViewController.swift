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
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        // set up the bar button
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addQuote))
        tabBarController?.navigationItem.rightBarButtonItems = [addButton]
        tabBarController?.title = collection.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupFetchedResultsController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        quotesFRC = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "addQuoteSegue") {
            let addQuoteVC = segue.destination as! AddQuoteViewController
            addQuoteVC.dataManager = self.dataManager
            addQuoteVC.collection = self.collection
        }
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
        cellView.contentConfiguration = cellContent
        
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
                AlertFactory.activeAlert = nil
            }, retryHandler: retryHandler)
            AlertFactory.activeAlert = alert
            self.present(alert, animated: true)
        }
    }
    
    // addQuote
    // Lets users choose where to get a quote from
    @objc func addQuote() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Add Quote", message: "Select source for the quote", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Write your own", style: .default) { _ in
                self.performSegue(withIdentifier: "addQuoteSegue", sender: nil)
            })
            // TODO: Add the option to fetch from the internet
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                self.dismiss(animated: true)
            }))
            self.present(alert, animated: true)
        }
    }
}
