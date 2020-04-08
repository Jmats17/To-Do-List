//
//  DataManager.swift
//  Simple
//
//  Created by Justin Matsnev on 4/8/20.
//  Copyright © 2020 Justin Matsnev. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct DataManager {
    
    static func save(item: String, date: String, completionHandler: @escaping (Bool, NSManagedObject?, Error?) -> Void) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else { completionHandler(false, nil, nil) ; return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "TodoItem", in: managedContext)!
        
        let todoItem = NSManagedObject(entity: entity, insertInto: managedContext)
        
        todoItem.setValue(item, forKeyPath: "todoItem")
        todoItem.setValue(date, forKey: "timeStamp")
        
        do {
            try managedContext.save()
            completionHandler(true, todoItem, nil)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            completionHandler(false, nil, error)
        }
    }
    
    static func loadItems(completionHandler: @escaping (Bool, [NSManagedObject]?, Error?) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else { completionHandler(false, nil, nil) ; return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TodoItem")
        
        do {
            let items = try managedContext.fetch(fetchRequest)
            completionHandler(true, items, nil)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            completionHandler(false, nil, error);
        }
    }
    
    static func deleteItem(item: NSManagedObject, completionHandler: @escaping (Bool) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
            else { completionHandler(false) ; return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.delete(item)
        do {
            try managedContext.save()
            completionHandler(true)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            completionHandler(false);
        }
    }
}
