//
//  Location.swift
//  PMLocation
//
//  Created by Mindbowser on 30/06/19.
//  Copyright © 2019 Mindbowser. All rights reserved.
//

import UIKit
import CoreData
class Location: NSManagedObject {
    class func addLocation(_ latitude: String, longitude: String, batteryStatus: Float, placeName: String, deviceActiveMemory: Int, deviceUsedMemory: Int) {

        let priority = DispatchQueue.GlobalQueuePriority.background
        DispatchQueue.global(priority: priority).async {
            let context = PMCoreDataManager().managedObjectContext

            let threadContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)

            threadContext.parent = context

            threadContext.perform({
                let entityDescription = NSEntityDescription.entity(forEntityName: "Locations", in: threadContext)
                let newLog = NSManagedObject(entity: entityDescription!, insertInto: threadContext)
                newLog.setValue(batteryStatus, forKey: "batteryLevel")
                newLog.setValue(latitude, forKey: "latitude")
                newLog.setValue(longitude, forKey: "longitude")
                newLog.setValue(placeName, forKey: "placeName")
                newLog.setValue(Date().timeIntervalSince1970, forKey: "date")
                newLog.setValue(deviceUsedMemory, forKey: "deviceUsedMemory")
                newLog.setValue(deviceActiveMemory, forKey: "deviceActiveMemory")

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
