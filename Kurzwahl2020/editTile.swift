//
//  editTile.swift
//  Kurzwahl2020
//
//  Created by Andreas Vogel on 04.01.20.
//  Copyright © 2020 Vogel, Andreas. All rights reserved.
//

import SwiftUI



struct editTile: View {
    @ObservedObject var model : kurzwahlModel
    @State private var name : String = ""
    @State private var number : String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Enter Name and Phone Number")) {
                    TextField("Name", text: $name).disableAutocorrection(true)
                    TextField("Number", text: $number).disableAutocorrection(true)
                    } //.labelsHidden
                HStack {
                Button(action: {
                    
                }) {
                    Text("OK")
                    }.buttonStyle(PlainButtonStyle())
                    
                    
                Button(action: {
                    
                }) {
                    Text("Cancel")
                }
                }
            }
        }.navigationBarTitle(Text("Settings"))
    }
}


struct editTile_Previews: PreviewProvider {
    static var previews: some View {
        editTile(model: globalDataModel)
    }
}
