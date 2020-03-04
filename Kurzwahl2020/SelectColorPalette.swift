//
//  SelectColorPalette.swift
//  Kurzwahl2020
//
//  Created by Vogel, Andreas on 03.03.20.
//  Copyright © 2020 Vogel, Andreas. All rights reserved.
//

import SwiftUI

struct SelectColorPalette: View {
    @EnvironmentObject var navigation: NavigationStack
    let cm: ColorManagement = ColorManagement()
    
    var body: some View {
        VStack {
            SingleActionBackView( title: "",
                                  buttonText: NSLocalizedString("Cancel", comment: "Navigation bar Cancel button"),
                                  action:{
                                    self.navigation.unwind()
            })
            
            Text("Select a new palette")
            List {
                ForEach(cm.getAllThumbnails()) { p in
                    thumbnailRow(colorPalette: p)
                }
            }
            Spacer()
        }
    }
}

struct SelectColorPalette_Previews: PreviewProvider {
    static var previews: some View {
        SelectColorPalette()
    }
}



struct thumbnailRow : View {
    @EnvironmentObject var paletteViewState: PaletteSelectViewState
    var colorPalette: palette
    @EnvironmentObject var navigation: NavigationStack
    var body: some View {
        HStack{
            Button(action: {
                self.paletteViewState.selectedPaletteName = self.colorPalette.name
                self.navigation.unwind() })
            {
                Text(self.colorPalette.name)
                Spacer()
                Image(self.colorPalette.thumbnail).resizable().frame(width: 30, height: 57)
            }.buttonStyle(PlainButtonStyle())
        }
    }
}
