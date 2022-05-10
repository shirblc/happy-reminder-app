//
//  MotivationalQuote.swift
//  happierReminders
//
//  Created by Shir Bar Lev on 09/05/2022.
//

import Foundation

struct MotivationalQuote: Codable {
    let text: String
    let author: String
    let tag: String
}

struct MotivationalQuotesResponse: Codable {
    let status: Int
    let message: String
    let count: Int
    let quotes: [MotivationalQuote]
}
