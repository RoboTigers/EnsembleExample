//
//  Value.swift
//  EnsembleExample
//
//  Created by Oskari Rauta on 7.2.2016.
//  Copyright © 2016 Oskari Rauta. All rights reserved.
//

import Foundation
import CoreData


class Value: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    
    class func ValueTypeInManagedObjectContext(_ context: NSManagedObjectContext) -> Value {
        let fetch : NSFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Values")
        var value : Value? = nil
        do {
            try value = context.fetch(fetch).last as? Value
        } catch {
            value = nil
        }
        
        if value == nil {
            value = NSEntityDescription.insertNewObject(forEntityName: "Values", into: context) as? Value
            value!.initial = NSNumber(value: true as Bool)
        }
        
        return value!
    }

}
