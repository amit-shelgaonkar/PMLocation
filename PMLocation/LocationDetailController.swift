//
//  LocationDetailController.swift
//  PMLocation
//
//  Created by Mindbowser on 01/07/19.
//  Copyright © 2019 Mindbowser. All rights reserved.
//

import UIKit

class LocationDetailController: UIViewController {

var locationdetail: [String: Any]!
@IBOutlet var locationLatitude: UILabel?
@IBOutlet var locationLongitude: UILabel?
@IBOutlet var batteryLevel: UILabel?
@IBOutlet var dateOfVisit: UILabel?
@IBOutlet var totalDeviceMemory: UILabel?
@IBOutlet var deviceActiveMemory: UILabel?
@IBOutlet var deviceUsedMemory: UILabel?


override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    self.setLocationAndDeviceInfo()
}

// Mark: setup Location and device info labels

func setLocationAndDeviceInfo() {
    self.title = String(describing: (locationdetail["placeName"] as! String))
    
    locationLatitude?.text = "Location Latitude: \(String(describing: (locationdetail["latitude"] as! String))) ?? \("N/A")"
    locationLongitude?.text = "Location Longitude: \(String(describing: (locationdetail["longitude"] as! String))) ?? \("N/A")"
    let batteryLevel = Int((locationdetail["batteryLevel"] as! Float) * 100) ?? 0 * 100
    self.batteryLevel?.text = "Device Battery Level: \(batteryLevel) %"
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYY/MM/dd HH:mm:ss"
    if (locationdetail?["date"]) != nil {
        let visitDate = dateFormatter.string(from: locationdetail?["date"] as! Date)
        dateOfVisit?.text = "LocationVisit Date: \(visitDate)"
    } else {
        dateOfVisit?.text = "LocationVisit Date: N/A"
    }
    self.totalDeviceMemory?.text = "Device Total Memory: \(SSMemoryInfo.totalMemory())"
    self.deviceActiveMemory?.text = "Device Active Memory: \(locationdetail["deviceactiveMemory"]!) %"
    self.deviceUsedMemory?.text = "Device Used Memory: \(locationdetail["deviceusedMemory"]!) %"
}

/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */

}
