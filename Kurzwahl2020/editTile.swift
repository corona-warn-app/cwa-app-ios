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
    @State var colorHexCode : String = ""
    @EnvironmentObject var navigation: NavigationStack
    var noColor = Color(.black)
    
    var body: some View {
        
        VStack{
            BackView( title: "Edit View",action:{
                self.navigation.unwind()
            })//.font(Font.system(size: 22))
            Form {
                Section(header: Text("Enter Name and Phone Number")) {
                    TextField("Name", text: $name).disableAutocorrection(true)
                    TextField("Number", text: $number).disableAutocorrection(true).keyboardType(.phonePad)
                    
                }//.font(Font.system(size: 22)) //.labelsHidden
//                Section(header: Text("Color Code – experimental")) {
//                    TextField( globalDataModel.getUIColor(withId: tileId).hexCode(), text: $colorHexCode)
//                }
                HStack {
                    Button(action: {
                        globalDataModel.modifyTile(withTile: tile.init(id: self.tileId, name: self.name, phoneNumber: self.number, backgroundColor: globalDataModel.getColorName(withId: self.tileId)))
                        globalDataModel.persist()
                        self.navigation.unwind()}) {
                            Text("OK").foregroundColor(Color.accentColor)
                    }.buttonStyle(PlainButtonStyle())//.font(Font.system(size: 22))
                }
                HStack {
                    Button(action: {
                        self.navigation.advance(NavigationItem(
                    view: AnyView(ContactView()))) }) {
                        Text("Contacts")
                    }.buttonStyle(PlainButtonStyle())
                    
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



// provide a hex code for a UIColor
extension UIColor {
    func hexCode() -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let hexCodeRed : String = String(NSString(format:"%02X", Int(255 * red)))
        let hexCodeGreen : String = String(NSString(format:"%02X", Int(255 * green)))
        let hexCodeBlue : String = String(NSString(format:"%02X", Int(255 * blue)))
        let hexCodeAlpha : String = String(NSString(format:"%02X", Int(255 * alpha)))
        
        return(hexCodeRed + hexCodeGreen + hexCodeBlue + hexCodeAlpha)
        
        
    }
}
