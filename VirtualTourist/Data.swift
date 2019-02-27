//
//  Data.swift
//  VirtualTourist
//
//  Created by Khaled H on 27/02/2019.
//  Copyright © 2019 Khaled H. All rights reserved.
//

import CoreData

class DataController{
    
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    init(modelName: String){
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    
    func load(compeletion: (() -> Void)? = nil){
        
        persistentContainer.loadPersistentStores { storedDescription, error in
            guard error == nil else{
                fatalError(error!.localizedDescription)
            }
            
            self.autoSaveViewContext()
            compeletion?()
        }
    }
    
    
}


extension DataController{
    
    func autoSaveViewContext(interval: TimeInterval = 30){
        
        guard interval > 0 else{
            
            print("Interval cannot be negative")
            return
        }
        
        if viewContext.hasChanges{
            try? viewContext.save()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval){
            self.autoSaveViewContext(interval: interval)
        }
    }
    
    
    func fetchPin(_ predicate: NSPredicate) throws -> Pin? {
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.predicate = predicate
        
        guard let pin = (try viewContext.fetch(fetchRequest) ).first else {
            return nil
        }
        return pin
    }
}
