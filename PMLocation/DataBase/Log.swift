//
//  Log.swift
//  
//
//  Created by Mindbowser on 02/09/16.
//
//

import Foundation
import CoreData

@objc(Location)
class Location: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
class func addLocation(_ message: String) {
    
    let priority = DispatchQueue.GlobalQueuePriority.background
    DispatchQueue.global(priority: priority).async {
        print(message)
        let context = PMCoreDataManager().managedObjectContext
        
        let threadContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        threadContext.parent = context
        
        threadContext.perform({
            let entityDescription = NSEntityDescription.entity(forEntityName: "Locations", in: threadContext)
            let newLog = NSManagedObject(entity: entityDescription!, insertInto: threadContext)
            newLog.setValue(message, forKey: "message")
            newLog.setValue(Date().timeIntervalSince1970, forKey: "timestamp")
            
            do {
                try threadContext.save()
                context.perform {
                    do {
                        try context.save()
                    } catch {
                        fatalError("Failure to save context: \(error)")
                    }
                }
                
            } catch {
                print("database error:\(error)")
            }
        })
        
        
    }
}
}
