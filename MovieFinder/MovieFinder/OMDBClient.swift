//
//  OMDBClient.swift
//  MovieFinder
//
//  Created by Christopher Webb-Orenstein on 11/21/16.
//  Copyright © 2016 Christopher Webb-Orenstein. All rights reserved.
//

import UIKit

typealias JSONData = [String: Any]


struct Client {
    
    let session = URLSession(configuration: URLSessionConfiguration.default)
    var queue = OperationQueue()
    var returnData: JSONData!
    
    fileprivate static let baseURL: String = Constants.Web.baseURL
    
    func get(request: ClientRequest, handler: @escaping (JSONData?) -> Void) {
        
        let urlRequest = generateURLRequest(with: request.url)
        let urlSession = generateURLSession()
        
        sendAPICall(withSession: urlSession, request: urlRequest) { json in
            guard let json = json else { handler(nil); return }
            handler(json)
        }
    }
}

extension Client {
    
    func generateURLRequest(with url: URL) -> URLRequest {
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }
    
    func generateURLSession() -> URLSession {
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        return session
    }
    
    func sendAPICall(withSession session: URLSession, request: URLRequest, handler: @escaping (JSONData?) -> Void) {
        
        var jsonReturn:JSONData!
        getDataFromUrl(url: request.url!, completion: { data, response, error in
            guard let data = data else { handler(nil); return }
            guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! JSONData else { handler(nil); return }
            jsonReturn = json
            handler(jsonReturn)
        })
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        
        let urlRequest = URLRequest(url:url)
        session.dataTask(with: urlRequest, completionHandler: { data, response, error in
            completion(data, response, error)
        }).resume()
    }
    
    func downloadImage(url: URL, handler: @escaping (UIImage?) -> Void) {
        
        print("Download Started")
        getDataFromUrl(url: url) { (data, response, error)  in
            let op2 = BlockOperation(block: {
                guard let data = data, error == nil else { return }
                OperationQueue.main.addOperation({
                    handler(UIImage(data: data)!)
                })
            })
            op2.completionBlock = {
                print("Op2 finished")
            }
            self.queue.addOperation(op2)
        }
    }
}

enum ClientRequest {
    
    case search(searchTerm: ValidSearch), page(searchTerm: ValidSearch, pageNumber:String)
    
    var url: URL {
        
        switch self {
        case let .search(searchTerm):
            return URL.clientURL(withEndpoint: "/?s=\(searchTerm.string)")
        case let .page(searchTerm, pageNumber):
            return URL.clientURL(withEndpoint:"/?s=\(searchTerm.string)&page=\(pageNumber)")
        }
    }
    
}

struct ValidSearch {
    
    let string: String
    
    init?(_ string: String) {
        guard let escapedString = string.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return nil }
        self.string = escapedString
    }
}

extension URL {
    
    static func clientURL(withEndpoint endpoint: String) -> URL {
        return URL(string: Client.baseURL + endpoint)!
    }
}
