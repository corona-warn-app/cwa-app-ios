//
//  KeyTests.swift
//  ENATests
//
//  Created by Kienle, Christian on 07.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import XCTest
@testable import ENA

class KeyTests: XCTestCase {
    // This is a very basic sanity test just to make sure that encoding and decoding of keys
    // works. Currently this is needed by the developer menu in order to transfer keys from
    // device to device.
    func testKeyEncodeDecode() throws {
        var kIn = Sap_Key()
        kIn.keyData = Data(bytes: [1,2,3], count: 3)
        kIn.rollingPeriod = 1337
        kIn.rollingStartNumber = 42
        kIn.transmissionRiskLevel = 8

        let dataIn = try kIn.serializedData()
        let kOut = try Sap_Key(serializedData: dataIn)
        XCTAssertEqual(kOut.keyData, Data(bytes: [1,2,3], count: 3))
        XCTAssertEqual(kOut.rollingPeriod, 1337)
        XCTAssertEqual(kOut.rollingStartNumber, 42)
        XCTAssertEqual(kOut.transmissionRiskLevel, 8)
    }
}

