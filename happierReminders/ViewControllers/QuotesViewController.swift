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
        dataManager = (tabBarController as? CollectionTabBarViewController)?.dataManager
        collection = (tabBarController as? CollectionTabBarViewController)?.collection
        setupFetchedResultsController()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        self.setupTopToolbar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupFetchedResultsController()
        self.setupTopToolbar()
        tableView.reloadData()
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
            
            if let sender = sender as? Quote {
                addQuoteVC.quote = sender
            }
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
    
    // setupTopToolbar
    // Sets up the top toolbar's items & title
    func setupTopToolbar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addQuote))
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(startEdit))
        let finishedEditButton = UIBarButtonItem(title: "Finish", style: .done, target: self, action: #selector(stopEdit))
        tabBarController?.navigationItem.rightBarButtonItems = tableView.isEditing ? [addButton, finishedEditButton] : [addButton, editButton]
        tabBarController?.title = collection.name
    }
    
    // MARK: UITableViewDataSource & UITableViewDelegate
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete) {
            deleteQuote(indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, handleActionPerformed in
            self.deleteQuote(indexPath: indexPath)
        }
        let editAction = UIContextualAction(style: .normal, title: "Edit") { action, view, handleActionPerformed in
            self.performSegue(withIdentifier: "addQuoteSegue", sender: self.quotesFRC.object(at: indexPath))
        }
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch(type) {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .left)
        case .update:
            self.tableView.reloadRows(at: [indexPath!], with: .left)
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .left)
        case .move:
            self.tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            print("This isn't implemented yet...")
            self.tableView.reloadData()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    // MARK: Utils
    // showErrorAlert
    // Shows an error alert
    func showErrorAlert(error: Error, retryHandler: (() -> Void)?) {
        DispatchQueue.main.async {
            let alert = AlertFactory.createErrorAlert(error: error.localizedDescription, dismissHandler: { _ in
                self.dismiss(animated: true)
                AlertFactory.activeAlert = nil
            }, retryHandler: retryHandler)
            AlertFactory.activeAlert = alert
            self.present(alert, animated: true)
        }
    }
    
    // startEdit
    // Starts editing mode
    @objc func startEdit() {
        tableView.setEditing(true, animated: true)
        setupTopToolbar()
    }
    
    // stopEdit
    // Exits editing mode
    @objc func stopEdit() {
        tableView.setEditing(false, animated: true)
        setupTopToolbar()
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
    
    func deleteQuote(indexPath: IndexPath) {
        dataManager.viewContext.perform {
            let quoteToDelete = self.quotesFRC.object(at: indexPath)
            self.dataManager.viewContext.delete(quoteToDelete)
            self.dataManager.saveContext(useViewContext: true) { error in
                self.showErrorAlert(error: error, retryHandler: nil)
            }
        }
    }
}
