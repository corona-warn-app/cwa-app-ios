//
//  KurzwahlView.swift
//  Kurzwahl2020
//
//  Created by Vogel, Andreas on 30.10.19.
//  Copyright © 2019 Vogel, Andreas. All rights reserved.
//
// all colors have to be defiend in the Assets catalog. The names
// of these colors can be found in AssetColorList: [String]
//+---------------------------------------------------------+
//|  kurzwahlModel                                          |
//   var contactDataModel : contactReader = contactReader() |
//+---------------------------------------------------------+

//+--------------------+ +-----------------------------+
//| ColorSelectView    | | SelectColorPalette          |
//+--------------------+ +-----------------------------+
//         |                            |
//         |                            |
//         V                            V
//+----------------------------------------------------+
//|  ColorManagement : ObservableObject                |
//+----------------------------------------------------+
//         | getUserSelectedPalette()
//         | updateScreenPalette()
//         V
//+----------------------------------------------------+
//| globalDataModel : kurzwahlModel                    |
//+----------------------------------------------------+



import Foundation
import Combine


struct palette: Identifiable, Hashable {
    var id = UUID()
    var name: String      // Human readable name
    var thumbnail: String // name of thumbnail image in assets
    var thumbnailDarkMode: String // name of thumbnail image for dark mode
    var colors : [String]
}



class ColorManagement : ObservableObject {
    var allPalettes = [palette]() //array of all available palettes
    var userScreen = [palette]()  // the three used palettes
    
    init() {
        
        print("ColorManagemen init")
        allPalettes.append(palette(name: c_summerTime, thumbnail: "Standard Light Mode", thumbnailDarkMode: "", colors:ColorPaletteSummer))
        allPalettes.append(palette(name: c_darkPink, thumbnail: "DarkPink Light Mode", thumbnailDarkMode: "", colors:ColorPaletteDarkPink))
        allPalettes.append(palette(name: c_red, thumbnail: "Red Light Mode", thumbnailDarkMode: "", colors:ColorPaletteRed))
        
        // read from file
        for i in 0...2 {
            self.setScreenPalette(withIndex: i, name: globalDataModel.getUserSelectedPalette(withIndex: i))
        }
    }
    
    
    func getThumbnailName(withIndex: Int) -> String {
        return userScreen[withIndex].thumbnail
    }
    
    func getAllThumbnails() -> [palette] {
        return allPalettes
    }
    
    
    func getScreenPaletteName(withIndex: Int) -> String {
        return userScreen[withIndex].name
    }
    
    func setScreenPalette(withIndex: Int, name: String) {
        for p in allPalettes {
            if p.name == name {
                userScreen.insert(p, at: withIndex)
                //update settings
                globalDataModel.updateScreenPalette(withIndex: withIndex, palette: p)
            }
        }
    }
    
    func getColors(forPalette: String) -> [String] {
        var result = [String]()
        for p in allPalettes {
            if p.name == forPalette {
                result = p.colors
            }
        }
        return result
    }
    
    func getAllPalettes() -> [palette]{
        return allPalettes
    }
    
    func getPalette(withName: String) -> palette{
        var result = palette(name: "", thumbnail: "", thumbnailDarkMode: "", colors: [""])
        for p in allPalettes {
            if p.name == withName {
                result = p
            }
        }
        return result
    }
    
} //class





// for a given number return the corresponding color
//extension Color {
//    static func appColor(_ id: Int) -> Color? {
//        var name: String
//        if id < globalMaxTileNumber {
//            name = AssetColorList[id]
//        }
//        else {
//            name = "Black"
//        }
//        return Color.init(name, bundle: nil)
//    }
//}

