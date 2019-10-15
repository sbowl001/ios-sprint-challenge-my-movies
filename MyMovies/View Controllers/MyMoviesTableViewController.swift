//
//  MyMoviesTableViewController.swift
//  MyMovies
//
//  Created by Spencer Curtis on 8/17/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import CoreData

class MyMoviesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    
    private let movieController = MovieController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

      
    }
    
    @IBAction func refresh(_ sender: Any) {
        movieController.fetchMoviesFromServer { (_) in
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
            }
        }
    }

  lazy var fetchedResultsController: NSFetchedResultsController<Movie> = {
         let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
         fetchRequest.sortDescriptors = [NSSortDescriptor(key: "hasWatched", ascending: true),
                                         NSSortDescriptor(key: "title", ascending: true)]
         let moc = CoreDataStack.shared.mainContext
         let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: "hasWatched", cacheName: nil)
         frc.delegate = self
         try! frc.performFetch() //real app needs do try catch
         return frc
     }()

     override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
 //        self.tableView.reloadData()
     }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

 
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController.sections?[section].name == "0" ? "Unwatched" : "Watched"
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyMovieCell", for: indexPath) as? MyMoviesTableViewCell else {return UITableViewCell()}
        let movie = fetchedResultsController.object(at: indexPath)
        cell.movie = movie
        cell.movieController = movieController
        
        return cell
    }
   

    

   
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let movieDelete = fetchedResultsController.object(at: indexPath)
//            tableView.deleteRows(at: [indexPath], with: .fade)
            movieController.deleteMovie(movie: movieDelete)
        }
    }
   

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

  //MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
 
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }
 
  // Rows
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                  didChange anObject: Any, at indexPath: IndexPath?,
                  for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
      switch type {
      case .insert:
          guard let newIndexPath = newIndexPath else {return}
          tableView.insertRows(at: [newIndexPath], with: .automatic)
      case .update:
          guard let indexPath = indexPath else {return}
          tableView.reloadRows(at: [indexPath], with: .automatic)
      case .move:
          guard let oldIndexPath = indexPath,
              let newIndexPath = newIndexPath else {return}
              tableView.deleteRows(at: [oldIndexPath], with: .automatic)
              tableView.insertRows(at: [newIndexPath], with: .automatic)
      case .delete:
          guard let indexPath = indexPath else {return}
          tableView.deleteRows(at: [indexPath], with: .automatic)
      default:
          break
      }
  }
}
 
