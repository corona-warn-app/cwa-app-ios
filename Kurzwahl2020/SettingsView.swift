//
//  SettingsView.swift
//  Kurzwahl2020
//
//  Created by Andreas Vogel on 12.01.20.
//  Copyright © 2020 Vogel, Andreas. All rights reserved.
//

import SwiftUI
import Combine

struct SettingsView: View {
    @ObservedObject var model : kurzwahlModel
    @EnvironmentObject var navigation: NavigationStack
    
    
    var body: some View {
        NavigationView {
            VStack{
                Form {
                    Section(header: Text(AppStrings.settings.fontSize)) {
                        Stepper(value: $model.fontSize, in: 12...64) {
                            Text("Size: \(model.getFontSizeAsInt())")
                        } //.labelsHidden
                    }.padding(.leading, 2.0)

                    Button(action: {
                        self.navigation.advance(NavigationItem(
                    view: AnyView(ColorSelectView()))) }) {
                        Text(AppStrings.settings.colors)
                    }//.buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        self.navigation.advance(NavigationItem(
                    view: AnyView(AskForAccessToContactsView()))) }) {
                        Text(AppStrings.settings.help)
                    }//.buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        self.navigation.advance(NavigationItem(
                    view: AnyView(PrivacyView()))) }) {
                        Text(AppStrings.settings.data_Privacy_Statement)
                    }//.buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        self.navigation.advance(NavigationItem(
                    view: AnyView(AboutView()))) }) {
                        Text(AppStrings.settings.about)
                    }//.buttonStyle(PlainButtonStyle())

                }.navigationBarTitle(Text(AppStrings.settings.settings))
            }
        }
    }
    
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(model: globalDataModel)
    }
}


