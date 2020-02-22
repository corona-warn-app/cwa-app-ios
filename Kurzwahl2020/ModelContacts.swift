//
//  ModelContacts.swift
//  Kurzwahl2020
//
//  Created by Vogel, Andreas on 23.01.20.
//  Copyright © 2020 Vogel, Andreas. All rights reserved.
//

import Foundation
import Contacts // Make sure to supply a NSContactsUsageDescription in your Info.plist
import Combine
import UIKit

struct myContact : Identifiable, Hashable {    
    var id = UUID()
    var name: String
    var phoneNumber: String
    var label: String
    var imageDataAvailable : Bool
    var thumbnailImageData : Data?
}


// see https://stackoverflow.com/questions/41304147/how-can-i-get-all-my-contacts-phone-numbers-into-an-array
// https://stackoverflow.com/questions/24852175/how-to-retrieve-address-book-contacts-with-swift

class contactReader: ObservableObject{
    var myContacts = [myContact]()
    var uniqueContacts = [myContact]()
    
    func contactsFromAddressBook() -> [myContact] {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        if status == .denied || status == .restricted {
            print("CNContactStore.authorizationStatus denied")
            return self.myContacts
        }
        
        // open it
        
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, error in
            guard granted else {
                DispatchQueue.main.async {
                    print("requestAccess: \(granted)")
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
            request.sortOrder = CNContactSortOrder.familyName
            
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
            
            
            for contact in contacts {
                var imageDataAvailable : Bool = false
                var contactThumbnailData : Data?
                
                let name = formatter.string(from: contact) ?? "???"
                
                if contact.imageDataAvailable == true {
                    if let imageData = contact.thumbnailImageData {
                        imageDataAvailable = true
                        contactThumbnailData = imageData
                    } else {
                        imageDataAvailable = false
                    }
                }
                
                // If phoneNo a Mobilenumber, then put into Array:
                for phoneNo in contact.phoneNumbers {
                    if (phoneNo.label == CNLabelPhoneNumberMobile ||
                        phoneNo.label == CNLabelPhoneNumberiPhone ||
                        phoneNo.label == CNLabelPhoneNumberMain ||
                        phoneNo.label == "_$!<Home>!$_" ||
                        phoneNo.label == "_$!<Work>!$_" ) {
                        // https://stackoverflow.com/questions/58578341/how-to-implement-localization-in-swift-ui
                        self.myContacts.append(myContact(name: name,
                                                         phoneNumber: phoneNo.value.stringValue,
                                                         label: phoneNo.label ?? "",
                                                         imageDataAvailable: imageDataAvailable,
                                                         thumbnailImageData: contactThumbnailData)
                        )
                    }
                }
            }
        }
        return self.myContacts
    }
    
    
    
    func getUniqueContacts() -> [myContact] {
        if uniqueContacts.count == 0 {
            if myContacts.count == 0 {
                uniqueContacts = self.removeDuplicates(arrayOfContacts: self.contactsFromAddressBook())
            }
            uniqueContacts = self.removeDuplicates(arrayOfContacts: myContacts)
        }
        return uniqueContacts
    }
    
    
    
    fileprivate func removeDuplicates(arrayOfContacts: [myContact]) -> [myContact] {
        var added = [String]()
        var result = [myContact]()
        
        for contact in arrayOfContacts {
            if !added.contains(contact.name) {
                result.append(contact)
                added.append(contact.name)
            }
        }
        return result
    }
    
    
    
    func getNumberOfPhoneNumbers(forContactName: String)-> Int {
        var count : Int = 0
        for contact in myContacts {
            if (contact.name == forContactName) {
                count += 1
            }
        }
        return count
    }
    
    
    
    func getNumbers(forName: String)->[myContact] {
        var result = [myContact]()
        for contact in myContacts {
            if (contact.name == forName) {
                result.append(contact)
            }
        }
        return result
    }
    
}
