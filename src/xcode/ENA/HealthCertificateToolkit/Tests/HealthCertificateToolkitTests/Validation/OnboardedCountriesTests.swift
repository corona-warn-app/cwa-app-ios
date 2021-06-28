//
// 🦠 Corona-Warn-App
//

import SwiftCBOR
import XCTest
@testable import HealthCertificateToolkit

class OnboardedCountriesTests: XCTestCase {

    func test_CreateOnboardedCountries() throws {
        let cborCountries = CBOR.array(
            [
                CBOR.utf8String("DE"),
                CBOR.utf8String("IT"),
                CBOR.utf8String("FR")
            ]
        )
        let cborData = Data(cborCountries.encode())
        let onboardedCountries = try OnboardedCountries(cborData: cborData)

        XCTAssertEqual(onboardedCountries.countryCodes, ["DE", "IT", "FR"])
    }
}
