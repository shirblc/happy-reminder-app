//
//  Select.swift
//  happierReminders
//
//  Created by Shir Bar Lev on 08/05/2022.
//

import UIKit
import Collections

class Select: UIButton {
    // MARK: Variables & Constants
    private var selectedDaysInternal: [Int] = []
    let dayOptions: OrderedDictionary = ["Monday": 0, "Tuesday": 1, "Wednesday": 2, "Thursday": 3, "Friday": 4, "Saturday": 5, "Sunday": 6]
    var selectedDays: [Int] {
        get {
            return selectedDaysInternal
        }
        set(newSelectedDays) {
            selectedDaysInternal = newSelectedDays
            setUpMenu()
        }
    }
    var dayActions: [UIAction] {
        var actions: [UIAction] = []
        for day in dayOptions {
            let imageName = selectedDays.contains(day.value) ? "checkmark.square.fill" : "square"
            let imageToUse = UIImage(systemName: imageName)
            let action = UIAction(title: day.key, image: imageToUse, identifier: nil, discoverabilityTitle: day.key, attributes: [], state: .off) { action in
                self.toggleSelection(selectedValue: day.value)
            }
            actions.append(action)
        }
        
        return actions
    }
    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpMenu()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpMenu()
    }
    
    // MARK: Functionality
    // setUpMenu
    // Sets up the initial/updated menu
    func setUpMenu() {
        let menu = UIMenu(title: "Select Day", image: nil, identifier: nil, options: [.displayInline], children: dayActions)
        self.menu = menu
        self.showsMenuAsPrimaryAction = true
    }
    
    // toggleSelection
    // Adds an item/removes it from the selected days
    func toggleSelection(selectedValue: Int) {
        // if it's selected, remove it
        if(selectedDaysInternal.contains(selectedValue)) {
            selectedDaysInternal.remove(at: selectedDaysInternal.firstIndex(of: selectedValue)!)
        // otherwise add it
        } else {
            selectedDaysInternal.append(selectedValue)
        }
        setUpMenu()
    }
    
}
