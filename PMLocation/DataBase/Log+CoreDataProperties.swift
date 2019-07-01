//
//  Log+CoreDataProperties.swift
//  
//
//  Created by Mindbowser on 09/09/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Location {

@NSManaged var message: String?
@NSManaged var timestamp: NSNumber?
@NSManaged var createdBy: String?
@NSManaged var latitude: String?
@NSManaged var longitude: String?
@NSManaged var batteryStatus: String?

}
