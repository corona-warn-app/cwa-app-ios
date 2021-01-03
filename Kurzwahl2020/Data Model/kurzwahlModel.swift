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

//+---------------------------------------------------------+
//|  kurzwahlModel                                          |
//|  var globalDataModel : kurzwahlModel = kurzwahlModel()  |
//+---------------------------------------------------------+
// used by:
// Colors: ColorManagement, HomeView, editView
// Font: AskForAccessToContactsView, AboutView, ColorSelectView, PrivacyView
// Tiles: editView, HomeView
//


import SwiftUI
import Combine

enum tileError : Error {
    case badIndex
}

struct tileGeometryStruct {
    var height: CGFloat;
    var width: CGFloat;
    
    init(height: CGFloat, width: CGFloat) {
        self.height = height
        self.width = width
    }
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
#if CBC36
var globalMaxTileNumber : Int = 35 // 3 * 12 - 1
let globalNoOfScreens : Int = 3
let globalDefaultPalettes = [ c_darkPink, c_summerTime, c_red ]
#elseif CBC24
var globalMaxTileNumber : Int = 23 // 2 * 12 - 1
let globalNoOfScreens : Int = 2
let globalDefaultPalettes = [ c_palette02, c_palette01 ]
#endif
let APPGROUP : String = "group.org.tcfos.callbycolor"

// global constants
struct appdefaults : Hashable {
    struct rows {
        // static let small = 5
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
//    @EnvironmentObject var cm : ColorManagement
    @Published var tiles: [phoneTile] = []
    @Published var font : String = "PingFang TC Medium"
    @Published var fontSize : CGFloat = 0
    @Published var tileGeometry : tileGeometryStruct
    
    private var phoneNumbers : [String] = [""]
    private var colors : [ String ] = [""]
    
    //Dictionary of settings
    var settings : [String : String] = ["fontsize" : "24"]
    let storageManager = storage.init()
    
    
    init() {
        self.tileGeometry = tileGeometryStruct(height: 0.0, width: 0.0)
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
        
//        let colorsFromFile = self.storageManager.loadColors()
//        if colorsFromFile.count > 0 {
//            for i in 0...(colorsFromFile.count - 1 ) {
//                tiles[i].backgroundColor = colorsFromFile[i]
//            }
//        }
        self.settings = self.storageManager.loadSettings()
    }
    
    
//    func setColorsFromSettings() {
//        for i in 0...2 {
//            let name = cm.getScreenPaletteName(withIndex: i)
//            let colors = cm.getColors(forPalette: name)
//            let j = i * 12
//            var k = 0
//            for color in colors {
//                tiles[j+k].backgroundColor = color
//                k = k + 1
//            }
//        }
//    }
    
    
    func getUserSelectedPaletteName(withIndex: Int) -> String {
        var result : String
        switch withIndex {
        case 0:
            result = settings["ColorPalette0"]!
        case 1:
            result = settings["ColorPalette1"]!
        case 2:
            result = settings["ColorPalette2"]!
        default:
            result = ""
        }
        return result
    }
    
    
    
    func updateScreenPalette(withIndex: Int, palette: palette) {
        //var settings : [String : String] = ["fontsize" : "24"]
        
        switch withIndex {
        case 0:
            settings["ColorPalette0"] = palette.name
        case 1:
            settings["ColorPalette1"] = palette.name
        case 2:
            settings["ColorPalette2"] = palette.name
        default:
            print("updateScreenPalette: illegal index: \(withIndex)")
        }
        storageManager.persist(settings: self.settings)
//        self.setColorsFromSettings()
    
    }
       
    
    fileprivate func initializeDefaultTiles() {
        var aTile: phoneTile
        let colorPalette = ColorPaletteSummer + ColorPaletteDarkPink + ColorPaletteRed
        globalMaxTileNumber = colorPalette.count - 1
        for i in 0...globalMaxTileNumber {
            aTile = phoneTile(id: i, name: "", phoneNumber: "", backgroundColor: colorPalette[i])
            tiles.append(aTile)
        }
    }
    
}

