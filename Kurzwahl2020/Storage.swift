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


class storage {

    init() {
        
    }
    

    func persist() {
        
        let directory : URL = FileManager.sharedContainerURL()
        let fileURL = directory.appendingPathComponent("testfile")
        do {
            try NSKeyedArchiver.archivedData(withRootObject: appdefaults(), requiringSecureCoding: true).write(to: fileURL)
        } catch {
      
        }
    }

    
    // check this: https://www.hackingwithswift.com/example-code/system/how-to-save-and-load-objects-with-nskeyedarchiver-and-nskeyedunarchiver
//    Use +unarchivedObjectOfClass:fromData:error: instead

    func load() {
        var payload : appdefaults
        
        let directory : URL = FileManager.sharedContainerURL()
        let fileURL = directory.appendingPathComponent("testfile")
        //NSKeyedUnarchiver.unarchivedObject(ofClasses: appdefaults, from: <#T##Data#>)
        
    
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
