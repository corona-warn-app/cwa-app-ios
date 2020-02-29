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
//
// https://swiftwithmajid.com/2019/06/19/building-forms-with-swiftui/
//var sleepGoal: Int {
//       set { defaults.set(newValue, forKey: Keys.sleepGoal) }
//       get { defaults.integer(forKey: Keys.sleepGoal) }
//   }

// User changes fontsize on settings screen. How can we update and
// persist the settings dictionary?




import SwiftUI
import Combine

enum tileError : Error {
    case badIndex
}

struct phoneTile {
    var id: Int
    var name: String
    var phoneNumber: String
    var backgroundColor: String
}


var globalNumberOfRows: Int = appdefaults.rows.large
var globalDataModel : kurzwahlModel = kurzwahlModel()
var contactDataModel : contactReader = contactReader()
let globalMaxTileNumber : Int = 35
let APPGROUP : String = "group.org.tcfos.callbycolor"

// global constants
struct appdefaults : Hashable {
    struct rows {
        static let small = 5
        static let large = 6
    }
    struct colorScheme{
        struct dark{
            static let opacity : Double = 0.85
            static let cornerRadius : CGFloat = 4
            static let hspacing : CGFloat = 4
            static let vspacing : CGFloat = 2
        }
        struct light{
            static let opacity : Double = 1.0
            static let cornerRadius : CGFloat = 2
            static let hspacing : CGFloat = 3
            static let vspacing : CGFloat = 1
        }
    }
    struct tilesize {
        static let aspectRatioStandard : CGFloat = 1.61
        static let aspectRatioIPhoneSE : CGFloat = 1.98
    }
    static let thumbnailSize : CGFloat = 40
}


class kurzwahlModel: ObservableObject{
    
    var didChange = PassthroughSubject<Void, Never>()
    
    @Published var tiles: [phoneTile] = []
    @Published var font : String = "PingFang TC Medium"
    @Published var fontSize : CGFloat = 0
    
    private var phoneNumbers : [String] = [""]
    private var colors : [ String ] = [""]
    
    //Dictionary of settings
    var settings : [String : String] = ["fontsize" : "24"]
    let storageManager = storage.init()
    
    
    init() {
        initializeDefaultTiles()
        self.load()
        fontSize = CGFloat(((settings["fontsize"] ?? "18") as NSString).doubleValue)
    }
    
    
    func getTile(withId: Int) throws ->phoneTile  {
        if withId < tiles.count {
            return tiles[withId]
        }
        else {
            throw tileError.badIndex
        }
    }
    
    
    func modifyTile(withTile: phoneTile)   {
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
    
    
    func getNumber(withId: Int) -> String {
        if withId < tiles.count {
            return tiles[withId].phoneNumber
        }
        else {
            return ""
        }
    }
    
    
    func getColorName(withId: Int) -> String {
        if withId < tiles.count {
            return tiles[withId].backgroundColor
        }
        else {
            return ""
        }
    }
    
    
    func getColor(withId: Int) -> Color {
        if withId < tiles.count {
            return Color.init(tiles[withId].backgroundColor, bundle: nil)
        }
        else {
            return Color.black
        }
    }
    
    
    func getUIColor(withId: Int) -> UIColor {
        if withId < tiles.count {
            //let c = Color.init(tiles[withId].backgroundColor, bundle: nil)
            let u : UIColor = UIColor.init(named: tiles[withId].backgroundColor)!
            return u
        }
        else {
            return UIColor.init(named: "black")!
        }
    }
    
    
    func getFontSizeAsInt() -> Int {
        return Int(fontSize)
    }
    
    
    func persist() {
        var displayNames = [String]()
        for i in 0...globalMaxTileNumber {
            displayNames.append(self.tiles[i].name)
        }
        self.storageManager.persist(withNames: displayNames)
        
        var displayNumbers = [String]()
        for i in 0...globalMaxTileNumber {
            displayNumbers.append(self.tiles[i].phoneNumber)
        }
        self.storageManager.persist(withNumbers: displayNumbers)
        
        
        var displayColors = [String]()
        for i in 0...globalMaxTileNumber {
            displayColors.append(self.tiles[i].backgroundColor)
        }
        self.storageManager.persist(withColors: displayColors)
        
        self.storageManager.persist(settings: settings)
    }
    
    
    func persistSettings() {
        if settings["fontsize"] != String(Int(fontSize)) {
            settings["fontsize"] = String(Int(fontSize))
            self.storageManager.persist(settings: settings)
        }
    }
    
    
    func load() {
        var namesFromFile : [String]
        namesFromFile = self.storageManager.loadNames()
        if namesFromFile.count > 0 {
            for i in 0...(namesFromFile.count - 1) {
                tiles[i].name = namesFromFile[i]
            }
        } else {
            for i in 0...globalMaxTileNumber {
                tiles[i].name = ""
            }
        }
        
        let numbersFromFile = self.storageManager.loadNumbers()
        if numbersFromFile.count > 0 {
            for i in 0...(numbersFromFile.count - 1) {
                tiles[i].phoneNumber = numbersFromFile[i]
            }
        }
        
        let colorsFromFile = self.storageManager.loadColors()
        if colorsFromFile.count > 0 {
            for i in 0...(colorsFromFile.count - 1 ) {
                tiles[i].backgroundColor = colorsFromFile[i]
            }
        }
        self.settings = self.storageManager.loadSettings()
    }
    
    
    fileprivate func initializeDefaultTiles() {
        var aTile: phoneTile
        let colorPalette = ColorPaletteSummer + ColorPaletteDarkPink + ColorPaletteBlue
        for i in 0...globalMaxTileNumber {
            aTile = phoneTile(id: i, name: "", phoneNumber: "", backgroundColor: colorPalette[i])
            tiles.append(aTile)
        }
    }
    
}

