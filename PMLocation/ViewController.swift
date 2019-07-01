//
//  ViewController.swift
//  PMLocation
//
//  Created by Mindbowser on 30/06/19.
//  Copyright © 2019 Mindbowser. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

@IBOutlet var locationsTableView: UITableView?
var locationArray = NSMutableArray()
var selectedLocation: [String: Any] = [:]

override func viewDidLoad() {
    super.viewDidLoad()
    NotificationCenter.default.addObserver(self, selector: #selector(fetchLatestLocations), name: NSNotification.Name(rawValue: "locationUpdate"), object: nil)
    self.fetchLatestLocations()
    // Do any additional setup after loading the view, typically from a nib.
}

@objc func fetchLatestLocations() {
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    appdelegate.locationManager.startMonitoringSignificantLocationChanges()
    do {
        try self.fetchedResultsController.performFetch()
    } catch {
        let fetchError = error as NSError
        print("\(fetchError), \(fetchError.userInfo)")
    }
    if let sections = fetchedResultsController.sections {
        let sectionInfo = sections[0]
        print("section:\(sectionInfo.objects)")
        for section in sectionInfo.objects! {
            let latitude = (section as! Locations).latitude
            let longitude = (section as! Locations).longitude
            let date = (section as! Locations).date
            let placeName = (section as! Locations).placeName
            let deviceInfo = (section as! Locations).batteryLevel
            let datevalue = Date(timeIntervalSince1970: date)
            let deviceusedMemory = (section as! Locations).deviceUsedMemory
            let deviceactiveMemory = (section as! Locations).deviceActiveMemory

            let locationObeject = ["latitude": latitude, "longitude": longitude, "date": datevalue, "placeName": placeName, "batteryLevel": deviceInfo, "deviceactiveMemory": deviceactiveMemory, "deviceusedMemory": deviceusedMemory] as [String : Any]
            locationArray.add(locationObeject)
        }
    }
    locationsTableView?.reloadData()
}

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return locationArray.count
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
    let location = locationArray[indexPath.row] as! [String : Any]
    cell.textLabel?.text = (location["placeName"] as! String)
    return cell
}

func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.selectedLocation = locationArray[indexPath.row] as! [String : Any]
    self.performSegue(withIdentifier: "LocationDetailSegue", sender: self)
}

// Mark: FetchresultController to fetch locations data

lazy var fetchedResultsController: NSFetchedResultsController<Location>  = {
    // Initialize Fetch Request
    let fetchRequest = NSFetchRequest<Location>(entityName: "Locations")
    // Add Sort Descriptors
    let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
    fetchRequest.sortDescriptors = [sortDescriptor]
    let context = PMCoreDataManager().managedObjectContext
    let threadContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    threadContext.parent = context
    // Initialize Fetched Results Controller
    let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    return fetchedResultsController
}()

override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "LocationDetailSegue" {
        let locationDetailsController = segue.destination as! LocationDetailController
        locationDetailsController.locationdetail = self.selectedLocation
    }
}
}

