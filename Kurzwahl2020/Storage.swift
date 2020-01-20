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
    fileprivate let numbersFileName = "CBC24numbers"
    fileprivate let namesFileName = "CBC24names"
    fileprivate let settingsFileName = "CBC24settings"
    fileprivate let colorsFileName = "CBC24colors"
    
    init() {
//        self.deleteFilesFromAppgroup()
    }
    

    func persist(withNames : [String], withFilename: String = "" ) {
        let filename : String = (withFilename.count == 0 ? namesFileName : withFilename)
        let directory : URL = FileManager.sharedContainerURL()
        let fullPath = directory.appendingPathComponent(filename)
        do {
            try NSKeyedArchiver.archivedData(withRootObject: withNames, requiringSecureCoding: false).write(to: fullPath)
        } catch {
            print("Store names failes")
        }
    }

    
    func persist(withNumbers : [String], withFilename: String = "" ) {
        
        let filename : String = (withFilename.count == 0 ? numbersFileName : withFilename)
        let directory : URL = FileManager.sharedContainerURL()
        let fullPath = directory.appendingPathComponent(filename)
        do {
            try NSKeyedArchiver.archivedData(withRootObject: withNumbers, requiringSecureCoding: false).write(to: fullPath)
        } catch {
            print("Store numbers failes")
        }
    }

    
    func persist(settings : [String : String], withFilename: String = "" ) {
        
        let filename : String = (withFilename.count == 0 ? settingsFileName : withFilename)
        let directory : URL = FileManager.sharedContainerURL()
        let fullPath = directory.appendingPathComponent(filename)
        do {
            try NSKeyedArchiver.archivedData(withRootObject: settings, requiringSecureCoding: false).write(to: fullPath)
        } catch {
            print("Store settings failed")
        }
    }
    
    
    // check this: https://www.hackingwithswift.com/example-code/system/how-to-save-and-load-objects-with-nskeyedarchiver-and-nskeyedunarchiver
//  Apple:  Use +unarchivedObjectOfClass:fromData:error: instead
    
// https://stackoverflow.com/questions/49526740/nskeyedunarchiver-unarchivetoplevelobjectwithdata-is-obsoleted-in-swift-4
    func loadNames(withFilename : String = "") ->[String] {
        var result : [String]
        var namesFromFile : [String]?
        let defaultNames : [String] = Array(repeating: "", count: globalMaxTileNumber + 1)
        
        let filename : String = (withFilename.count == 0 ? namesFileName : withFilename)
        let directory : URL = FileManager.sharedContainerURL()
        
        let fileURL = directory.appendingPathComponent(filename)
        do {
        let data = try Data(contentsOf: fileURL)
            namesFromFile = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data as Data) as? [String]
            result = namesFromFile ?? defaultNames
        } catch {
            print("load Names failed")
            result = defaultNames
        }
        return result
    }
    

    func loadNumbers(withFilename : String = "") ->[String] {
        var result : [String] = [""]
        let filename : String = (withFilename.count == 0 ? numbersFileName : withFilename)
        let directory : URL = FileManager.sharedContainerURL()
        let fileURL = directory.appendingPathComponent(filename)
        do {
        let data = try Data(contentsOf: fileURL)
            result = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data as Data) as! [String]
        } catch {
            print("load Numbers failed")
        }
        return result
    }
    
    
    func loadColors(withFilename : String = "") ->[String] {
        var result : [String] = [""]
        let filename : String = (withFilename.count == 0 ? colorsFileName : withFilename)
        let directory : URL = FileManager.sharedContainerURL()
        let fileURL = directory.appendingPathComponent(filename)
        do {
        let data = try Data(contentsOf: fileURL)
            result = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data as Data) as! [String]
        } catch {
            print("load Colors failed")
        }
        return result
    }
    
    
    func loadSettings(withFilename : String = "") ->[String : String] {
        var result: [String : String] = ["":""]
        let filename : String = (withFilename.count == 0 ? settingsFileName : withFilename)
        let directory : URL = FileManager.sharedContainerURL()
        let fileURL = directory.appendingPathComponent(filename)
        do {
            let data = try Data(contentsOf: fileURL)
            result = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data as Data) as! [String : String]
            return result
        } catch {
            print("load settings failed")
            result = ["fontsize" : "22"]
        }
        return result
    }
    
    
    func deleteFilesFromAppgroup() {
        let numbersFileName = "CBC24numbers"
        let namesFileName = "CBC24names"
        let settingsFileName = "CBC24settings"
        
        let directory : URL = FileManager.sharedContainerURL()
        let fullPathNames = directory.appendingPathComponent(namesFileName)
        let fullPathNumbers = directory.appendingPathComponent(numbersFileName)
        let fullPathSettings = directory.appendingPathComponent(settingsFileName)
        do {
            try FileManager.default.removeItem(at: fullPathNames)
        } catch let error as NSError {
            print("Error: \(error.domain)")
        }
        do {
            try FileManager.default.removeItem(at: fullPathNumbers)
        } catch let error as NSError {
            print("Error: \(error.domain)")
        }
        do {
            try FileManager.default.removeItem(at: fullPathSettings)
        } catch let error as NSError {
            print("Error: \(error.domain)")
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
