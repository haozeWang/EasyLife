//
//  DataController.swift
//  EasyLife
//
//  Created by 王昊泽 on 17/3/11.
//  Copyright © 2017年 Haoze Wang. All rights reserved.
//

import UIKit
import CoreData
class DataController: NSObject {
    
var managedObjectContext: NSManagedObjectContext
    

override init() {
    // This resource is the same name as your xcdatamodeld contained in your project.
    guard let modelURL = Bundle.main.url(forResource: "DataModel", withExtension:"momd") else {
        fatalError("Error loading model from bundle")
    }
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
        fatalError("Error initializing mom from: \(modelURL)")
    }
    let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
    self.managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    self.managedObjectContext.persistentStoreCoordinator = psc
    
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let docURL = urls[urls.endIndex-1]
    /* The directory the application uses to store the Core Data store file.
     This code uses a file named "DataModel.sqlite" in the application's documents directory.
     */
    let storeURL = docURL.appendingPathComponent("DateModel.sqlite")
    do {
        try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
    } catch {
        fatalError("Error migrating store: \(error)")
    }
    
     }
  }
