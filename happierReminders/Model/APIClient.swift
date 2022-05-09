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
    
    // MARK: Quote-Specific Methods
    // executeDataTask
    // Executes a data task for fetching quotes
    func executeDataTask(type: apis) async throws -> QuoteData {
        let requestUrl = URLRequest(url: URL(string: type.rawValue)!)
        
        do {
            let response = try await networkSession.data(for: requestUrl)
            
            guard (200..<399).contains((response.1 as! HTTPURLResponse).statusCode) else {
                let statusCode = (response.1 as! HTTPURLResponse).statusCode
                let error = getErrorString(type: type, responseData: response.0)
                
                if (400..<499).contains(statusCode) {
                    throw HTTPError.ClientError(errorText: "\(statusCode) Error: \(error)")
                } else {
                    throw HTTPError.ServerError(errorText: "\(statusCode) Error: \(error)")
                }
            }
            
            return try getResponseData(type: type, responseData: response.0)
        } catch {
            throw error
        }
    }
    
    // getResponseData
    // Gets the quote's data from the response
    func getResponseData(type: apis, responseData: Data) throws -> QuoteData {
        var quote: QuoteData
        
        do {
            if(type == .Affirmation || type == .Insperational) {
                let responseJSON = try JSONSerialization.jsonObject(with: responseData) as! [String: Any]
                let quoteText = type == .Affirmation ? responseJSON["affirmation"] : responseJSON["content"]
                let quoteSource = type == .Affirmation ? nil : responseJSON["author"]
                let quoteType = type == .Affirmation ? "Affirmation" : "Insperational"
                quote = QuoteData(text: quoteText as! String, source: quoteSource as? String, type: quoteType)
            } else {
                let quotes = try JSONDecoder().decode(MotivationalQuotesResponse.self, from: responseData)
                let currentQuote = quotes.quotes[0]
                quote = QuoteData(text: currentQuote.text, source: currentQuote.author, type: "Motivational")
            }
        } catch {
            throw error
        }
        
        return quote
    }
    
    // getErrorString
    // Gets the error description from the response data
    func getErrorString(type: apis, responseData: Data) -> String {
        switch(type) {
        case .Affirmation:
            let error = String(data: responseData, encoding: .utf8)
            return "An error occurred while fetching the affirmation: \(String(describing: error))"
        case .Insperational:
            let responseJSON = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any]
            let errorMsg = responseJSON?["statusMessage"] as? String ?? "An error occurred while fetching the quote"
            return "Remote Server resopnsed: \(errorMsg)"
        case .Motivational:
            let error = String(data: responseData, encoding: .utf8)
            return "An error occurred while fetching the quote: \(String(describing: error))"
        }
    }
}
