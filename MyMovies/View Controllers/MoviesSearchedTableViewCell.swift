//
//  MoviesSearchedTableViewCell.swift
//  MyMovies
//
//  Created by Stephanie Bowles on 10/14/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class MoviesSearchedTableViewCell: UITableViewCell {

    
    var movieController: MovieController?
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
     @IBAction func addMovieTapped(_ sender: Any) {
            guard let movieTitle = titleLabel.text else {return }
        print("button tapped")
            movieController?.createMovie(title: movieTitle)
        }

}
