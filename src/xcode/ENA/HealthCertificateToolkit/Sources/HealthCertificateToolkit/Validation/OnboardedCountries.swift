//
// 🦠 Corona-Warn-App
//

import Foundation
import SwiftCBOR

struct OnboardedCountries {

    let countryCodes: [String]

    init(cborData: CBORData) throws {
        self.countryCodes = try CodableCBORDecoder().decode([String].self, from: cborData)
    }
}
