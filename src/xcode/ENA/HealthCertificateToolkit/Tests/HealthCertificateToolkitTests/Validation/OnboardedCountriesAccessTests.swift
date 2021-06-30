//
// 🦠 Corona-Warn-App
//

import SwiftCBOR
import XCTest
@testable import HealthCertificateToolkit

class OnboardedCountriesAccessTests: XCTestCase {

    func test_AccessOnboardedCountries() throws {
        let cborCountries = CBOR.array(
            [
                CBOR.utf8String("DE"),
                CBOR.utf8String("IT"),
                CBOR.utf8String("FR")
            ]
        )
        let cborData = Data(cborCountries.encode())
        let result = OnboardedCountriesAccess().extractCountryCodes(from: cborData)

        guard case let .success(onboardedCountries) = result else {
            XCTFail("Success expected.")
            return
        }

        XCTAssertEqual(onboardedCountries, ["DE", "IT", "FR"])
    }
}
