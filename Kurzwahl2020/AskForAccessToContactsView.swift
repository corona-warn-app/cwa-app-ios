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
            SingleActionBackView( title: "Edit View",
                                  buttonText: "Back",
                                  action:{
                                    self.navigation.unwind()
            })
            VStack{
                Text("In case you want to access your contacts to pick phone numbers then please go to Settings to grant access.").multilineTextAlignment(.leading).customFont(name: globalDataModel.font, style: .body).padding(.horizontal)
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

