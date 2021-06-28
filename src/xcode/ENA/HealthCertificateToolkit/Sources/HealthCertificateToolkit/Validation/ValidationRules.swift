//
// 🦠 Corona-Warn-App
//

import Foundation
import SwiftCBOR
import CertLogic

struct ValidationRules {

    let rules: [Rule]

    init(cborData: CBORData) throws {
        self.rules = try CodableCBORDecoder().decode([Rule].self, from: cborData)
    }
}
