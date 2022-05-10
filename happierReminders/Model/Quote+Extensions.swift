//
//  Quote+Extensions.swift
//  happierReminders
//
//  Created by Shir Bar Lev on 10/05/2022.
//

import Foundation

extension Quote {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.addedAt = Date()
    }
}
