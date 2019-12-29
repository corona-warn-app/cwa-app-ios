//
//  ModelPhoneNumbers.swift
//  Kurzwahl2020
//
//  Created by Vogel, Andreas on 29.12.19.
//  Copyright © 2019 Vogel, Andreas. All rights reserved.
//

import Foundation
import SwiftUI
import Combine


class numbers: ObservableObject{
    @Published var numbers : [String]
    
    init(withNumbers: [String]) {
        self.numbers = withNumbers
    }
}



class names: ObservableObject{
    @Published var names : [String]
    
    init(withNames: [String]) {
        self.names = withNames
    }
}
