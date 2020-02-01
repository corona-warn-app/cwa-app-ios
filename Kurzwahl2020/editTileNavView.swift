//
//  editTileNavView.swift
//  Kurzwahl2020
//
//  Created by Vogel, Andreas on 24.01.20.
//  Copyright © 2020 Vogel, Andreas. All rights reserved.
//

import SwiftUI

struct editTileNavView: View {
    @EnvironmentObject var editNavigation: NavigationStack
    
    @State var tileId : Int = 0
    @State var name : String = ""
    @State var number : String = ""
    @State var colorHexCode : String = ""
    
    var noColor = Color(.black)
    
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Enter Name and Phone Number")) {
                    TextField("Name", text: $name).disableAutocorrection(true)
                    TextField("Number", text: $number).disableAutocorrection(true).keyboardType(.phonePad)
                    
                }//.font(Font.system(size: 22)) //.labelsHidden
                HStack {
                    //                    NavigationLink(destination: ContactView()) {
                    Button(action: {
                        self.editNavigation.advance(NavigationItem(
                    view: AnyView(ContactView()))) }) {
                        Text("Contacts")
                    }.buttonStyle(PlainButtonStyle())
                    
                }

                HStack {
                    Button(action: {
                        globalDataModel.modifyTile(withTile: tile.init(id: self.tileId, name: self.name, phoneNumber: self.number, backgroundColor: globalDataModel.getColorName(withId: self.tileId)))
                        globalDataModel.persist()
                        self.editNavigation.unwind()}) {
                            Text("OK").foregroundColor(Color.accentColor)
                    }.buttonStyle(PlainButtonStyle())//.font(Font.system(size: 22))
                }
            }
            
        }.navigationBarTitle(Text("Contact Details"))
        
    }
}

struct editTileNavView_Previews: PreviewProvider {
    static var previews: some View {
        editTileNavView()
    }
}
