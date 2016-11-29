//
//  DataStore.swift
//  MovieFinder
//
//  Created by Christopher Webb-Orenstein on 11/21/16.
//  Copyright © 2016 Christopher Webb-Orenstein. All rights reserved.
//

import Foundation
import UIKit

class DataStore {
    
    let api = Client()
    static let sharedInstance = DataStore()
    var searchResult: JSONData?
    var searchResults: [Movie] = [Movie]()
    var returndData: JSONData!
    
    func returnWebData(from searchTerm: String, completion: @escaping (JSONData?) -> Void) {
        var returnedJSON: JSONData?
        api.get(request: .search(searchTerm: ValidSearch(searchTerm)!), handler: { json in
            self.returndData = json
            returnedJSON = self.returndData
            completion(returnedJSON)
        })
    }
    
    func returnJSON(data:JSONData) -> JSONData {
        self.searchResult = data
        return self.searchResult!
    }
    
    func addMoviesToResults() {
        var movieData: JSONData!
        
        returnWebData(from: "star+wars", completion: { json in
            let data = self.returnJSON(data: json!)
            movieData = data
            self.searchResult = movieData
        })
        
        if let data = searchResult?["Search"] as! Array<AnyObject>? {
            var newMovie = Movie()
            print(self.searchResults)
            self.searchResults.removeAll()
            data.forEach { bit in
                
                newMovie.title = (bit["Title"] as? String)!
                newMovie.posterURL = (bit["Poster"] as? String)!
                newMovie.imdbID = (bit["imdbID"] as? String)!
                newMovie.year = (bit["Year"] as? String)!
                
                self.api.downloadImage(url: URL(string:String(describing: newMovie.posterURL))!, handler: { image in
                    newMovie.posterImage = image
                    DispatchQueue.main.async {
                        // implement
                    }
                })
                self.searchResults.append(newMovie)
            }
        }
    }
}
