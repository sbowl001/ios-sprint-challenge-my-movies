//
//  MovieController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class MovieController {
    
   //MARK: FIREBASE
    let firebaseURL = URL(string: "https://sprintmovies.firebaseio.com/")!
    typealias CompletionHandler = (Error?) -> Void
    
   init() {
       fetchMoviesFromServer() { _ in
           print("Fetching tasks from the server")
       }
   }
    
    
    func saveToPersistenceStore(){
        do {
        try CoreDataStack.shared.save()
        } catch {
            print("errror Saving to persistence store")
        }
    }
    //MARK: CoreData Handling
    
    func createMovie(title: String){
        let newMovie = Movie(title: title)
        put(movie: newMovie)
        saveToPersistenceStore()
        
    }
    func toggle(movie: Movie) {
        movie.hasWatched.toggle()
        put(movie: movie)
        saveToPersistenceStore()
    }
    
    func deleteMovie(movie: Movie) {
        CoreDataStack.shared.mainContext.delete(movie)
        deleteTaskFromServer(movie, completion: {_ in})
        saveToPersistenceStore()
    }
    
    //MARK: Create
    func put(movie: Movie, completion: @escaping CompletionHandler = {_ in}) {
            let uuid = movie.identifier ?? UUID()
            let requestURL = firebaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
            var request = URLRequest(url: requestURL)
            request.httpMethod = "PUT"
            
            do {
                guard let representation = movie.movieRepresentation else {
                    completion(nil)
                    return
                }
//                representation.identifier = uuid
//                movie.identifier = uuid
     
                saveToPersistenceStore()
                request.httpBody = try JSONEncoder().encode(representation)
            } catch {
                NSLog("Error encoding task \(movie): \(error)")
                completion(nil)
                return
                
            }
            
            URLSession.shared.dataTask(with: request) { (data, _, error) in
                if let error = error {
                    NSLog("Error Putting task to server \(error)")
                    completion(nil)
                    return
                }
                completion(nil)
            }.resume()
        }
        
    
  //MARK: READ
    
    func fetchMoviesFromServer(completion: @escaping CompletionHandler){
        let requestURL = firebaseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) {(data, _ , error) in
            if let error = error {
                NSLog("Error fetching tasks: \(error)")
                completion(error)
                return
            }
            guard let data = data else {
                NSLog("No data returned by data task")
                completion(NSError())
                return
            }
            do {
                let movieRepresentations = Array(try JSONDecoder().decode([String: MovieRepresentation].self, from: data).values) //data on firebase is a dictionary so gotta decode to array.
                
                try self.updateTasks(with: movieRepresentations)
                completion(nil)
            } catch {
                NSLog("error decoding tasks representations: \(error)")
                completion(error)
                return
            }
        }.resume()
    }
    
    //MARK: Update
    private func updateTasks(with representations: [MovieRepresentation]) throws {
            let moviesWithID = representations.filter({ $0.identifier != nil}) //only task objects with identifier
        let identifiersToFetch = moviesWithID.compactMap({$0.identifier!})
            let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, moviesWithID))
            
            var moviesToCreate = representationsByID
            
            let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
            
   
            let context = CoreDataStack.shared.container.newBackgroundContext()
            
            
            context.perform {
                do {
                    //Updating core data tasks with representations from the server
                    let existingMovies = try context.fetch(fetchRequest)
                    for movie in existingMovies {
                        guard let id = movie.identifier,
                            let representation = representationsByID[id] else {continue}
                        self.update(movie: movie, with: representation)
                        moviesToCreate.removeValue(forKey: id)
                    }
                    
                    //creating core data tasks from representations from the server
                    for representation in moviesToCreate.values {
                        Movie(movieRepresentation: representation, context: context)
                    }
                } catch {
                    NSLog("error fetching tasks for UUIDs: \(error)")
                }
            }
         
            try CoreDataStack.shared.save(context: context)
        }
    
  func update(movie: Movie, with representation: MovieRepresentation) {
         movie.title = representation.title
         movie.hasWatched = representation.hasWatched!
         
     }
  //MARK: Delete
    
    func deleteTaskFromServer(_ movie: Movie, completion: @escaping CompletionHandler) {
        guard let uuid = movie.identifier else {
            completion(NSError())
            return
        }
        
        let requestURL = firebaseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            print(response!)
            completion(error)
            } .resume()
    }
   //MARK: Boiler plate moviedb
    
    private let apiKey = "4cc920dab8b729a619647ccc4d191d5e"
    private let baseURL = URL(string: "https://api.themoviedb.org/3/search/movie")!
    
    func searchForMovie(with searchTerm: String, completion: @escaping (Error?) -> Void) {
        
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        
        let queryParameters = ["query": searchTerm,
                               "api_key": apiKey]
        
        components?.queryItems = queryParameters.map({URLQueryItem(name: $0.key, value: $0.value)})
        
        guard let requestURL = components?.url else {
            completion(NSError())
            return
        }
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            
            if let error = error {
                NSLog("Error searching for movie with search term \(searchTerm): \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from data task")
                completion(NSError())
                return
            }
            
            do {
                let movieRepresentations = try JSONDecoder().decode(MovieRepresentations.self, from: data).results
                self.searchedMovies = movieRepresentations
                completion(nil)
            } catch {
                NSLog("Error decoding JSON data: \(error)")
                completion(error)
            }
        }.resume()
    }
    //MARK: end boiler plate movieDB
    
    // MARK: - Properties
    
    var searchedMovies: [MovieRepresentation] = []
}
