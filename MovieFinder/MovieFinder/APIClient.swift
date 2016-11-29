//
//  APIClient.swift
//  MovieFinder
//
//  Created by Christopher Webb-Orenstein on 11/28/16.
//  Copyright © 2016 Christopher Webb-Orenstein. All rights reserved.
//

import Foundation
import UIKit

protocol DataOp {
    
}

class APIClient {
    
    let store = DataStore.sharedInstance
    
    var queue = OperationQueue()
    let session = URLSession(configuration: URLSessionConfiguration.default)
    var returnData: JSONData!
    var urls = [String]()
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
//                if self.urls.contains(movie.posterURL) == false {
//                    self.urls.append(movie.posterURL)
//                }
                
                let url = URL(string: movie.posterURL)
                //print(self.store.uids)
                //print(self.urls)
                
                
                print(!self.urls.contains(movie.posterURL))
                
                if !self.urls.contains(movie.posterURL) {
                    self.urls.append(movie.posterURL)
                    print("****************")
                    print(self.urls)
                    print("---------------------")
                    print(movie.posterURL)
                    // print (url?.absoluteString)
                    //self.movieDataArray.remove(at: self.movieDataArray.count - 1)
                    //print(self.store.uids)
                    //print(self.movieDataArray)
                    //self.store.uids.append()
                    
                } else if self.urls.contains(movie.posterURL) {
                    //self.urls.append(movie.posterURL)
                    print("@@@@@@@@@@@@@@@@@")
                    print(self.movieDataArray)
                    return 
                }
                
                //print(self.movieDataArray)
                //print("@@@@@@@@@@@@@@@@@@@@@@")
                
               // print(self.urls)
                self.store.uids.append(movie.uid)
                self.urls.append(movie.posterURL)
                //print(self.movieDataArray)
                
                // print(self.urls)
                //print(self.store.uids)
                self.downloadNewImage(url: url!, handler: { image in
                    
                    var returnMovie = movie
                    returnMovie.posterImage = image
                    self.myMovies(passedData: returnMovie, handler: { movie in
                        var test = movie
                        self.movieDataArray.append(test)
                    })
                    var setMovies = self.movieDataArray as? [Movie]
                    self.store.searchResults.append(contentsOf: setMovies!)
                    handler(self.store.searchResults)
                })
                
                
                //                self.downloadNewImage(url: url!, handler: { image in
                //                    var returnMovie = movie
                //                    returnMovie.posterImage = image
                //                    self.myMovies(passedData: returnMovie, handler: { movie in
                //                        var test = movie
                //                        self.movieDataArray.append(test)
                //                    })
                //                    var setMovies = self.movieDataArray as? [Movie]
                //                    self.store.searchResults.append(contentsOf: setMovies!)
                //                    handler(self.store.searchResults)
                //                })
            })
        }
    }
    
    func movieDataFunc(passedData: [AnyObject], handler: @escaping (Movie) -> Void) {
        for databit in passedData {
            var newMovie = Movie()
            
            newMovie.title = (databit["Title"] as? String)!
            newMovie.posterURL = (databit["Poster"] as? String)!
            newMovie.imdbID = (databit["imdbID"] as? String)!
            newMovie.year = (databit["Year"] as? String)!
            handler(newMovie)
            
            //            if urls.contains(newMovie.posterURL) {
            //                print("here")
            //                continue
            //            } else {
            //                handler(newMovie)
            //            }
        }
        
        //        passedData.forEach { bit in
        //
        //            var newMovie = Movie()
        //
        //            newMovie.title = (bit["Title"] as? String)!
        //            newMovie.posterURL = (bit["Poster"] as? String)!
        //            newMovie.imdbID = (bit["imdbID"] as? String)!
        //            newMovie.year = (bit["Year"] as? String)!
        //
        //            if urls.contains(newMovie.posterURL) {
        //                break
        //            }
        //
        ////            if self.urls.contains(newMovie.posterURL) {
        ////                print("yes")
        ////                print(self.urls)
        ////                return
        ////            }
        ////            self.urls.append(newMovie.posterURL)
        //
        //
        //            handler(newMovie)
        //        }
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
        //
        //        if self.urls.contains(url.absoluteString) {
        //            print("yes")
        //            print(self.urls)
        //            return
        //        }
        //        self.urls.append(url.absoluteString)
        
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

















