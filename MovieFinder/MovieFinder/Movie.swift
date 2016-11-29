//
//  Movie.swift
//  MovieFinder
//
//  Created by Christopher Webb-Orenstein on 11/29/16.
//  Copyright © 2016 Christopher Webb-Orenstein. All rights reserved.
//

import UIKit

class Movie: Hashable {
    
    var uid: Int
    var title: String
    var imdbID: String
    var posterURL: String
    var year: String
    var posterImage: UIImage?
    
    var hashValue: Int {
        return self.uid
    }
    
    init() {
        self.title = "None"
        self.imdbID = "N/A"
        self.posterURL = "Uknown"
        self.year = "None"
        self.posterImage = nil
        self.uid = title.hash
    }
    
    static func ==(lhs: Movie, rhs: Movie) -> Bool {
        return lhs.uid == rhs.uid
    }
}
