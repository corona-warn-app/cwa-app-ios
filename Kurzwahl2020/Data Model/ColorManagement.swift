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



import SwiftUI
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
    var userScreen = [palette]()  //the three used palettes
    var allColors = [String]()    //array with all color code of the selected 3 palettes
    
    
    init() {
        print("ColorManagemen init")
        allPalettes.append(palette(name: c_summerTime, thumbnail: "Standard Light Mode", thumbnailDarkMode: c_tn_summerTime_dm, colors:ColorPaletteSummer))
        allPalettes.append(palette(name: c_darkPink, thumbnail: "DarkPink Light Mode", thumbnailDarkMode: c_tn_darkPink_dm, colors:ColorPaletteDarkPink))
        allPalettes.append(palette(name: c_red, thumbnail: "Red Light Mode", thumbnailDarkMode: c_tn_red_dm, colors:ColorPaletteRed))
        allPalettes.append(palette(name: c_green, thumbnail: c_tn_green_lm, thumbnailDarkMode: c_tn_green_dm, colors:ColorPaletteGreen))
        allPalettes.append(palette(name: c_blue, thumbnail: c_tn_blue_lm, thumbnailDarkMode: c_tn_blue_dm, colors:ColorPaletteBlue))
        
        for i in 0...2 {
            self.setScreenPalette(withIndex: i, name: globalDataModel.getUserSelectedPalette(withIndex: i))
        }
        setAllColors()
    }
    
    
    func getUIColor(withId: Int) -> UIColor {
        if withId < allColors.count {
            let u : UIColor = UIColor.init(named: allColors[withId])!
            return u
        }
        else {
            return UIColor.init(named: "black")!
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
    
    
    func setAllColors() {
        allColors.removeAll()
        for i in 0...2 {
            let p = getScreenPaletteName(withIndex: i)
            allColors = allColors + getColors(forPalette: p)
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
