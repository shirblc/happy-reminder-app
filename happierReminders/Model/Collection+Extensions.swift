//
//  Collection+Extensions.swift
//  happierReminders
//
//  Created by Shir Bar Lev on 09/05/2022.
//

import Foundation

extension Collection {
    // getRandomQuote
    // Grabs a ranom quote from the collection
    func getRandomQuote() -> Quote? {
        let quoteList = self.quotes?.allObjects as? [Quote]
        
        if let quoteList = quoteList, quoteList.count > 0 {
            let randomQuoteIndex = Int.random(in: 0...quoteList.count)
            return quoteList[randomQuoteIndex]
        } else {
            return nil
        }
    }
}
