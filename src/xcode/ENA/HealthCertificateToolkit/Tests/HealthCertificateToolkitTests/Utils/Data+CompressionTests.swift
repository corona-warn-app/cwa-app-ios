//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import HealthCertificateToolkit

class DataCompressionTests: XCTestCase {

    func test_CompressAndDecompress() throws {
        let data = try XCTUnwrap("HelloWorld".data(using: .utf8))

        let compressedData = data.compressZLib()
        let decompressedData = try compressedData.decompressZLib()

        XCTAssertEqual(data, decompressedData)
    }
}
