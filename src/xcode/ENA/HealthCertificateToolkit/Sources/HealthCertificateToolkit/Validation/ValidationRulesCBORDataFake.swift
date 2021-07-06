//
// 🦠 Corona-Warn-App
//

import Foundation
import CertLogic
import SwiftCBOR

func rulesCBORDataFake() throws -> Data {
    let rules = [
        Rule.fake(),
        Rule.fake(),
        Rule.fake()
    ]

    return try CodableCBOREncoder().encode(rules)
}
