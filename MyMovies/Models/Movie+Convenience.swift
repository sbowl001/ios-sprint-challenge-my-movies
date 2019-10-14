//
//  Movie+Convenience.swift
//  MyMovies
//
//  Created by Stephanie Bowles on 10/14/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreData


extension Movie {
    convenience init(title: String, hasWatched: Bool = false, identifier: UUID? = UUID(), context: NSManagedObjectContext = CoreDataStack.shared.mainContext ) {
        self.init(context: context)
        self.title = title
        self.hasWatched = hasWatched
        self.identifier = identifier
    }
    
    //create Movie from a Movie Representation
    
    @discardableResult convenience init? (movieRepresentation: MovieRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let identifier = movieRepresentation.identifier,
            let hasWatched = movieRepresentation.hasWatched else {return nil}
        
        self.init(title: movieRepresentation.title,
                  hasWatched:  hasWatched,
                  identifier: identifier)
    }
    
    var movieRepresentation: MovieRepresentation? {
        guard let title = title
                 else {return nil}
               
        return MovieRepresentation(title: title, identifier: identifier, hasWatched: hasWatched)
           }
   
}
