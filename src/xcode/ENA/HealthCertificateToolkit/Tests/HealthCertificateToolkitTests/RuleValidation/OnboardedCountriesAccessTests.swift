//
// 🦠 Corona-Warn-App
//

import SwiftCBOR
import XCTest
@testable import HealthCertificateToolkit

class OnboardedCountriesAccessTests: XCTestCase {

    func test_AccessOnboardedCountries() throws {
       
        let cborData = onboardedCountriesCBORDataFake_DE_FR
        let result = OnboardedCountriesAccess().extractCountryCodes(from: cborData)

        guard case let .success(onboardedCountries) = result else {
            XCTFail("Success expected.")
            return
        }

        XCTAssertEqual(onboardedCountries, ["DE", "FR"])
    }
}
