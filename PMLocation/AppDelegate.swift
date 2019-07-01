//
//  AppDelegate.swift
//  PMLocation
//
//  Created by Mindbowser on 30/06/19.
//  Copyright © 2019 Mindbowser. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

var window: UIWindow?
let locationManager = CLLocationManager()
var backgroundUpdateTask: UIBackgroundTaskIdentifier!
var backgroundTaskTimer:Timer?
var foregroundTaskTimer:Timer?
var isFromlaunch = false

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    // Override point for customization after application launch.
    locationManager.requestAlwaysAuthorization()
    locationManager.startMonitoringSignificantLocationChanges()
    locationManager.allowsBackgroundLocationUpdates = true
    locationManager.delegate = self
    isFromlaunch = true
    return true
}

func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    // Mark: Invalidate foreground task timer when app is in background and call setupBackground task
    if self.foregroundTaskTimer != nil {
        self.foregroundTaskTimer?.invalidate()
        self.foregroundTaskTimer = nil
    }
    isFromlaunch = false
    self.doBackgroundTask()

}



func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.

    // Mark: Invalidate background task timer when app is in foreground and start new timer in foreground.

    if self.backgroundTaskTimer != nil {
        self.backgroundTaskTimer?.invalidate()
        self.backgroundTaskTimer = nil
    }

    self.foregroundTaskTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.startTrackingLocation), userInfo: nil, repeats: true)
    RunLoop.current.add(self.foregroundTaskTimer!, forMode: .default)
    RunLoop.current.run()
}

func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    self.saveContext()
}

lazy var persistentContainer: NSPersistentContainer = {
    /*
     The persistent container for the application. This implementation
     creates and returns a container, having loaded the store for the
     application to it. This property is optional since there are legitimate
     error conditions that could cause the creation of the store to fail.
     */
    let container = NSPersistentContainer(name: "PMLocation")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
        if let error = error as NSError? {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            /*
             Typical reasons for an error here include:
             * The parent directory does not exist, cannot be created, or disallows writing.
             * The persistent store is not accessible, due to permissions or data protection when the device is locked.
             * The device is out of space.
             * The store could not be migrated to the current model version.
             Check the error message to determine what the actual problem was.
             */
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    })
    return container
}()

// MARK: - Core Data Saving support

func saveContext () {
    let context = persistentContainer.viewContext
    if context.hasChanges {
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}


func doBackgroundTask() {
    DispatchQueue.global(qos: .default).async {
        self.beginBackgroundTask()
        if self.backgroundTaskTimer != nil {
            self.backgroundTaskTimer?.invalidate()
            self.backgroundTaskTimer = nil
        }
        //Making the app to run in background forever by calling the API
        self.backgroundTaskTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.startTrackingLocation), userInfo: nil, repeats: true)
        RunLoop.current.add(self.backgroundTaskTimer!, forMode: .default)
        RunLoop.current.run()
        // End the background task.
        self.endBackgroundTask()
    }
}

@objc func startTrackingLocation() {
    locationManager.stopMonitoringSignificantLocationChanges()
    locationManager.startMonitoringSignificantLocationChanges()
}
// Mark: setup background task for location update

func beginBackgroundTask() {
    self.backgroundUpdateTask = UIApplication.shared.beginBackgroundTask(withName: "Track location", expirationHandler: {
        self.endBackgroundTask()
    })
}

// Mark: end background task

func endBackgroundTask() {
    UIApplication.shared.endBackgroundTask(self.backgroundUpdateTask)
    self.backgroundUpdateTask = UIBackgroundTaskIdentifier.invalid
    locationManager.stopMonitoringSignificantLocationChanges()
}
}

// Mark: Location Manager Extension

extension AppDelegate: CLLocationManagerDelegate {
func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.first else {
        return
    }
    let lastLocationUpdate = UserDefaults.standard.value(forKey: "lastLocationUpdateDate")
    print("lastTime:\(lastLocationUpdate)")
    if lastLocationUpdate == nil {
        self.inserlocationAndDeviceDetailsInDataBase(location: location)
    } else {
        let timeinterval = Date().timeIntervalSince(lastLocationUpdate as! Date)
        if Int(timeinterval) % 60 == 0 {
            self.inserlocationAndDeviceDetailsInDataBase(location: location)
        }
    }
}

// Mark: Insert location and deviceInfo Date in Database
func inserlocationAndDeviceDetailsInDataBase(location: CLLocation) {
    UserDefaults.standard.set(Date(), forKey: "lastLocationUpdateDate")
    UserDefaults.standard.synchronize()
    // print("location:\(location)")
    // save location and device info details here
    UIDevice.current.isBatteryMonitoringEnabled = true
    let batteryLevel = UIDevice.current.batteryLevel
    //  print("batteryLevel:\(batteryLevel)")
    let geoCoder = CLGeocoder()
    geoCoder.reverseGeocodeLocation(location) { placemarks, _ in
        if let place = placemarks?.first {
            let description = "place visit: \(place)"
            print("place: \(description)")
            Location.addLocation(String(location.coordinate.latitude), longitude: String(location.coordinate.longitude), batteryStatus: batteryLevel, placeName: "\(place)", deviceActiveMemory: Int(SSMemoryInfo.activeMemory(true)), deviceUsedMemory: Int(SSMemoryInfo.usedMemory(true)))
        } else {
            Location.addLocation(String(location.coordinate.latitude), longitude: String(location.coordinate.longitude), batteryStatus: batteryLevel, placeName: "Unknown Location", deviceActiveMemory: Int(SSMemoryInfo.activeMemory(true)), deviceUsedMemory: Int(SSMemoryInfo.usedMemory(true)))
        }
    }
    if isFromlaunch == true {
        isFromlaunch = false
        perform(#selector(reloadLocationsDatailsView), with: nil, afterDelay: 1)
    }
}

   @objc func reloadLocationsDatailsView() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "locationUpdate"), object: nil)

    }

}
