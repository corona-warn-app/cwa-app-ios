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

struct AboutView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 4){
            Text("Call by Color 36").font(Font.custom(globalDataModel.font, size: 26))
            Text("Version 1.0").font(Font.custom(globalDataModel.font, size: 18))
            Divider()
            Text("Privacy Policy").font(Font.custom(globalDataModel.font, size: 18))
            Text("In case you want to copy names and phone numbers from your contacts then please grant access to your contacts. All information you enter in this app will stay on your iPhone. No personal information is collected by this app.").font(Font.custom(globalDataModel.font, size: 18)).padding(.horizontal)
//            Text("All information you enter in this app will stay on your iPhone. No personal information is collected by this app. ").font(Font.custom(globalDataModel.font, size: 18)).padding(.horizontal)
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
