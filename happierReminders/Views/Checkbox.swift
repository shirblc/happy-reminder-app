//
//  Checkbox.swift
//  happierReminders
//
//  Created by Shir Bar Lev on 06/05/2022.
//

import UIKit

// Tiny checkbox class
class Checkbox: UIButton {
    override var isSelected: Bool {
        get {
            return super.isSelected
        }
        set(newSelected) {
            super.isSelected = newSelected
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // setup
    // Sets up the checkbox
    func setup() {
        setImage(UIImage(systemName: "square"), for: .normal)
        setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        addTarget(self, action: #selector(handleTap(_:)), for: .touchUpInside)
        isSelected = false
    }
    
    // handleSelection
    // Checks/unchecks the checkbox
    @objc func handleTap(_ sender: Any) {
        isSelected = !isSelected
        sendActions(for: .valueChanged)
    }
}
