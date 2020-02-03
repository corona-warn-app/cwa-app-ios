//
//  ContactDetailView.swift
//  Kurzwahl2020
//
//  Created by Andreas Vogel on 03.02.20.
//  Copyright © 2020 Vogel, Andreas. All rights reserved.
//

import SwiftUI

struct ContactDetailView: View {
    @State var name : String = ""
    @EnvironmentObject var editNavigation: NavigationStack
    
    
    
    var body: some View {
        VStack {
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
                self.navigation.unwind()})
            {
                Text(person.name)
            }.buttonStyle(PlainButtonStyle())
            Spacer()
            Text(person.label)
            
            
            if person.imageDataAvailable == true {
                Image(uiImage: UIImage(data: person.thumbnailImageData)! ).resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle().size(width:50, height:50 ) )
                    .aspectRatio(contentMode: ContentMode.fit)
            }
        }
    }
}
