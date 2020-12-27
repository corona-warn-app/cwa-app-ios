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
                                  buttonText: AppStrings.privacyPolicy.backButton,
                                  action:{
                                    self.navigation.unwind()
            })
            VStack{

                
                Text(AppStrings.privacyPolicy.heading1).font(.title)
                Text(AppStrings.privacyPolicy.paragraph1)
                    .fontWeight(.regular).multilineTextAlignment(.leading).padding()
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
