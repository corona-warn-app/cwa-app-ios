//
//  SettingsView.swift
//  Kurzwahl2020
//
//  Created by Andreas Vogel on 24.12.19.
//  Copyright © 2019 Vogel, Andreas. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @State private var name: String = "Tim"
    
    var body: some View {
        VStack {
            HStack {
                Text("Font Size")
                TextField("Font Size", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
            }
            Text("Hello, \(name)!")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
