//
//  ViewQuoteViewController.swift
//  happierReminders
//
//  Created by Shir Bar Lev on 11/05/2022.
//

import UIKit

class ViewQuoteViewController: UIViewController {
    var quote: Quote!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var quoteTextView: UITextView!
    @IBOutlet weak var sourceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        typeLabel.text = "\(quote.type!) Quote:"
        quoteTextView.text = quote.text
        
        if let source = quote.source {
            sourceLabel.text = source
        } else {
            sourceLabel.text = ""
        }
    }
    
}
