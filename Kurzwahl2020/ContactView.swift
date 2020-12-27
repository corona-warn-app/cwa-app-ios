//
//  ContactView.swift
//  Kurzwahl2020
//
//  Created by Vogel, Andreas on 22.01.20.
//  Copyright © 2020 Vogel, Andreas. All rights reserved.
//

import SwiftUI
import Contacts
import Combine

struct ContactView: View {
    @EnvironmentObject var editNavigation: NavigationStack
    @EnvironmentObject var editViewState : EditViewState
    
    let contacts = contactDataModel.getUniqueContacts()
    
    var body: some View {
        VStack{
            SingleActionBackView( title: NSLocalizedString("contacts", comment: "Navigation bar title"),
                                  buttonText: NSLocalizedString("contactView_cancel", comment: "Navigation bar Cancel button"),
                                  action:{
                                    self.editNavigation.unwind()
            })
            List {
                ForEach(contacts) { person  in
                    contactRow(person: person)
                }
            }
        }
    }
}



struct contactRow: View {
    var person : myContact
    @EnvironmentObject var navigation: NavigationStack
    @EnvironmentObject var editViewState : EditViewState
    
    var body: some View {
        HStack {
            Button(action: {
                if (contactDataModel.getNumberOfPhoneNumbers(forContactName: self.person.name) == 1){
                    self.editViewState.userSelectedName = self.person.name
                    self.editViewState.userSelectedNumber = self.person.phoneNumber
                    self.editViewState.label = self.person.label
                    self.editViewState.imageDataAvailable = self.person.imageDataAvailable
                    if self.editViewState.imageDataAvailable == true {
                        self.editViewState.thumbnailImageData = self.person.thumbnailImageData
                    }
                    
                    self.navigation.unwind()
                } else {
                    self.editViewState.userSelectedName = self.person.name
                    self.editViewState.userSelectedNumber = self.person.phoneNumber
                    self.editViewState.label = self.person.label
                    self.editViewState.imageDataAvailable = self.person.imageDataAvailable
                    if self.editViewState.imageDataAvailable == true {
                        self.editViewState.thumbnailImageData = self.person.thumbnailImageData
                    }
                    self.navigation.advance(NavigationItem(view: AnyView(ContactDetailView(name: self.person.name))))
                    
                }
            })
            {
                HStack {
                    Text(person.name)
                    Spacer()
                    if person.imageDataAvailable == true {
                        Image(uiImage: UIImage(data: person.thumbnailImageData!)! ).resizable().renderingMode(.original)
                            .frame(width: appdefaults.thumbnailSize, height: appdefaults.thumbnailSize)
                            .clipShape(Circle().size(width:appdefaults.thumbnailSize, height:appdefaults.thumbnailSize ) )
                            .aspectRatio(contentMode: ContentMode.fit)
                        
                    }
                }//.padding()
            }//.buttonStyle(PlainButtonStyle())

        }
    }
}



struct ContactView_Previews: PreviewProvider {
    static var previews: some View {
        ContactView()
    }
}
