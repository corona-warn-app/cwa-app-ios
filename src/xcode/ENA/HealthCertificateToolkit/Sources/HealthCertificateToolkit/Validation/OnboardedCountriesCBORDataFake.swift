//
// 🦠 Corona-Warn-App
//

import Foundation
import SwiftCBOR

public var onboardedCountriesCBORDataFake: Data {
    let cborCountries = CBOR.array(
        [
            CBOR.utf8String("DE"),
            CBOR.utf8String("FR")
        ]
    )
    return Data(cborCountries.encode())
}

public var onboardedCountriesCorruptCBORDataFake: Data {
    let cborCountries = CBOR.array(
        [
            CBOR.null,
            CBOR.unsignedInt(42)
        ]
    )
    return Data(cborCountries.encode())
}
