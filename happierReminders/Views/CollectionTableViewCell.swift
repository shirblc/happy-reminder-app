//
//  CollectionTableViewCell.swift
//  happierReminders
//
//  Created by Shir Bar Lev on 24/04/2022.
//

import UIKit

class CollectionTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var notificationIndicatorImage: UIImageView!
    
    override func prepareForReuse() {
        self.titleLabel.text = nil
        self.subtitleLabel.text = nil
    }
}
