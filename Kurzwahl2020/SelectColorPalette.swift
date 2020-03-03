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
    
    
    var body: some View {
        VStack {
            SingleActionBackView( title: "",
                                  buttonText: NSLocalizedString("Cancel", comment: "Navigation bar Cancel button"),
                                  action:{
                                    self.navigation.unwind()
            })
            
            Text("Select a new palette")
        

            Spacer()
        }
    }
}

struct SelectColorPalette_Previews: PreviewProvider {
    static var previews: some View {
        SelectColorPalette()
    }
}
