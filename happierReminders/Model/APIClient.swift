//
//  APIClient.swift
//  happierReminders
//
//  Created by Shir Bar Lev on 09/05/2022.
//

import Foundation

struct QuoteData {
    let text: String
    let source: String?
    let type: String
}

enum HTTPError: Error, LocalizedError {
    case ClientError(errorText: String)
    case ServerError(errorText: String)
}

class APIClient {
    // MARK: Variables & Constants
    let networkSession = URLSession.shared
    static let shared = APIClient()
    enum apis: String {
        case Affirmation = "https://www.affirmations.dev"
        case Insperational = "https://api.quotable.io/random?tags=inspirational"
        case Motivational = "https://private-anon-33f3a67ab8-goquotes.apiary-proxy.com/api/v1/random/1?type=tag&val=motivational"
    }
    
    private init () {
        
    }
    

}
