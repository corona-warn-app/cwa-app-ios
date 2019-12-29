//
//  SettingsView.swift
//  Kurzwahl2020
//
//  Created by Andreas Vogel on 27.12.19.
//  Copyright © 2019 Vogel, Andreas. All rights reserved.
//
// see https://dev.to/kevinmaarek/forms-made-easy-with-swiftui-3b75

import SwiftUI
import Combine

struct SettingsView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    //@State private var password: String = ""
//    @ObservedObject private var myname : tileColor
    @State private var fontsize: String = "28"
    @State private var size: Int = 26
    
   var body: some View {
       NavigationView {
           Form {
                Section(header: Text("Your Info")) {
                    TextField("Your name", text: $name)
                    TextField("Your email", text: $email)
                }
//                Section(header: Text("Password")) {
//                    TextField("Password", text: $passwordChecker.password)
//                    SecureLevelView(level: self.passwordChecker.level)
//                }
                Section(header: Text("Font Size")) {
                    TextField("Font Size", text: $fontsize)
                }
            Section(header: Text("Stepper")) {
                Stepper(value: $size, in: 20...36) {
                    Text("Size: \(size)")
                }
            }
                Section {
                        Button(action: {
                    }) {
                        Text("OK")
                    }
            }

           }
           .navigationBarTitle(Text("Registration Form"))
       }
   }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}



enum PasswordLevel: Int {
    case none = 0
    case weak = 1
    case ok = 2
    case strong = 3
}

struct SecureLevelView : View {
    var level: PasswordLevel
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 8).foregroundColor(self.getColors()[0]).frame(height: 10)
            RoundedRectangle(cornerRadius: 8).foregroundColor(self.getColors()[1]).frame(height: 10)
            RoundedRectangle(cornerRadius: 8).foregroundColor(self.getColors()[2]).frame(height: 10)
        }
    }

    func getColors() -> [Color] {
        switch self.level {
        case .none:
            return [.clear, .clear, .clear]
        case .weak:
            return [.red, .clear, .clear]
        case .ok:
            return [.red, .orange, .clear]
        case .strong:
            return [.red, .orange, .green]
        }
    }
}

class PasswordChecker: ObservableObject {
    public let didChange = PassthroughSubject<PasswordChecker, Never>()
    var password: String = "" {
        didSet {
            self.checkForPassword(password: self.password)
        }
    }

    var level: PasswordLevel = .none {
        didSet {
            self.didChange.send(self)
        }
    }

    func checkForPassword(password: String) {
        if password.count == 0 {
            self.level = .none
        } else if password.count < 2 {
            self.level = .weak
        } else if password.count < 6 {
            self.level = .ok
        } else {
            self.level = .strong
        }
    }
}
