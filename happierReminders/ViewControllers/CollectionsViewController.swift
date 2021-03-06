//
//  CollectionsViewController.swift
//  happierReminders
//
//  Created by Shir Bar Lev on 22/04/2022.
//

import UIKit
import CoreData


class CollectionsViewController: UIViewController, NSFetchedResultsControllerDelegate, ErrorHandler {
    // MARK: Variables & Constants
    var dataManager: DataManager!
    var collectionsFRC: NSFetchedResultsController<Collection>!
    let reuseIdentifier = "collectionCellView"
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createCollection))
        NotificationCenter.default.addObserver(self, selector: #selector(toggleContinueButton(textFieldNotification:)), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupFetchedResultsController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows {
            self.tableView.reloadRows(at: indexPathsForVisibleRows, with: .automatic)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.collectionsFRC = nil
    }
    
    // MARK: Fetched Results Controller
    // setupFetchedResultsController
    // Sets up the FetchedResultsController
    func setupFetchedResultsController() {
        collectionsFRC = dataManager.setupFRC(managedClass: "Collection", predicate: nil, sortDescriptors: [NSSortDescriptor(key: "name", ascending: false)], cacheName: "collections")
        
        do {
            try collectionsFRC.performFetch()
            collectionsFRC.delegate = self
        } catch {
            showErrorAlert(error: error.localizedDescription, retryHandler: setupFetchedResultsController)
        }
    }
    
    // NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [(indexPath ?? newIndexPath)!], with: .right)
        case .delete:
            tableView.deleteRows(at: [(indexPath ?? newIndexPath)!], with: .right)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        case .update:
            tableView.reloadRows(at: [(indexPath ?? newIndexPath)!], with: .right)
        @unknown default:
            print("This isn't implemented yet...")
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    // MARK: Helpers
    // prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewCollectionSegue" {
            let tabBarController = segue.destination as! CollectionTabBarViewController
            tabBarController.dataManager = dataManager
            tabBarController.collection = sender as? Collection
        }
    }
    
    // MARK: Collections
    // createCollection
    // Shows the alert for creating a collection
    @objc func createCollection() {        
        DispatchQueue.main.async {
            let alert = AlertFactory.createInputAlert(title: "Add Collection", message: "Enter collection name", cancelHandler: {
                AlertFactory.activeAlert = nil
                self.dismiss(animated: true)
            }, completionHandler: self.addCollection(title:), errorMessage: "You must enter name for the new collection")
            AlertFactory.activeAlert = alert
            self.present(alert, animated: true)
        }
    }
    
    // addCollection
    // Adds the collection to the store
    func addCollection(title: String) {
        dataManager.viewContext.perform {
            let collection = Collection(context: self.dataManager.viewContext)
            collection.name = title
            collection.sendNotifications = false
            collection.uuid = UUID()
            
            self.dataManager.saveContext(useViewContext: true) { error in
                self.showErrorAlert(error: error.localizedDescription) {
                    self.addCollection(title: title)
                }
            }
        }
    }
    
    // toggleContinueButton
    // Disables/enables the continue button depending on whether there's text
    @objc func toggleContinueButton(textFieldNotification: NSNotification) {
        let textField = textFieldNotification.object as! UITextField
        
        // make sure there's a name; otherwise disable the button
        guard let text = textField.text, text.count > 0 else {
            AlertFactory.activeAlert?.actions.last?.isEnabled = false
            return
        }
        
        AlertFactory.activeAlert?.actions.last?.isEnabled = true
    }
    
    // deleteCollection
    // Deletes the collection at the given index path
    func deleteCollection(indexPath: IndexPath) {
        DispatchQueue.main.async {
            let alert = AlertFactory.createConfirmAlert(title: "Delete Collection?") {
                self.dismiss(animated: true)
            } completionHandler: {
                let collectionToDelete = self.collectionsFRC.object(at: indexPath)
                self.dataManager.deleteManagedObject(object: collectionToDelete, useViewContext: true) { error in
                    self.showErrorAlert(error: error.localizedDescription, retryHandler: nil)
                }
                self.dismiss(animated: true)
            }
            self.present(alert, animated: true)
        }
    }
}
