//
//  editView.swift
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
import Contacts


final class EditViewState: ObservableObject {
    @Published var userSelectedName = String()
    @Published var userSelectedNumber = String()
    @Published var label = String()
    @Published var imageDataAvailable = Bool()
    @Published var thumbnailImageData : Data?
}


struct editView: View {
    
    @State var tileId : Int = 0
    @State var colorHexCode : String = ""
    @EnvironmentObject var navigation: NavigationStack
    @EnvironmentObject var editViewState : EditViewState
    var noColor = Color(.black)
    
    var body: some View {
        
        VStack{
            BackView( title: NSLocalizedString("Edit", comment: "Navigation bar title"),
                      okAction: {
                        globalDataModel.modifyTile(withTile: phoneTile.init(id: self.tileId,
                                                                       name: self.editViewState.userSelectedName,
                                                                       phoneNumber: self.editViewState.userSelectedNumber,
                                                                       backgroundColor: globalDataModel.getColorName(withId: self.tileId)))
                        globalDataModel.persist()
                        self.cleanEditViewState()
                        self.navigation.unwind()
                        },
                      cancelAction: {
                        self.cleanEditViewState()
                        self.navigation.unwind()
                        }
            )
            
            Form {
                Section(header: Text("Enter Name and Phone Number")) {
                    HStack {
                        TextField("Name", text: $editViewState.userSelectedName).disableAutocorrection(true)
                        Spacer()
                        if self.editViewState.imageDataAvailable == true {
                            Image(uiImage: UIImage(data: self.editViewState.thumbnailImageData!)! ).resizable()
                                .frame(width: appdefaults.thumbnailSize, height: appdefaults.thumbnailSize)
                                .clipShape(Circle().size(width:appdefaults.thumbnailSize, height:appdefaults.thumbnailSize ) )
                                .aspectRatio(contentMode: ContentMode.fit)
                        }
                    }
                    TextField("Number", text: $editViewState.userSelectedNumber).disableAutocorrection(true).keyboardType(.phonePad)
                    
                }//.font(Font.system(size: 22)) //.labelsHidden
                //                Section(header: Text("Color Code – experimental")) {
                //                    TextField( globalDataModel.getUIColor(withId: tileId).hexCode(), text: $colorHexCode)
                //                }
                HStack {
                    if CNContactStore.authorizationStatus(for: .contacts) == CNAuthorizationStatus.authorized {
                        Button(action: {
                            self.navigation.advance(NavigationItem(
                                view: AnyView(ContactView()))) }) {
                                    HStack {
                                        Text(AppStrings.edit.contacts).foregroundColor(Color.accentColor)
                                        Spacer()
                                        Image(systemName: "person.2")
                                    }
                        }//.buttonStyle(PlainButtonStyle())
                    } else {
                        Button(action: {
                            self.navigation.advance(NavigationItem(
                                view: AnyView(AskForAccessToContactsView()))) }) {
                                    HStack {
                                        Text(AppStrings.edit.contacts).foregroundColor(Color.accentColor)
                                        Spacer()
                                        Image(systemName: "person.2")
                                    }
                        }//.buttonStyle(PlainButtonStyle())
                    }
                    
                }
                
                HStack {
                    Button(action: {
                        self.cleanEditViewState()
                    }) {
                        HStack {
                            Text("Clear").foregroundColor(Color.accentColor)
                            Spacer()
                            Image(systemName: "trash")
                        }
                    }//.buttonStyle(PlainButtonStyle())//.font(Font.system(size: 22))
                }
            }
            
        }
    }



    func cleanEditViewState() {
        editViewState.userSelectedName = ""
        editViewState.userSelectedNumber = ""
        editViewState.imageDataAvailable = false
        editViewState.label = ""
        editViewState.thumbnailImageData = Data()
    }

}






struct editView_Previews: PreviewProvider {
    static var previews: some View {
        editView()
    }
}



struct BackView: View{
    var title: String
    var okAction: ()->Void
    var cancelAction: ()->Void
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    var body: some View {
        ZStack{
            //            Rectangle().fill(Color.secondary).frame( height: 40 )
            Rectangle().fill(colorScheme == .light ? Color.white : Color.black).frame( height: 40 )
            HStack{
                Button( action: cancelAction){ Text(AppStrings.edit.cancel).padding(.leading, 15)
                }.foregroundColor(Color.accentColor)
                Spacer()
                Text(title).padding(.leading, 20).font(Font.system(size: 20)).padding(.trailing, 20)
                Spacer()
                Button( action: okAction){ Text("OK").padding(.trailing, 15)
                }.foregroundColor(Color.accentColor)
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
