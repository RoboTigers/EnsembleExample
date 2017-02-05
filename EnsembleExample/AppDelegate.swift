//
//  AppDelegate.swift
//  EnsembleExample
//
//  Created by Oskari Rauta on 7.2.2016.
//  Copyright © 2016 Oskari Rauta. All rights reserved.
//

import UIKit
import CoreData
import Ensembles

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let _ : CoreDataStack = CoreDataStack.defaultStack
        
//        Value.ValueTypeInManagedObjectContext(CoreDataStack.defaultStack.managedObjectContext)
        CoreDataStack.defaultStack.saveContext()
        
        CoreDataStack.defaultStack.enableEnsemble()

        // Listen for local saves, and trigger merges
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.localSaveOccured(_:)), name: NSNotification.Name.CDEMonitoredManagedObjectContextDidSave, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.cloudDataDidDownload(_:)), name:NSNotification.Name.CDEICloudFileSystemDidDownloadFiles, object:nil)
        
        CoreDataStack.defaultStack.syncWithCompletion(nil);
        
        // Override point for customization after application launch.
        
        NSLog("App started")
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

        let identifier : UIBackgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        CoreDataStack.defaultStack.saveContext()
        CoreDataStack.defaultStack.syncWithCompletion( { () -> Void in
            UIApplication.shared.endBackgroundTask(identifier)
        })
        
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        NSLog("Received a remove notification")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        CoreDataStack.defaultStack.syncWithCompletion(nil)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        CoreDataStack.defaultStack.syncWithCompletion(nil)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        CoreDataStack.defaultStack.saveContext()
    }

    func localSaveOccured(_ notif: Notification) {
        NSLog("Local save occured")
        CoreDataStack.defaultStack.syncWithCompletion(nil)
    }
    
    func cloudDataDidDownload(_ notif: Notification) {
        NSLog("Cloud data did download")
        CoreDataStack.defaultStack.syncWithCompletion(nil)
    }    
    
}

