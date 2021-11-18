//
//  CoreDataDBStore.swift
//
//  Created by Abhishek Darak
//

import Foundation
import CoreData
import UIKit

public class CoreDataDBStore {
    
    var myVenues: [NSManagedObject] = []
    
    public func saveVenue (myData: [String:String]) {
        
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
          return
        }
        
        // 1
        let managedContext =
          appDelegate.persistentContainer.viewContext
        
        // 2
        let entity =
          NSEntityDescription.entity(forEntityName: "MyCoreDataVenue",
                                     in: managedContext)!
        
        let venue = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
                        
            // 3
            venue.setValue(myData["venue_id"], forKeyPath: "id")
            venue.setValue(myData["venue_id"], forKeyPath: "venue_id")
            venue.setValue(myData["venue_name"], forKeyPath: "venue_name")
            
            // 4
            do {
              try managedContext.save()
              myVenues.append(venue)
            } catch let error as NSError {
              print("Could not save. \(error), \(error.userInfo)")
            }
            
        
    }
    
    public func getVenues() -> [NSManagedObject] {
        
        //1
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
            return [NSManagedObject.init()]
        }
        
        let managedContext =
          appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
          NSFetchRequest<NSManagedObject>(entityName: "MyCoreDataVenue")
        
        //3
        do {
          myVenues = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return myVenues
        
    }

    
}
