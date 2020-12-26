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
    var userSelectedPalettes = [palette]()  //the three used palettes
    var allColors = [String]()    //array with all color code of the selected 3 palettes

    // MARK: - Init
    
    init() {
        print("ColorManagemen init")
        #if CBC24
        paletteInitCBC24()
        #elseif CBC36
        paletteInitCBC36()
        #endif        
        for i in 0...(globalNoOfScreens - 1) {
            self.setScreenPalette(withIndex: i, name: globalDataModel.getUserSelectedPaletteName(withIndex: i))
        }
        setAllColors()
    }
    
    // MARK: - Public
    
    func getUIColor(withId: Int) -> UIColor {
        if withId < allColors.count {
            guard let color = UIColor.init(named: allColors[withId]) else {
                return UIColor.init(named: "Black")!
            }
            return color
        }
        else {
            return UIColor.init(named: "Black")!
        }
    }
    
    func getThumbnailName(withIndex: Int) -> String {
        return userSelectedPalettes[withIndex].thumbnail
    }
    
    func getAllPalettes() -> [palette] {
        return allPalettes
    }
    
    func getScreenPaletteName(withIndex: Int) -> String {
        if userSelectedPalettes.count < withIndex + 1 {
            return globalDefaultPalettes[withIndex]
        }
        return userSelectedPalettes[withIndex].name
    }
    
    // in case an invalid palette name has been read from the settings file then
    // we have to make sure to set a valid palette name
    func setScreenPalette(withIndex: Int, name: String) {
        var paletteFound = false
        for p in allPalettes {
            if p.name == name {
                paletteFound = true
                userSelectedPalettes.insert(p, at: withIndex)
                //update settings
                globalDataModel.updateScreenPalette(withIndex: withIndex, palette: p)
            }
        }
        if paletteFound == false {
            let paletteName = globalDefaultPalettes[withIndex]
            for p in allPalettes {
                if p.name == paletteName {
                    paletteFound = true
                    userSelectedPalettes.insert(p, at: withIndex)
                    //update settings
                    globalDataModel.updateScreenPalette(withIndex: withIndex, palette: p)
                }
            }
        }
    }
    
    func modifyScreenPalette(withIndex: Int, name: String) {
        for p in allPalettes {
            if p.name == name {
                userSelectedPalettes.remove(at: withIndex)
                userSelectedPalettes.insert(p, at: withIndex)
                //update settings
                globalDataModel.updateScreenPalette(withIndex: withIndex, palette: p)
            }
        }
    }
    
    func setAllColors() {
        allColors.removeAll()
        for i in 0...(globalNoOfScreens - 1) {
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
    
    func getPalette(withName: String) -> palette{
        var result = palette(name: "", thumbnail: "", thumbnailDarkMode: "", colors: [""])
        for p in allPalettes {
            if p.name == withName {
                result = p
            }
        }
        return result
    }
    
    // MARK: - Private
    
    private func paletteInitCBC36() {
        allPalettes.append(palette(name: c_summerTime, thumbnail: c_tn_summerTime_lm, thumbnailDarkMode: c_tn_summerTime_dm, colors:ColorPaletteSummer))
        allPalettes.append(palette(name: c_darkPink, thumbnail: c_tn_darkPink_lm, thumbnailDarkMode: c_tn_darkPink_dm, colors:ColorPaletteDarkPink))
        allPalettes.append(palette(name: c_red, thumbnail: c_tn_red_lm, thumbnailDarkMode: c_tn_red_dm, colors:ColorPaletteRed))
        allPalettes.append(palette(name: c_green, thumbnail: c_tn_green_lm, thumbnailDarkMode: c_tn_green_dm, colors:ColorPaletteGreen))
        allPalettes.append(palette(name: c_blue, thumbnail: c_tn_blue_lm, thumbnailDarkMode: c_tn_blue_dm, colors:ColorPaletteBlue))
        allPalettes.append(palette(name: c_gray, thumbnail: c_tn_gray_lm, thumbnailDarkMode: c_tn_gray_dm, colors:ColorPaletteGray))
        allPalettes.append(palette(name: c_palette01, thumbnail: c_tn_P01_lm, thumbnailDarkMode: c_tn_P01_dm, colors:ColorPalette01))
        allPalettes.append(palette(name: c_palette02, thumbnail: c_tn_P02_lm, thumbnailDarkMode: c_tn_P02_dm, colors:ColorPalette02))
        allPalettes.append(palette(name: c_palette03, thumbnail: c_tn_P03_lm, thumbnailDarkMode: c_tn_P03_dm, colors:ColorPalette03))
    }
    
    private func paletteInitCBC24() {
        allPalettes.append(palette(name: c_palette01, thumbnail: c_tn_P01_lm, thumbnailDarkMode: c_tn_P01_dm, colors:ColorPalette01))
        allPalettes.append(palette(name: c_palette02, thumbnail: c_tn_P02_lm, thumbnailDarkMode: c_tn_P02_dm, colors:ColorPalette02))
        allPalettes.append(palette(name: c_red, thumbnail: c_tn_red_lm, thumbnailDarkMode: c_tn_red_dm, colors:ColorPaletteRed))
        allPalettes.append(palette(name: c_green, thumbnail: c_tn_green_lm, thumbnailDarkMode: c_tn_green_dm, colors:ColorPaletteGreen))
        allPalettes.append(palette(name: c_blue, thumbnail: c_tn_blue_lm, thumbnailDarkMode: c_tn_blue_dm, colors:ColorPaletteBlue))
        allPalettes.append(palette(name: c_gray, thumbnail: c_tn_gray_lm, thumbnailDarkMode: c_tn_gray_dm, colors:ColorPaletteGray))
        //        allPalettes.append(palette(name: c_palette03, thumbnail: c_tn_P03_lm, thumbnailDarkMode: c_tn_P03_dm, colors:ColorPalette03))
    }
    
} //class
