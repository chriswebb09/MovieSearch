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
    var pageNumber = 1
    var searchTerm = "star+wars"
    var filteredMovies = [Movie]()
    var titles = [String]()
    fileprivate let itemsPerRow: CGFloat = 3
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    var client = APIClient()
    
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
        
        client.get(request: .search(searchTerm: ValidSearch(searchTerm)!), handler: { json in
            var newMovies = [Movie]()
            newMovies = json!
            self.movies = newMovies
            self.collectionView.reloadData()
        })
        //print(self.movies)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        for movie in movies.enumerated() {
            //print(movie.element)
        }
        //return 10
       return movies.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        self.view.endEditing(true)
        client.get(request: .search(searchTerm: ValidSearch("\(self.searchTerm)&page=\(pageNumber)")!), handler: { json in
            var newMovies = [Movie]()
            newMovies = json!
            self.movies = newMovies
            self.collectionView.reloadData()
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath as IndexPath) as! MovieCollectionViewCell
            self.store.titles.append(movies[indexPath.row].title)
            cell.moviePosterView.image = movies[indexPath.row].posterImage!
            cell.movieTitleLabel.text = movies[indexPath.row].title
            cell.layoutSubviews()
            return cell
//        var containsTitle = titles.contains(movies[indexPath.row].title)
//        
//        if !containsTitle {
//            titles.append(movies[indexPath.row].title)
//            cell.moviePosterView.image = movies[indexPath.row].posterImage!
//            cell.movieTitleLabel.text = movies[indexPath.row].title
//            cell.layoutSubviews()
//            return cell
//        }
//        
//        movies.remove(at: indexPath.row)
//        collectionView.reloadData()
//        cell.moviePosterView.image = movies[indexPath.row].posterImage!
//        cell.movieTitleLabel.text = movies[indexPath.row].title
//        cell.layoutSubviews()
//        return cell
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == self.movies.count - 1 {
            pageNumber += 1
            client.get(request: .search(searchTerm: ValidSearch("\(searchTerm)&page=\(pageNumber)")!), handler: { json in
                
                var newMovies = [Movie]()
                newMovies = json!
                self.movies.append(contentsOf: newMovies)
                self.collectionView.reloadData()
            })
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


func filterContentForSearchText(searchText: String, scope: String = "All") {
}

extension ViewController: UITextFieldDelegate {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath as IndexPath) as! MovieCollectionReusableView
        headerView.searchField.delegate = self
        return headerView
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("Did begin editing: \(textField.text)")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print(self.store.searchResults)
        searchTerm = textField.text!
        print(searchTerm)
    }
}
