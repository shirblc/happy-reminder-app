//
//  CollectionsViewController.swift
//  happierReminders
//
//  Created by Shir Bar Lev on 22/04/2022.
//

import UIKit

let reuseIdentifier = "collectionCellView"

class CollectionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: Variables & Constants
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellView = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        return cellView
    }
}
