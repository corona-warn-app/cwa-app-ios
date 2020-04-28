//
//  NSObject.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 28.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation

extension NSObject {
    /// Returns the string representation of NSObject class.
    ///
    /// - Returns: String representation of the instance.
    static func stringName() -> String {
        String(describing: self)
    }
}
