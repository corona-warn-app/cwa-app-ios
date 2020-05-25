//
//  Hasher.swift
//  ENA
//
//  Created by Rohwer, Johannes on 25.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import CryptoKit

enum Hasher {
    /// Hashes the given input string using SHA-256.
    static func sha256(_ input: String) -> String {
        let value = SHA256.hash(data: input.data(using: .utf8) ?? Data())
        let hash = value.compactMap { String(format: "%02x", $0) }.joined()
        return hash
    }
}
