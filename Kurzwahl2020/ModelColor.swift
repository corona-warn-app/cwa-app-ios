//
//  KurzwahlView.swift
//  Kurzwahl2020
//
//  Created by Vogel, Andreas on 30.10.19.
//  Copyright © 2019 Vogel, Andreas. All rights reserved.
//
import Foundation
import SwiftUI
import Combine



class tileColor: ObservableObject{
    @Published var name : String = "Alice"
    
    init(selectedName: String) {
        self.name = selectedName
    }
}

// the color names refer to the items in Asset.xcassets
var AssetColorList: [String] = [
    "OrangeFF9500","Darkblue00398E", "RedFF3A2D",  "RedAC193D",
    "Green008A00", "OrangeD24726", "Green00A600", "Blue2E8DEF",
    "Darkgrey6E6E6E", "lightGreyAEAEAE", "DarkViolet5856D6", "grey8E8E8E",
    
    //    2nd screen – lipstick pink
    "E69D95", "E07260", "C83773", "B8A89F",
    "665A5C", "C64247", "B4938C", "EAA598",
    "9B7983", "B897BB", "885D8D", "742E34"
]


// for a given number return the corresponding color
extension Color {
    static func appColor(_ id: Int) -> Color? {
        var name: String
        if id < 24 {
            name = AssetColorList[id]
        }
        else {
            name = "Black"
        }
        return Color.init(name, bundle: nil)
    }
}

