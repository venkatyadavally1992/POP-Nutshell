//
//  FavoritesManager.swift
//  POP Nutshell
//
//  Created by Patrick Bellot & Thomas Hanning http://www.twitter.com/@hanning_thomas on 6/17/16.
//  Copyright © 2016 Bell OS, LLC. All rights reserved.
//

import Foundation
import CoreData

class FavoritesManager: NSObject {
    
    var coreDataStack: CoreDataStack!
    var managedContext: NSManagedObjectContext!
    
    class var sharedInstance: FavoritesManager {
        struct Static {
            static let instance: FavoritesManager = FavoritesManager()
        }
        return Static.instance
    }
    
    //MARK: - Insert
    func insertEntityForName(entityName: String) -> AnyObject {
        return NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: self.managedContext)
    }
    
    //MARK: - Fetch
    func fetchEntitiesForName(entityName: String) -> NSArray{
        
    }
    
    //MARK: - Delete
    func deleteObject(object:NSManagedObject) {
        self.managedContext.deleteObject(object)
    }
        
}// End of Class