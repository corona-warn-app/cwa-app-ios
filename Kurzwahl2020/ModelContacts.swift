//
//  ModelContacts.swift
//  Kurzwahl2020
//
//  Created by Vogel, Andreas on 23.01.20.
//  Copyright © 2020 Vogel, Andreas. All rights reserved.
//

import Foundation
import Contacts
import Combine
import UIKit

struct myContact : Identifiable {
    var id = UUID()
    var name: String
    var phoneNumber: String
    var label: String
    var imageDataAvailable : Bool
    var thumbnailImageData : Data
}


// see https://stackoverflow.com/questions/41304147/how-can-i-get-all-my-contacts-phone-numbers-into-an-array
// https://stackoverflow.com/questions/24852175/how-to-retrieve-address-book-contacts-with-swift

class contactReader: ObservableObject{
    @Published var myContacts = [myContact]()
    
    func contactsFromAddressBook() -> [myContact] {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        if status == .denied || status == .restricted {
            //            presentSettingsActionSheet()
            return self.myContacts
        }
        
        // open it
        
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, error in
            guard granted else {
                DispatchQueue.main.async {
                    //                    self.presentSettingsActionSheet()
                }
                return
            }
            
            // get the contacts
            
            var contacts = [CNContact]()
            let contactKeys = [CNContactIdentifierKey as CNKeyDescriptor,
                               CNContactImageDataKey as CNKeyDescriptor,
                               CNContactPhoneNumbersKey as CNKeyDescriptor,
//                               CNContactImageDataKey as CNKeyDescriptor,
                               CNContactImageDataAvailableKey as CNKeyDescriptor,
                               CNContactThumbnailImageDataKey as CNKeyDescriptor,
                               CNContactFormatter.descriptorForRequiredKeys(for: .fullName)]
            let request = CNContactFetchRequest(keysToFetch: contactKeys)
            
            do {
                try store.enumerateContacts(with: request) { contact, stop in
                    contacts.append(contact)
                }
                
                
            } catch  {
                print(error)
            }
            
            // do something with the contacts array (e.g. print the names)
            let formatter = CNContactFormatter()
            formatter.style = .fullName
            var contactThumbnailData = Data()
            
            for contact in contacts {
                var allNumbers =  [String]()
                var allLabels =  [String]()
                let name = formatter.string(from: contact) ?? "???"
                
                if contact.imageDataAvailable == true {
                    contactThumbnailData = contact.thumbnailImageData ?? Data()
                }
                
                // If phoneNo a Mobilenumber, then put into Array:
                for phoneNo in contact.phoneNumbers {
                    if (phoneNo.label == CNLabelPhoneNumberMobile ||
                        phoneNo.label == CNLabelPhoneNumberiPhone ||
                        phoneNo.label == CNLabelPhoneNumberMain ||
                        phoneNo.label == "_$!<Home>!$_" ||
                        phoneNo.label == "_$!<Work>!$_" ) {
// https://stackoverflow.com/questions/58578341/how-to-implement-localization-in-swift-ui
                        if phoneNo.value.stringValue.count > 0 {
                            allNumbers.append(phoneNo.value.stringValue)
                            allLabels.append(phoneNo.label ?? "")
                        }
                        self.myContacts.append(myContact(name: name,
                                                         phoneNumber: phoneNo.value.stringValue,
                                                         label: phoneNo.label ?? "",
                                                         imageDataAvailable: contact.imageDataAvailable,
                                                         thumbnailImageData: contactThumbnailData)
                        )
                    }
                }
            }
        }
        return self.myContacts
    }
    
}

