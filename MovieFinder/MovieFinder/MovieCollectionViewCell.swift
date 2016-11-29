//
//  MovieCollectionViewCell.swift
//  MovieFinder
//
//  Created by Christopher Webb-Orenstein on 11/27/16.
//  Copyright © 2016 Christopher Webb-Orenstein. All rights reserved.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var moviePosterView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel! {
        didSet {
            movieTitleLabel.textColor = UIColor.white
            movieTitleLabel.numberOfLines = 2
            movieTitleLabel.lineBreakMode = .byWordWrapping
            movieTitleLabel.textAlignment = .center
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
        setupConstraints()
    }
    
    func setupConstraints() {
        movieTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        movieTitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        movieTitleLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        movieTitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    }
}
