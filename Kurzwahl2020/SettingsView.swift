//
//  SettingsView.swift
//  Kurzwahl2020
//
//  Created by Andreas Vogel on 27.12.19.
//  Copyright © 2019 Vogel, Andreas. All rights reserved.
//
// see https://dev.to/kevinmaarek/forms-made-easy-with-swiftui-3b75

import SwiftUI
import Combine

struct SettingsView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var fontsize: String = ""
    
   var body: some View {
       NavigationView {
           Form {
                Section(header: Text("Your Info")) {
                    TextField("Your name", text: $name)
                    TextField("Your email", text: $email)
                }
                Section(header: Text("Password")) {
                    TextField("Password", text: $password)
                }
                Section(header: Text("Font Size")) {
                    TextField("Font Size", text: $fontsize)
                }
                Section {
                        Button(action: {
                    }) {
                        Text("OK")
                    }
            }

           }
           .navigationBarTitle(Text("Registration Form"))
       }
   }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}





