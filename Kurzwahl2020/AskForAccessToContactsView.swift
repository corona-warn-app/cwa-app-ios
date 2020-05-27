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
                Text("How to Enter a Number")
                    .fontWeight(.bold)
                Text("Double tap to enter a phone number and name. Alternatively tap and hold a field. Then choose 'Edit' from the menue.").multilineTextAlignment(.leading).padding()
                Text("")
                Text("Start a Phone Call")
                    .fontWeight(.bold)
                Text("Tap to start a phone call. Alternatively tap and hold, then choose 'Call number' from the  menue.").multilineTextAlignment(.leading).padding()
                Text("")
                Text("Access Contacts")
                    .fontWeight(.bold)
                Text("In case you want to pick phone numbers from your contacts then please go to Settings – Privacy – Contacts and grant access to the contacts.").multilineTextAlignment(.leading).padding()                
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

