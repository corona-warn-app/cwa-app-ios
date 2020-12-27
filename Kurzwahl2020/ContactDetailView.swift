//
//  ContactDetailView.swift
//  Kurzwahl2020
//
//  Created by Andreas Vogel on 03.02.20.
//  Copyright © 2020 Vogel, Andreas. All rights reserved.
//

import SwiftUI
import Contacts

struct ContactDetailView: View {
    @State var name : String = ""
    @EnvironmentObject var editNavigation: NavigationStack
    
    
    
    var body: some View {
        VStack {
            SingleActionBackView( title: AppStrings.contacts.phoneNumbers,
                                  buttonText: NSLocalizedString("Cancel", comment: "Navigation bar Cancel button"),
                                  action:{
                                    self.editNavigation.unwind()
            })
            List {
                ForEach(contactDataModel.getNumbers(forName: self.name)) { person in
                    contactDetailRow(person: person)
                }
            }
        }
    }
}

struct ContactDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ContactDetailView()
    }
}



struct contactDetailRow: View {
    var person : myContact
    @EnvironmentObject var navigation: NavigationStack
    @EnvironmentObject var editViewState : EditViewState
    
    var body: some View {
        HStack {
            Button(action: {
                self.editViewState.userSelectedName = self.person.name
                self.editViewState.userSelectedNumber = self.person.phoneNumber
                self.navigation.unwind2()})
            {
                HStack {
                    Text(person.name)
                    
                    Spacer()
                    if person.label == CNLabelPhoneNumberMobile {
                        Text("Mobile").font(.footnote).fontWeight(.light)
                    } else if person.label == CNLabelPhoneNumberiPhone {
                        Text("iPhone").font(.footnote).fontWeight(.light)
                    } else if person.label == CNLabelPhoneNumberMain {
                        Text("Main").font(.footnote).fontWeight(.light)
                    } else if person.label == "_$!<Home>!$_" {
                        Text("Home").font(.footnote).fontWeight(.light)
                    } else if person.label == "_$!<Work>!$_" {
                        Text("Work").font(.footnote).fontWeight(.light)
                    }
                    
                    
                    
                    if person.imageDataAvailable == true {
                        Image(uiImage: UIImage(data: person.thumbnailImageData!)! ).resizable().renderingMode(.original)
                            .frame(width: appdefaults.thumbnailSize, height: appdefaults.thumbnailSize)
                            .clipShape(Circle().size(width:appdefaults.thumbnailSize, height:appdefaults.thumbnailSize ) )
                            .aspectRatio(contentMode: ContentMode.fit)
                    }
                }
            }//.buttonStyle(PlainButtonStyle())
        }
    }
}
