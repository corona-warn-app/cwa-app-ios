//
//  editTile.swift
//  Kurzwahl2020
//
//  Created by Andreas Vogel on 04.01.20.
//  Copyright © 2020 Vogel, Andreas. All rights reserved.
//
// openURL https://stackoverflow.com/questions/26178324/application-openurl-in-swift
// https://stackoverflow.com/questions/38964264/openurl-in-ios10
// https://useyourloaf.com/blog/openurl-deprecated-in-ios10/
//


import SwiftUI



struct editTile: View {
    
    @State var tileId : Int = 0
    @State var name : String = ""
    @State var number : String = ""
    @EnvironmentObject var navigation: NavigationStack
    
    var body: some View {
        
        VStack{
            BackView( title: "Edit View",action:{
                self.navigation.unwind()
            })//.font(Font.system(size: 22))
            Form {
                Section(header: Text("Enter Name and Phone Number")) {
                    TextField("Name", text: $name).disableAutocorrection(true)
                    TextField("Number", text: $number).disableAutocorrection(true).keyboardType(/*@START_MENU_TOKEN@*/.phonePad/*@END_MENU_TOKEN@*/)
                }//.font(Font.system(size: 22)) //.labelsHidden
                HStack {
                    Button(action: {
                        globalDataModel.modifyTile(withTile: tile.init(id: self.tileId, name: self.name, phoneNumber: self.number))
                        globalDataModel.persist()
                        self.navigation.unwind()}) {
                            Text("OK").foregroundColor(Color.accentColor)
                    }.buttonStyle(PlainButtonStyle())//.font(Font.system(size: 22))
                    
                }
            }
            
        }
    }
}


struct editTile_Previews: PreviewProvider {
    static var previews: some View {
        editTile()
    }
}



struct BackView: View{
    var title: String
    var action: ()->Void
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    var body: some View {
        ZStack{
            //            Rectangle().fill(Color.secondary).frame( height: 40 )
            Rectangle().fill(colorScheme == .light ? Color.white : Color.black).frame( height: 40 )
            HStack{
                Button( action: action){ Text("Cancel").padding(.leading, 15)
                }.foregroundColor(Color.accentColor)
                Spacer()
            }
        }
    }
    
    
}
