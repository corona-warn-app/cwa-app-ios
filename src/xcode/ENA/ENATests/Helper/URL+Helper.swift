//
//  URL+Helper.swift
//  ENATests
//
//  Created by Kienle, Christian on 14.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation

extension URL {
    init(staticString: StaticString) {
        // swiftlint:disable:next force_unwrapping
        self.init(string: "\(staticString)")!
    }
}
