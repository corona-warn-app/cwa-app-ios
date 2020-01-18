//
//  AboutView.swift
//  Kurzwahl2020
//
//  Created by Andreas Vogel on 12.01.20.
//  Copyright © 2020 Vogel, Andreas. All rights reserved.
//

//    return [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
//    return [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];

import SwiftUI
import Combine

struct AboutView: View {
    @EnvironmentObject var navigation: NavigationStack
    
    var body: some View {
        
        VStack{
            BackView( title: "Edit View",action:{
                self.navigation.unwind()
            })
            VStack{
                Text("Call by Color 36").font(Font.custom(globalDataModel.font, size: 26))
                Text("Version 1.0").font(Font.custom(globalDataModel.font, size: 18))
                
                    Image("Icon120").cornerRadius(20)
                    Spacer()
                        .fixedSize()
                        .frame(width: 150, height: 20)
                
                Text("Privacy Policy").font(Font.custom(globalDataModel.font, size: 26)).frame(height: 50)
                Text("All information you enter in this app will stay on your iPhone. No personal information is collected by this app. In case you want to copy names and phone numbers from your contact list then please grant access to your contacts.").font(Font.custom(globalDataModel.font, size: 18)).padding(.horizontal).multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                Spacer()
                
            }
        }
        
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
