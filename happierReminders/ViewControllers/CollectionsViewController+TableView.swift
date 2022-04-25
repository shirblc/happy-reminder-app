//
//  CollectionsViewController+TableView.swift
//  happierReminders
//
//  Created by Shir Bar Lev on 25/04/2022.
//

import Foundation
import UIKit

extension CollectionsViewController: UITableViewDelegate, UITableViewDataSource {
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
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, handleActionPerformed in
            self.deleteCollection(indexPath: indexPath)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
