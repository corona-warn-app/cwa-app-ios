//
//  TestView.swift
//  Kurzwahl2020
//
//  Created by Andreas Vogel on 12.01.20.
//  Copyright © 2020 Vogel, Andreas. All rights reserved.
//

import SwiftUI
import Combine

struct TestView: View {
    @ObservedObject var model : kurzwahlModel
    @EnvironmentObject var navigation: NavigationStack
    
    
   var body: some View {
    VStack{
        TitleView( title: "Settings", homeAction: {self.navigation.home()})
        Form {
            Section(header: Text("Font Size")) {
                Stepper(value: $model.fontSize, in: 12...64) {
                    Text("Size: \(model.getFontSizeAsInt())")
                } //.labelsHidden
            }
            Button(action: {
                self.navigation.advance(NavigationItem(
                    view: AnyView(AboutView()))) }) {
                    Text("About")
            }.buttonStyle(PlainButtonStyle())
        }
       }
    }
    
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(model: globalDataModel)
    }
}
