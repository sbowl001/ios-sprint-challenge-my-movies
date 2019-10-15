//
//  MyMoviesTableViewCell.swift
//  MyMovies
//
//  Created by Stephanie Bowles on 10/14/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MyMoviesTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hasWatchedButton: UIButton!
   

    var movieController: MovieController?
    var movie: Movie? {
        didSet {
            print("movie was set")
            updateViews()
        }
    }
    @IBAction func watchedButtonTapped(_ sender: Any) {
        guard let movie = movie else {return}
        movieController?.toggle(movie: movie)
         hasWatchedButton.setTitle(movie.hasWatched ?  "Watched" : "Not Watched", for: .normal)
    }
    
    private func updateViews() {
        //do we put isViewloaded?
        guard let movie = movie else { return}
        titleLabel.text = movie.title
        
        hasWatchedButton.setTitle(movie.hasWatched ?  "Watched" : "Not Watched", for: .normal)
    }
}
