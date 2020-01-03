//
//  ModelNumbers.swift
//  Kurzwahl2020
//
//  Created by Vogel, Andreas on 29.12.19.
//  Copyright © 2019 Vogel, Andreas. All rights reserved.
//
// the data model consists of:
//      names
//      phone numbers
//
// The class kurzwahlModel manages arrays for names & phone numbers.
// The contents of these arrays shall be stored in a shared container.
//
// NSUserDefaults shall be used for storing:
//      fontsize
//      font name
//      ...
// Read about NSUserDefaults
//https://www.codingexplorer.com/nsuserdefaults-a-swift-introduction/


import Foundation
import SwiftUI
import Combine

enum tileError : Error {
    case badIndex
}

struct tile {
  var id: Int
  var name: String
  var phoneNumber: String
}
    
    
var globalNumberOfRows: Int = appdefaults.rows.large
var globalDataModel : kurzwahlModel = kurzwahlModel()
var APPGROUP : String = "group.org.tcfos.callbycolor"

// global constants
struct appdefaults : Hashable {
    struct rows {
    static let small = 5
    static let large = 6
    }
    //static let font : String = "PingFang TC Medium"
    struct colorScheme{
        struct dark{
            static let opacity : Double = 0.8
            static let cornerRadius : CGFloat = 5
            static let hspacing : CGFloat = 3
            static let vspacing : CGFloat = 1
        }
        struct light{
            static let opacity : Double = 1.0
            static let cornerRadius : CGFloat = 0
            static let hspacing : CGFloat = 3
            static let vspacing : CGFloat = 1
        }
    }
}


class kurzwahlModel: ObservableObject{
    
    var didChange = PassthroughSubject<Void, Never>()
    
    @Published var tiles: [tile] = []
    @Published var fontSize : CGFloat = 24
    @Published var font : String = "PingFang TC Medium"
    
    private var names : [String] =
        ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrott",
         "Golf", "Hotel", "India", "Juliet", "Kilo", "Lima",
         "Mike", "November", "Oscar", "Papa", "Quebec", "Romeo",
         "Sierra", "Tango", "Uniform", "Victor", "Whiskey", "X-ray",
         "Yankee", "Zulu"]
    private var phoneNumbers : [ String ] = [""]
    private var colors : [ String ] = [""]
    
    //Dictionary of settings
    var settings : [String : String] = ["fontsize" : "24"]
   
    init() {
        var x: tile
        for i in 0...23 {
            x = tile(id: i, name: names[i], phoneNumber: "062111223344")
            tiles.append(x)
        }
        self.load()
        fontSize = CGFloat(((settings["fontsize"] ?? "18") as NSString).doubleValue)
    }
    
    
    func getTile(withId: Int) throws ->tile  {
        if withId < tiles.count {
            return tiles[withId]
        }
        else {
            throw tileError.badIndex
        }
    }
    
   
    func modifyTile(withTile: tile)   {
        if withTile.id >= 0 && withTile.id < tiles.count{
            tiles[withTile.id] = withTile
            didChange.send()
        }
    }
    

    func getName(withId: Int) -> String {
        if withId < tiles.count {
            return tiles[withId].name
        }
        else {
            return ""
        }
    }
    
    
    func getFontSizeAsInt() -> Int {
        return Int(fontSize)
    }
    

    func persist() {
        let storageManager = storage.init()
        storageManager.persist(withNames: names)
        storageManager.persist(withNumbers: phoneNumbers)
        storageManager.persist(settings: settings)
        
    }
    
    
    func load() {
        let storageManager = storage.init()
        
        do {
            self.names = try storageManager.loadNames()
            self.phoneNumbers = try storageManager.loadNumbers()
            settings = try storageManager.loadSettings()
        } catch {
            
        }
    }

}

