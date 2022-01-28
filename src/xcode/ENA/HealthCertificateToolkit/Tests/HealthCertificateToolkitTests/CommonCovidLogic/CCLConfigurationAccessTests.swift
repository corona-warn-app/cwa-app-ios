//
// 🦠 Corona-Warn-App
//

import XCTest
import SwiftCBOR
@testable import HealthCertificateToolkit

class CCLConfigurationAccessTests: XCTestCase {
    
    func test_ExtractConfigurations() throws {
        let cborData = try configurationsCBORDataFake()
        let result = CCLConfigurationAccess().extractCCLConfiguration(from: cborData)

        guard case let .success(configurations) = result else {
            XCTFail("Success expected.")
            return
        }

        XCTAssertEqual(configurations.count, 3)
    }
}

public func configurationsCBORDataFake() throws -> CBORData {
    let configurations = [
        CCLConfiguration.fake(),
        CCLConfiguration.fake(),
        CCLConfiguration.fake()
    ]

    return try CodableCBOREncoder().encode(configurations)
}
