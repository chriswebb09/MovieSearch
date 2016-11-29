////
////  ViewController.swift
////  MovieFinder
////
////  Created by Christopher Webb-Orenstein on 11/21/16.
////  Copyright © 2016 Christopher Webb-Orenstein. All rights reserved.
////
//
import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let store = DataStore.sharedInstance
    var poster = UIImageView()
    var movies = [Movie]()
    
    fileprivate let itemsPerRow: CGFloat = 3
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    let searchController = UISearchController(searchResultsController: nil)
    let lockQueue = DispatchQueue(label: "promise_lock_queue", qos: .userInitiated)
    var client = APClient()
    
    @IBOutlet weak var searchButton: UIButton! {
        didSet {
            searchButton.layer.borderColor = UIColor.white.cgColor
            searchButton.layer.borderWidth = 1
        }
    }
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlow: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.frame = view.frame
        
        client.get(request: .search(searchTerm: ValidSearch("star+wars")!), handler: { json in
            var newMovies = [Movie]()
            newMovies = json!
            self.movies = newMovies
            self.collectionView.reloadData()
        })
        print(self.movies)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        for movie in movies.enumerated() {
            print(movie.element)
        }
        return movies.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        client.get(request: .search(searchTerm: ValidSearch("star+wars&page=2")!), handler: { json in
            var newMovies = [Movie]()
            newMovies = json!
            self.movies = newMovies
            self.collectionView.reloadData()
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath as IndexPath) as! MovieCollectionViewCell
        cell.moviePosterView.image = movies[indexPath.row].posterImage!
        cell.movieTitleLabel.text = movies[indexPath.row].title
        cell.layoutSubviews()
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath as IndexPath)
        return headerView
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

