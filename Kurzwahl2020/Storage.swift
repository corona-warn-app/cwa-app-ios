//
//  Storage.swift
//  Kurzwahl2020
//
//  Created by Vogel, Andreas on 30.10.19.
//  Copyright © 2019 Vogel, Andreas. All rights reserved.
//
// iOS Persistence: https://www.iosapptemplates.com/blog/ios-development/data-persistence-ios-swift
//
// APPGROUP https://www.avanderlee.com/swift/core-data-app-extension-data-sharing/
// https://developer.apple.com/library/archive/documentation/General/Conceptual/ExtensibilityPG/ExtensionScenarios.html
// https://github.com/maximbilan/iOS-Shared-CoreData-Storage-for-App-Groups (Swift 4.2)
// https://dmtopolog.com/ios-app-extensions-data-sharing/
// https://medium.com/swift2go/app-groups-as-an-alternative-to-deep-linking-between-your-apps-a8c214c6582a
// https://blog.zeroseven.de/app-entwicklung/erfolgreiche-veroeffentlichung-einer-ios-app-mit-app-extensions/
// https://agostini.tech/2017/08/13/sharing-data-between-applications-and-extensions-using-app-groups/

import SwiftUI
import Foundation

// can we use simple arrays to store data to file?



class storage {

    init() {
        
    }
    

    func persist() {
        
        let directory : URL = FileManager.sharedContainerURL()
        let fullPath = directory.appendingPathComponent("testfile")
        do {
            try NSKeyedArchiver.archivedData(withRootObject: appdefaults.self, requiringSecureCoding: false).write(to: fullPath)
        } catch {
      
        }
    }

    
    // check this: https://www.hackingwithswift.com/example-code/system/how-to-save-and-load-objects-with-nskeyedarchiver-and-nskeyedunarchiver
//  Apple:  Use +unarchivedObjectOfClass:fromData:error: instead
    
// https://stackoverflow.com/questions/49526740/nskeyedunarchiver-unarchivetoplevelobjectwithdata-is-obsoleted-in-swift-4
    func load() {
        var payload : appdefaults
        
        let directory : URL = FileManager.sharedContainerURL()
        let fileURL = directory.appendingPathComponent("testfile")

        do {
            let data = try Data(contentsOf: fileURL)
            let payload = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data as Data) as? appdefaults
        } catch {
            
        }
    
    }
       
}

// from https://dmtopolog.com/ios-app-extensions-data-sharing/
extension FileManager {
  static func sharedContainerURL() -> URL {
    return FileManager.default.containerURL(
      forSecurityApplicationGroupIdentifier: APPGROUP
    )!
  }
}
