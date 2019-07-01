//
//  Location+CoreDataProperties.swift
//  PMLocation
//
//  Created by Mindbowser on 30/06/19.
//  Copyright © 2019 Mindbowser. All rights reserved.
//

import Foundation
import CoreData

extension Location {

    @NSManaged var date: NSNumber?
    @NSManaged var batteryLevel: NSNumber?
    @NSManaged var latitude: String?
    @NSManaged var longitude: String?
    @NSManaged var placeName: String?
    @NSManaged var deviceUsedMemory: NSNumber?
    @NSManaged var deviceActiveMemory: NSNumber?


}
