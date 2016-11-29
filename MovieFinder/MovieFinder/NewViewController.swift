//
//  NewViewController.swift
//  MovieFinder
//
//  Created by Christopher Webb-Orenstein on 11/28/16.
//  Copyright © 2016 Christopher Webb-Orenstein. All rights reserved.
//

import UIKit

class NewViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    let store = DataStore.sharedInstance
    
    var poster = UIImageView()
    var movies = [Movie]()
    let searchController = UISearchController(searchResultsController: nil)
    let lockQueue = DispatchQueue(label: "promise_lock_queue", qos: .userInitiated)
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        var client = APClient()
        client.get(request: .search(searchTerm: ValidSearch("star+wars")!), handler: { json in
            var newMovies = [Movie]()
            newMovies = json!
            self.movies = newMovies
            self.collectionView.reloadData()
            //print(json!)
           // print(json)
        })
        print(self.movies)
        
       // collectionView.delegate = self
        //collectionView.dataSource = self
        //store.addMoviesToResults()
       // self.searchResults = self.store.searchResults
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            for movie in movies.enumerated() {
                print(movie.element)
            }
           // print(movies.count)
            return movies.count
        }
    
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
    
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            if indexPath.row == 0 {
                let headerCell = collectionView.dequeueReusableCell(withReuseIdentifier: "headerCell", for: indexPath as IndexPath) as! HeaderCollectionViewCell
                return headerCell
            } else {
                //collectionView.reloadData()
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath as IndexPath) as! MovieCollectionViewCell
                cell.moviePosterView.image = movies[indexPath.row].posterImage!
                return cell
            }
        }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
