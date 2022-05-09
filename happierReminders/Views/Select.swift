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
    private var selectOptions: OrderedDictionary<String, Int> = [:]
    private var menuTitle: String = ""
    private var multipleSelectEnabled: Bool = true
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
        for day in selectOptions {
            var imageToUse: UIImage?
            
            if(multipleSelectEnabled) {
                let imageName = selectedDays.contains(day.value) ? "checkmark.square.fill" : "square"
                imageToUse = UIImage(systemName: imageName)
            } else {
                imageToUse = nil
            }
            
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
    // setSelectData
    // Sets up the Select's data
    func setSelectData(menuTitle: String, multipleSelect: Bool, options: OrderedDictionary<String, Int>) {
        self.menuTitle = menuTitle
        multipleSelectEnabled = multipleSelect
        selectOptions = options
        setUpMenu()
    }
    
    // setUpMenu
    // Sets up the initial/updated menu
    func setUpMenu() {
        var menu: UIMenu
        
        if(multipleSelectEnabled) {
            menu = UIMenu(title: menuTitle, image: nil, identifier: nil, options: [.displayInline], children: dayActions)
        } else {
            menu = UIMenu(title: menuTitle, image: nil, identifier: nil, options: [.displayInline, .singleSelection], children: dayActions)
        }

        self.menu = menu
        self.showsMenuAsPrimaryAction = true
    }
    
    // toggleSelection
    // Adds an item/removes it from the selected days
    func toggleSelection(selectedValue: Int) {
        if(multipleSelectEnabled) {
            // if it's selected, remove it
            if(selectedDaysInternal.contains(selectedValue)) {
                selectedDaysInternal.remove(at: selectedDaysInternal.firstIndex(of: selectedValue)!)
            // otherwise add it
            } else {
                selectedDaysInternal.append(selectedValue)
            }
        } else {
            selectedDaysInternal = [selectedValue]
        }
        
        setUpMenu()
        sendActions(for: .valueChanged)
    }
    
}
