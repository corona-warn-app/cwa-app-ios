//
//  PrivacyView.swift
//  Kurzwahl2020
//
//  Created by Andreas Vogel on 19.01.20.
//  Copyright © 2020 Vogel, Andreas. All rights reserved.
//

import SwiftUI

struct PrivacyView: View {
    @EnvironmentObject var navigation: NavigationStack
    
    var body: some View {
        VStack{
            SingleActionBackView( title: "",
                                  buttonText: NSLocalizedString("Back", comment: "Navigation bar Back button"),
                                  action:{
                                    self.navigation.unwind()
            })
            VStack{

                
                Text("Privacy Policy").font(Font.custom(globalDataModel.font, size: 26)).frame(height: 50)
                Text("All information you enter in this app will stay on your iPhone. No personal information is collected by this app. In case you want to copy names and phone numbers from your contact list then please grant access to your contacts if asked.").multilineTextAlignment(.leading).customFont(name: globalDataModel.font, style: .body).padding(.horizontal)
                Spacer()
                
            }
        }
    }
}

struct PrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyView()
    }
}
