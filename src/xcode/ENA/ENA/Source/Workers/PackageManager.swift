//
//  PackageManager.swift
//  ENA
//
//  Created by Bormeth, Marc on 30.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation

class PackageManager {
    private static var shared = PackageManager()
    
    func shared() -> PackageManager {
        return Self.shared
    }
    
}
