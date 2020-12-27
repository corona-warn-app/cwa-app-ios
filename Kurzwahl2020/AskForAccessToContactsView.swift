//
//  AskForAccessToContactsView.swift
//  Kurzwahl2020
//
//  Created by Vogel, Andreas on 22.02.20.
//  Copyright © 2020 Vogel, Andreas. All rights reserved.
//

import SwiftUI

struct AskForAccessToContactsView: View {
    @EnvironmentObject var navigation: NavigationStack
    
    var body: some View {
        
        VStack{
            SingleActionBackView( title: "",
                                   buttonText: NSLocalizedString("Back", comment: "Navigation bar Back button"),
                                  action:{
                                    self.navigation.unwind()
            })
            VStack{
                Text(AppStrings.askForAccess.heading1).fontWeight(.bold)
                Text("")
                Text(AppStrings.askForAccess.paragraph1).multilineTextAlignment(.leading).padding()
                Text(AppStrings.askForAccess.heading2).fontWeight(.bold)
                Text(AppStrings.askForAccess.paragraph2).multilineTextAlignment(.leading).padding()
                Text("")
                Text(AppStrings.askForAccess.heading3).fontWeight(.bold)
                Text(AppStrings.askForAccess.paragraph3).multilineTextAlignment(.leading).padding()
                Spacer()
            }
        }
        
    }
    
}

struct AskForAccessToContactsView_Previews: PreviewProvider {
    static var previews: some View {
        AskForAccessToContactsView()
    }
}

