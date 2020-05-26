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
                Text("How to Enter a Number").customFont(name: globalDataModel.font, style: .body)
                Text("Double tap to enter a phone number and name. Alternatively tap and hold a field. Then choose 'Edit' from the menue.").multilineTextAlignment(.leading).customFont(name: globalDataModel.font, style: .body).padding(.horizontal)
                Text("")
                Text("Start a Phone Call").customFont(name: globalDataModel.font, style: .body)
                
                Text("Tap to start a phone call. Alternatively tap and hold, then choose 'Call number' from the  menue.").multilineTextAlignment(.leading).customFont(name: globalDataModel.font, style: .body).padding(.horizontal)
                Text("")
                Text("iPhone Contacts").customFont(name: globalDataModel.font, style: .body)
                Text("In case you want to pick phone numbers from your contacts then please go to Settings – Privacy – Contacts and grant access to the contacts.").multilineTextAlignment(.leading).customFont(name: globalDataModel.font, style: .body).padding(.horizontal)
                
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

