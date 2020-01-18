//
//  SettingsView.swift
//  Kurzwahl2020
//
//  Created by Andreas Vogel on 27.12.19.
//  Copyright © 2019 Vogel, Andreas. All rights reserved.
//
// see https://dev.to/kevinmaarek/forms-made-easy-with-swiftui-3b75
// see https://heckj.github.io/swiftui-notes/

import SwiftUI
import Combine

struct SettingsView: View {
    @ObservedObject var model : kurzwahlModel
    
    
   var body: some View {
       NavigationView {
           Form {
            Section(header: Text("Font Size")) {
                Stepper(value: $model.fontSize, in: 12...64) {
                    Text("Size: \(model.getFontSizeAsInt())")
                }//.font(Font.system(size: 22)) //.labelsHidden
            }
           }
           .navigationBarTitle(Text("Settings"))
       }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(model: globalDataModel)
    }
}
