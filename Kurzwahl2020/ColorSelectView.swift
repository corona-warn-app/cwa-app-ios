//
//  ColorSelectView.swift
//  Kurzwahl2020
//
//  Created by Vogel, Andreas on 01.03.20.
//  Copyright © 2020 Vogel, Andreas. All rights reserved.
//

import SwiftUI

struct ColorSelectView: View {
    @EnvironmentObject var navigation: NavigationStack
    
    var body: some View {
        VStack{
            SingleActionBackView( title: "",
                                   buttonText: NSLocalizedString("Back", comment: "Navigation bar Back button"),
                                  action:{
                                    self.navigation.unwind()
            })
            VStack{
                Text("Show the two/three screens").multilineTextAlignment(.leading).customFont(name: globalDataModel.font, style: .body).padding(.horizontal)
                Spacer()
            }
        }
    }
}

struct ColorSelectView_Previews: PreviewProvider {
    static var previews: some View {
        ColorSelectView()
    }
}
