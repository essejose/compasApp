//
//  UIViewController+CoreData.swift
//  jose
//
//  Created by jose on 15/10/17.
//  Copyright © 2017 jose. All rights reserved.
//


import CoreData
import UIKit

extension UIViewController {
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    var context: NSManagedObjectContext {
        return appDelegate.persistentContainer.viewContext
    }
}
