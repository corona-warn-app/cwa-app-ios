//
//  SelectColorPalette.swift
//  Kurzwahl2020
//
//  Created by Vogel, Andreas on 03.03.20.
//  Copyright © 2020 Vogel, Andreas. All rights reserved.
//

import SwiftUI

struct SelectColorPalette: View {
    var screenIndex: Int
    @EnvironmentObject var navigation: NavigationStack
    @EnvironmentObject var colorManager: ColorManagement
    
    var body: some View {
        VStack {
            SingleActionBackView( title: "",
                                  buttonText: NSLocalizedString("Cancel", comment: "Navigation bar Cancel button"),
                                  action:{
                                    self.navigation.unwind()
            })
            
            Text("Select a new palette")
            List {
                ForEach(colorManager.getAllThumbnails()) { p in
                    thumbnailRow(colorPalette: p, screenIndex: self.screenIndex)
                }
            }
            Spacer()
        }
    }
}

struct SelectColorPalette_Previews: PreviewProvider {
    static var previews: some View {
        SelectColorPalette(screenIndex: 0)
    }
}



struct thumbnailRow : View {
    @EnvironmentObject var navigation: NavigationStack
    @EnvironmentObject var paletteViewState: PaletteSelectViewState
    @EnvironmentObject var colorManager : ColorManagement
    var colorPalette: palette
    var screenIndex: Int
    
    var body: some View {
        HStack{
            Button(action: {
                self.colorManager.setScreenPalette(withIndex: self.screenIndex, name: self.colorPalette.name)
                self.colorManager.setAllColors()
                self.navigation.unwind() })
            {
                Text(self.colorPalette.name)
                Spacer()
                Image(self.colorPalette.thumbnail).resizable().frame(width: 30, height: 57)
            }.buttonStyle(PlainButtonStyle())
        }
    }
}
