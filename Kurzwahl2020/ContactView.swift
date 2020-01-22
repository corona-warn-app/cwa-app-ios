//
//  ContactView.swift
//  Kurzwahl2020
//
//  Created by Vogel, Andreas on 22.01.20.
//  Copyright © 2020 Vogel, Andreas. All rights reserved.
//

import SwiftUI
import Contacts

struct ContactView: View {
    @EnvironmentObject var navigation: NavigationStack
    
    var body: some View {
        VStack{
            AboutBackView( title: "Contact View",action:{
                self.navigation.unwind()
            })
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            Spacer()
        }
    }
}

struct ContactView_Previews: PreviewProvider {
    static var previews: some View {
        ContactView()
    }
}



struct myContact {
    var id: Int
    var name: String
    var phoneNumber: String
}

class contactReader {
    var counter : Int = 0
    var myContacts = [myContact]()
    
    func test() -> [myContact] {
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
                    self.presentSettingsActionSheet()
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
    
    
    
    func presentSettingsActionSheet() {
        let alert = UIAlertController(title: "Permission to Contacts", message: "This app needs access to contacts in order to ...", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Go to Settings", style: .default) { _ in
            let url = URL(string: UIApplication.openSettingsURLString)!
            UIApplication.shared.open(url)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        //        present(alert, animated: true)
    }
    
    
}
