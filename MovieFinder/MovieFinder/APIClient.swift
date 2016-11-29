//
//  APIClient.swift
//  MovieFinder
//
//  Created by Christopher Webb-Orenstein on 11/28/16.
//  Copyright © 2016 Christopher Webb-Orenstein. All rights reserved.
//

import Foundation
import UIKit

class APIClient {
    
    let store = DataStore.sharedInstance
    
    var queue = OperationQueue()
    let session = URLSession(configuration: URLSessionConfiguration.default)
    var returnData: JSONData!
    var movieDataArray: [Movie]!
    
    
    func get(request: ClientRequest, handler: @escaping ([Movie]?) -> Void) {
        
        var returnMovieData = [Movie]()
        let urlRequest = generateURLRequest(with: request.url)
        let urlSession = generateNewURLSession()
        
        self.queue.maxConcurrentOperationCount = 10
        self.queue.qualityOfService = .userInitiated
        
        sendNewAPICall(withSession: urlSession, request: urlRequest) { json in
            self.movieDataArray = [Movie]()
            
            guard let json = json else { handler(nil); return }
            guard let data = json as? AnyObject else { return }
            guard let movieSearch = data["Search"] as? [AnyObject] else { return }
            
            self.movieDataFunc(passedData: movieSearch, handler: { movie in
                
                let url = URL(string: movie.posterURL)
                self.downloadNewImage(url: url!, handler: { image in
                    var returnMovie = movie
                    returnMovie.posterImage = image
                    self.myMovies(passedData: returnMovie, handler: { movie in
                        var test = movie
                        
                        self.movieDataArray.append(test)
                    })
                    var setMovies = self.movieDataArray as? [Movie]
                    //var change = Set<Movie>(setMovies!)
                    self.store.searchResults.append(contentsOf: setMovies!)
                    //self.movieDataArray = Array(change)
                    handler(self.store.searchResults)
                })
            })
        }
    }
    
    func movieDataFunc(passedData: [AnyObject], handler: @escaping (Movie) -> Void) {
        passedData.forEach { bit in
            
            var newMovie = Movie()
            
            newMovie.title = (bit["Title"] as? String)!
            newMovie.posterURL = (bit["Poster"] as? String)!
            newMovie.imdbID = (bit["imdbID"] as? String)!
            newMovie.year = (bit["Year"] as? String)!
            
            handler(newMovie)
        }
    }
    
    func myMovies(passedData: Movie, handler: @escaping (Movie) -> Void) {
        self.movieDataArray.append(passedData)
    }
    
    func generateURLRequest(with url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }
    
    func generateNewURLSession() -> URLSession {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        return session
    }
    
    func sendNewAPICall(withSession session: URLSession, request: URLRequest, handler: @escaping (JSONData?) -> Void) {
        getNewDataFromUrl(url: request.url!, completion: { data, response, error in
            
            guard let data = data else { handler(nil); return }
            guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! JSONData else { handler(nil); return }
            
            handler(json)
        })
    }
    
    func downloadNewImage(url: URL, handler: @escaping (UIImage?) -> Void) {
        queue.maxConcurrentOperationCount = 5
        print("Download Started")
        
        getNewDataFromUrl(url: url) { (data, response, error)  in
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
    
    func getNewDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        let urlRequest = URLRequest(url:url)
        session.dataTask(with: urlRequest, completionHandler: { data, response, error in
            completion(data, response, error)
        }).resume()
    }
    
    func getNew(request: ClientRequest, handler: @escaping (JSONData?) -> Void) {
        
        let urlRequest = generateURLRequest(with: request.url)
        let urlSession = generateNewURLSession()
        
        sendNewAPICall(withSession: urlSession, request: urlRequest) { json in
            guard let json = json else { handler(nil); return }
            handler(json)
        }
    }
}


//class AsyncOperations: Operation {
//    let dataOperation: APIClient
//    var request: URLRequest
//    
//    var isExecuting: Bool {
//        get { return super.isExecuting }
//        set { super.isExecuting }
//    }
//    
//    func start() {
//        self.willChangeValue(forKey: "isExecuting")
//        self.isExecuting = true
//        self.didChangeValue(forKey: "isExecuting")
//        
//        OperationQueue.main.addOperation({
//            dataOperation.downloadNewImage(url: self.request.url!, handler: {
//                
//            })
//        })
//        
//    }
//
//}

















