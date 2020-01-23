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


struct myContact {
    var id: Int
    var name: String
    var phoneNumber: String
}


// see https://stackoverflow.com/questions/41304147/how-can-i-get-all-my-contacts-phone-numbers-into-an-array
// https://stackoverflow.com/questions/24852175/how-to-retrieve-address-book-contacts-with-swift

class contactReader: ObservableObject{
    @Published var myContacts = [myContact]()
    var counter : Int = 0
    
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
            let request = CNContactFetchRequest(keysToFetch: [CNContactIdentifierKey as NSString, CNContactPhoneNumbersKey as NSString, CNContactFormatter.descriptorForRequiredKeys(for: .fullName)])
            
            do {
                try store.enumerateContacts(with: request) { contact, stop in
                    contacts.append(contact)
                }
            } catch {
                print(error)
            }
            
            // do something with the contacts array (e.g. print the names)
            var i : Int = 0
            let formatter = CNContactFormatter()
            formatter.style = .fullName
            for contact in contacts {
                print(formatter.string(from: contact) ?? "???")
                
                
                let name = formatter.string(from: contact) ?? "???"
                
                // If phoneNo a Mobilenumber, then put into Array:
                for phoneNo in contact.phoneNumbers {
                    if phoneNo.label == CNLabelPhoneNumberMobile {
                        let istEineMobileNummer = (phoneNo.value).stringValue
                        print(istEineMobileNummer)
                        let aContact = myContact(id: i, name: name, phoneNumber: istEineMobileNummer)
                        self.myContacts.append(aContact)
                    }
                }
                i += 1
            }
        }
        return self.myContacts
    }
    
}

