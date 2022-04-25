//
//  CollectionsViewController.swift
//  happierReminders
//
//  Created by Shir Bar Lev on 22/04/2022.
//

import UIKit
import CoreData

let reuseIdentifier = "collectionCellView"

class CollectionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: Variables & Constants
    var dataManager: DataManager!
    var collectionsFRC: NSFetchedResultsController<Collection>!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.setupFetchedResultsController()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createCollection))
        NotificationCenter.default.addObserver(self, selector: #selector(toggleContinueButton(textFieldNotification:)), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collectionsFRC.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellView = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! CollectionTableViewCell
        let cellData = self.collectionsFRC.object(at: indexPath)
        
        cellView.titleLabel.text = cellData.name
        cellView.subtitleLabel.text = "\(cellData.quotes?.count ?? 0)"
        cellView.notificationIndicatorImage.image = cellData.sendNotifications ? UIImage(systemName: "checkmark") : UIImage(systemName: "xmark")
        
        return cellView
    }
    
    // MARK: Fetched Results Controller
    // setupFetchedResultsController
    // Sets up the FetchedResultsController
    func setupFetchedResultsController() {
        let fetchRequest = Collection.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        
        collectionsFRC = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataManager.viewContext, sectionNameKeyPath: nil, cacheName: "collections")
        
        do {
            try collectionsFRC.performFetch()
        } catch {
            showErrorAlert(error: error, retryHandler: setupFetchedResultsController)
        }
    }
    
    // MARK: Helpers
    // showErrorAlert
    // Shows an error alert
    func showErrorAlert(error: Error, retryHandler: (() -> Void)?) {
        DispatchQueue.main.async {
            let errorAlert = AlertFactory.createErrorAlert(error: error, dismissHandler: { _ in
                AlertFactory.activeAlert = nil
                self.dismiss(animated: true)
            }, retryHandler: retryHandler)
            AlertFactory.activeAlert = errorAlert
            self.present(errorAlert, animated: false)
        }
    }
    
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
            
            self.dataManager.saveContext(useViewContext: true) { error in
                self.showErrorAlert(error: error) {
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
}
