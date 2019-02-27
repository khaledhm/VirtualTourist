//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Khaled H on 27/02/2019.
//  Copyright © 2019 Khaled H. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    let dataController = DataController(modelName: "VirtualTourist")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        dataController.load()
        let navigationController = window?.rootViewController as! UINavigationController
        let LocationViewController = navigationController.topViewController as! LocationsViewController
        LocationViewController.dataController = dataController
        
        return true
    }
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        saveViewContext()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        saveViewContext()
    }
    
    func saveViewContext(){
        try? dataController.viewContext.save()
    }


}

