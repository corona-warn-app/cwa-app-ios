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
    @State var tile : Int = 0
    @State private var name : String = ""
    @State private var number : String = ""
    @EnvironmentObject var navigation: NavigationStack
    
    var body: some View {
        
        VStack{
            BackView( title: "Edit View",action:{
            self.navigation.unwind()
               })
            Form {
                Section(header: Text("Enter Name and Phone Number")) {
                    TextField("Name", text: $name).disableAutocorrection(true)
                    TextField("Number", text: $number).disableAutocorrection(true)
                    Text("Tile \(tile)")
                    } //.labelsHidden
                HStack {
                Button(action: {self.navigation.unwind()}) {
                    Text("OK")
                    }.buttonStyle(PlainButtonStyle())
                }
            }
            
        }
    }
}


struct editTile_Previews: PreviewProvider {
    static var previews: some View {
        editTile(model: globalDataModel)
    }
}
