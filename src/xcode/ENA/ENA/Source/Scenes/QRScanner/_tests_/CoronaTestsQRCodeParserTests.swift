////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

// IMPORTANT: THESE TESTS ARE BASED ON THE CURRENT EXPECTED REGEX, WE NEED TO UPDATE THEM IF THE REGEX IS UPDATED
// swiftlint:disable:next type_body_length
class CoronaTestsQRCodeParserTests: CWATestCase {
    func testQRCodeExtraction_EmptyString() {
        let parser = CoronaTestsQRCodeParser()
        
        let result = parser.coronaTestQRCodeInformation(from: "")
        XCTAssertEqual(result, .failure(.scanningError(.codeNotFound)))
    }
    
    func testQRCodeExtraction_InputLengthExceeded() {
        let parser = CoronaTestsQRCodeParser()
        
        let result = parser.coronaTestQRCodeInformation(from: String(repeating: "x", count: 150))
        
        XCTAssertEqual(result, .failure(.scanningError(.codeNotFound)))
    }
    
    func testQRCodeExtraction_WrongURL() {
        let parser = CoronaTestsQRCodeParser()
        
        let result = parser.coronaTestQRCodeInformation(from: "https://wrong.app/?\(validPcrGuid)")
        
        XCTAssertEqual(result, .failure(.scanningError(.codeNotFound)))
    }
    
    func testQRCodeExtraction_someUTF8Text() {
        let parser = CoronaTestsQRCodeParser()
        
        let result = parser.coronaTestQRCodeInformation(from: "This is a Test ん鞠")
        
        XCTAssertEqual(result, .failure(.scanningError(.codeNotFound)))
    }
    
    func testQRCodeExtraction_MissingURL() {
        let parser = CoronaTestsQRCodeParser()
        
        let result = parser.coronaTestQRCodeInformation(from: "?\(validPcrGuid)")
        
        XCTAssertEqual(result, .failure(.scanningError(.codeNotFound)))
    }
    
    func testQRCodeExtraction_MissingQuestionMark() {
        let parser = CoronaTestsQRCodeParser()
        
        let result = parser.coronaTestQRCodeInformation(from: "https://localhost/\(validPcrGuid)")
        
        XCTAssertEqual(result, .failure(.scanningError(.codeNotFound)))
    }
    
    func testPcrQRCodeExtraction_AdditionalSpaceAfterQuestionMark() {
        let parser = CoronaTestsQRCodeParser()
        
        let result = parser.coronaTestQRCodeInformation(from: "? \(validPcrGuid)")
        
        XCTAssertEqual(result, .failure(.scanningError(.codeNotFound)))
    }
    
    func testPcrQRCodeExtraction_GUIDLengthExceeded() {
        let parser = CoronaTestsQRCodeParser()
        
        let result = parser.coronaTestQRCodeInformation(from: "https://localhost/?\(validPcrGuid)-BEEF")
        
        XCTAssertEqual(result, .failure(.scanningError(.codeNotFound)))
    }
    
    func testPcrQRCodeExtraction_GUIDTooShort() {
        let parser = CoronaTestsQRCodeParser()
        
        let result = parser.coronaTestQRCodeInformation(from: "https://localhost/?\(validPcrGuid.dropLast(4))")
        
        XCTAssertEqual(result, .failure(.scanningError(.codeNotFound)))
    }
    
    func testPcrQRCodeExtraction_GUIDStructureWrong() {
        let parser = CoronaTestsQRCodeParser()
        
        let wrongGuid = "3D6D-083567F3F2-4DCF-43A3-8737-4CD1F87D6FDA"
        let result = parser.coronaTestQRCodeInformation(from: "https://localhost/?\(wrongGuid)")
        
        XCTAssertEqual(result, .failure(.scanningError(.codeNotFound)))
    }
    
    func testPcrQRCodeExtraction_ValidWithUppercaseString() {
        let parser = CoronaTestsQRCodeParser()
        
        switch parser.coronaTestQRCodeInformation(from: "https://localhost/?\(validPcrGuid.uppercased())") {
        case let .success(testResult):
            switch  testResult {
            case .antigen:
                XCTFail("Expected PCR test")
            case .pcr(let result, _):
                XCTAssertEqual(result, validPcrGuid)
            case .teleTAN:
                XCTFail("Expected PCR test")
            case .rapidPCR:
                XCTFail("Expected PCR test")
            }
            
        case .failure:
            XCTFail("Result is nil")
        }
    }
    
    func testPcrQRCodeExtraction_ValidWithLowercaseString() {
        let parser = CoronaTestsQRCodeParser()
        
        switch parser.coronaTestQRCodeInformation(from: "https://localhost/?\(validPcrGuid.lowercased())") {
        case let .success(testResult):
            switch testResult {
            case .antigen:
                XCTFail("Expected PCR test")
            case .pcr(let result, _):
                XCTAssertEqual(result, validPcrGuid.lowercased())
            case .teleTAN:
                XCTFail("Expected PCR test")
            case .rapidPCR:
                XCTFail("Expected PCR test")
            }
            
        case .failure:
            XCTFail("Result is nil")
        }
    }
    
    func testPcrQRCodeExtraction_ValidWithMixedcaseString() {
        let parser = CoronaTestsQRCodeParser()
        
        let mixedCaseGuid = "3D6d08-3567F3f2-4DcF-43A3-8737-4CD1F87d6FDa"
        
        switch parser.coronaTestQRCodeInformation(from: "https://localhost/?\(mixedCaseGuid)") {
        case let .success(testResult):
            switch testResult {
            case .antigen:
                XCTFail("Expected PCR test")
            case .pcr(let result, _):
                XCTAssertEqual(result, mixedCaseGuid)
            case .teleTAN:
                XCTFail("Expected PCR test")
            case .rapidPCR:
                XCTFail("Expected PCR test")
            }
        case .failure:
            XCTFail("Result is nil")
        }
    }
    
    func testGIVEN_upperCasedHost_WHEN_extractGuid_THEN_isFound() {
        // GIVEN
        let parser = CoronaTestsQRCodeParser()
        
        // WHEN
        var result: CoronaTestRegistrationInformation!
        switch parser.coronaTestQRCodeInformation(from: "HTTPS://LOCALHOST/?\(validPcrGuid)") {
        case let .success(testResult):
            result = testResult
        case .failure:
            XCTFail("Result is nil")
        }
        
        // THEN
        XCTAssertNotNil(result)
    }
    
    func testGIVEN_invalidPath_WHEN_extractPcrGuid_THEN_isInvalid() {
        // GIVEN
        let parser = CoronaTestsQRCodeParser()
        
        // WHEN
        switch parser.coronaTestQRCodeInformation(from: "https://localhost//?A9652E-3BE0486D-0678-40A8-BEFD-07846B41993C") {
        case .success:
            XCTFail("Not expected to succeed")
        case let .failure(error):
            // THEN
            XCTAssertEqual(error, .scanningError(.codeNotFound))
        }
    }
    
    func testGIVEN_lowercasedURL_WHEN_extractGUID_THEN_isValidAndGuidMatch() {
        // GIVEN
        let parser = CoronaTestsQRCodeParser()
        
        // WHEN
        switch parser.coronaTestQRCodeInformation(from: "https://localhost/?123456-12345678-1234-4DA7-B166-B86D85475064") {
        case let .success(result):
            // THEN
            switch result {
            case .pcr(let guid, _):
                XCTAssertEqual("123456-12345678-1234-4DA7-B166-B86D85475064", guid)
            case .antigen:
                XCTFail("expected PCR test")
            case .teleTAN:
                XCTFail("expected PCR test")
            case .rapidPCR:
                XCTFail("Expected PCR test")
            }
        case .failure:
            XCTFail("Result is nil")
        }
    }
    
    func testGIVEN_uppercasedURL_WHEN_extractGUID_THEN_isValidAndGuidMatch() {
        // GIVEN
        let parser = CoronaTestsQRCodeParser()
        
        // WHEN
        switch parser.coronaTestQRCodeInformation(from: "HTTPS://LOCALHOST/?123456-12345678-1234-4DA7-B166-B86D85475064") {
        case let .success(result):
            // THEN
            switch result {
            case .pcr(let guid, _):
                XCTAssertEqual("123456-12345678-1234-4DA7-B166-B86D85475064", guid)
            case .antigen:
                XCTFail("expected PCR test")
            case .teleTAN:
                XCTFail("expected PCR test")
            case .rapidPCR:
                XCTFail("Expected PCR test")
            }
        case .failure:
            XCTFail("Result is nil")
        }
    }
    
    func testGIVEN_lowercasedURLWithDoublePathSlashes_WHEN_extractGUID_THEN_isInvalid() {
        // GIVEN
        let parser = CoronaTestsQRCodeParser()
        
        // WHEN
        let guid = parser.coronaTestQRCodeInformation(from: "https://localhost//?123456-12345678-1234-4DA7-B166-B86D85475064")
        
        // THEN
        XCTAssertEqual(guid, .failure(.scanningError(.codeNotFound)))
    }
    
    func testGIVEN_lowercasedURLWithTripplePathSlashes_WHEN_extractGUID_THEN_isInvalid() {
        // GIVEN
        let parser = CoronaTestsQRCodeParser()
        
        // WHEN
        let guid = parser.coronaTestQRCodeInformation(from: "https://localhost///?123456-12345678-1234-4DA7-B166-B86D85475064")
        
        // THEN
        XCTAssertEqual(guid, .failure(.scanningError(.codeNotFound)))
    }
    
    func testGIVEN_uppercasedURLWithDoublePathSlashes_WHEN_extractGUID_THEN_isInvalid() {
        // GIVEN
        let parser = CoronaTestsQRCodeParser()
        
        // WHEN
        let guid = parser.coronaTestQRCodeInformation(from: "HTTPS://LOCALHOST///?123456-12345678-1234-4DA7-B166-B86D85475064")
        
        // THEN
        XCTAssertEqual(guid, .failure(.scanningError(.codeNotFound)))
    }
    
    func testGIVEN_lowercasedURLUppercaseGuid_WHEN_extractGUID_THEN_isValidAndGuidMatch() {
        // GIVEN
        let parser = CoronaTestsQRCodeParser()
        
        // WHEN
        switch parser.coronaTestQRCodeInformation(from: "https://localhost/?123456-12345678-1234-4DA7-B166-B86D85475ABC") {
        case let .success(result):
            // THEN
            switch result {
            case .pcr(let guid, _):
                XCTAssertEqual("123456-12345678-1234-4DA7-B166-B86D85475ABC", guid)
            case .antigen:
                XCTFail("expected PCR test")
            case .teleTAN:
                XCTFail("expected PCR test")
            case .rapidPCR:
                XCTFail("Expected PCR test")
            }
        case .failure:
            XCTFail("Result is nil")
        }
        
    }
    
    func testGIVEN_lowercasedURLMixedGuid_WHEN_extractGUID_THEN_isValidAndGuidMatch() {
        // GIVEN
        let parser = CoronaTestsQRCodeParser()
        
        // WHEN
        switch parser.coronaTestQRCodeInformation(from: "https://localhost/?123456-12345678-1234-4DA7-B166-B86D85475abc") {
        case let .success(result):
            // THEN
            switch result {
            case .pcr(let guid, _):
                XCTAssertEqual("123456-12345678-1234-4DA7-B166-B86D85475abc", guid)
            case .antigen:
                XCTFail("expected PCR test")
            case .teleTAN:
                XCTFail("expected PCR test")
            case .rapidPCR:
                XCTFail("Expected PCR test")
            }
        case .failure:
            XCTFail("Result is nil")
        }
        
    }
    
    func testGIVEN_uppercasedUrlUppercasedGuid_WHEN_extractGUID_THEN_isValidAndGuidMatch() {
        // GIVEN
        let parser = CoronaTestsQRCodeParser()
        
        // WHEN
        switch parser.coronaTestQRCodeInformation(from: "HTTPS://LOCALHOST/?123456-12345678-1234-4DA7-B166-B86D85475ABC") {
        case let .success(result):
            // THEN
            switch result {
            case .pcr(let guid, _):
                XCTAssertEqual("123456-12345678-1234-4DA7-B166-B86D85475ABC", guid)
            case .antigen:
                XCTFail("expected PCR test")
            case .teleTAN:
                XCTFail("expected PCR test")
            case .rapidPCR:
                XCTFail("Expected PCR test")
            }
        case .failure:
            XCTFail("Result is nil")
        }
        
    }
    
    func testGIVEN_uppercasedUrlMixedcaseGuid_WHEN_extractGUID_THEN_isValidAndGuidMatch() {
        // GIVEN
        let parser = CoronaTestsQRCodeParser()
        
        // WHEN
        switch parser.coronaTestQRCodeInformation(from: "HTTPS://LOCALHOST/?123456-12345678-1234-4DA7-B166-B86D85475abc") {
        case let .success(result):
            // THEN
            switch result {
            case .pcr(let guid, _):
                XCTAssertEqual("123456-12345678-1234-4DA7-B166-B86D85475abc", guid)
            case .antigen:
                XCTFail("expected PCR test")
            case .teleTAN:
                XCTFail("expected PCR test")
            case .rapidPCR:
                XCTFail("Expected PCR test")
            }
            
        case .failure:
            XCTFail("Result is nil")
        }
    }
    
    func testGIVEN_missingGuid_WHEN_extractGUID_THEN_isValidGUIDMatches() {
        // GIVEN
        let parser = CoronaTestsQRCodeParser()
        
        // WHEN
        let guid = parser.coronaTestQRCodeInformation(from: "https://localhost/?")
        
        // THEN
        XCTAssertEqual(guid, .failure(.scanningError(.codeNotFound)))
    }
    
    func testGIVEN_percentescapedSpaceinURL_WHEN_extractGUID_THEN_isValidGUIDMatches() {
        // GIVEN
        let parser = CoronaTestsQRCodeParser()
        
        // WHEN
        let guid = parser.coronaTestQRCodeInformation(from: "https://localhost/%20?3D6D08-3567F3F2-4DCF-43A3-8737-4CD1F87D6FDA")
        
        // THEN
        XCTAssertEqual(guid, .failure(.scanningError(.codeNotFound)))
    }
    
    func testGIVEN_otherHost_WHEN_extractGUID_THEN_isINvalid() {
        // GIVEN
        let parser = CoronaTestsQRCodeParser()
        
        // WHEN
        let guid = parser.coronaTestQRCodeInformation(from: "https://some-host.com/?3D6D08-3567F3F2-4DCF-43A3-8737-4CD1F87D6FDA")
        
        // THEN
        XCTAssertEqual(guid, .failure(.scanningError(.codeNotFound)))
    }
    
    func testGIVEN_httpSchemeURL_WHEN_extractGUID_THEN_isInvalid() {
        // GIVEN
        let parser = CoronaTestsQRCodeParser()
        
        // WHEN
        let guid = parser.coronaTestQRCodeInformation(from: "http://localhost/?123456-12345678-1234-4DA7-B166-B86D85475064")
        
        // THEN
        XCTAssertEqual(guid, .failure(.scanningError(.codeNotFound)))
    }
    
    func testGIVEN_urlWithWrongFormattedGuid_WHEN_extractGUID_THEN_isInvalid() {
        // GIVEN
        let parser = CoronaTestsQRCodeParser()
        
        // WHEN
        let guid = parser.coronaTestQRCodeInformation(from: "https://localhost/?3567F3F2-4DCF-43A3-8737-4CD1F87D6FDA")
        
        // THEN
        XCTAssertEqual(guid, .failure(.scanningError(.codeNotFound)))
    }
    
    func testGIVEN_urlWithToShortInvalidGUID_WHEN_extractGUID_THEN_isInvalid() {
        // GIVEN
        let parser = CoronaTestsQRCodeParser()
        
        // WHEN
        let guid = parser.coronaTestQRCodeInformation(from: "https://localhost/?https://localhost/?4CD1F87D6FDA")
        
        // THEN
        XCTAssertEqual(guid, .failure(.scanningError(.codeNotFound)))
    }
    
    func testGIVEN_wwwLocalhostURL_WHEN_extractGUID_THEN_isInvalid() {
        // GIVEN
        let parser = CoronaTestsQRCodeParser()
        
        // WHEN
        let guid = parser.coronaTestQRCodeInformation(from: "https://www.localhost/%20?3D6D08-3567F3F2-4DCF-43A3-8737-4CD1F87D6FDA")
        
        // THEN
        XCTAssertEqual(guid, .failure(.scanningError(.codeNotFound)))
    }
    
    func testGIVEN_invalidPath_WHEN_extractRapidPayload_THEN_isInvalid() {
        // GIVEN
        let parser = CoronaTestsQRCodeParser()
        
        // WHEN
        let result = parser.coronaTestQRCodeInformation(from: "https://s.coronawarn.app/?v=1#//?eyJ0aW1lc3RhbXAiOjE2MTgyMzM5NzksImd1aWQiOiIwQzg5MjItMEM4OTIyNjMtQTM0Qy00RjM1LTg5QUMtMTcyMzlBMzQ2QUZEIiwiZm4iOiJDYW1lcm9uIiwibG4iOiJIdWRzb24iLCJkb2IiOiIxOTkyLTA4LTA3In0")
        
        // THEN
        XCTAssertEqual(result, .failure(.invalidError(.invalidTestCode(.invalidPayload))))
    }
    
    func testRapid_hashIsTooShort() {
        let invalidHash = "f1200d9650f1fd673d58f52811f98f1427fab40b4996e9c2d0da8b741446408"
        let antigenTestInformation = RapidTestQRCodeInformation.mock(hash: invalidHash)
        
        do {
            let payloadData = try JSONEncoder().encode(antigenTestInformation)
            let payloadString = payloadData.base64EncodedString()
            let url = "https://s.coronawarn.app/?v=1#\(payloadString)"
            let route = Route(url)
            XCTAssertEqual(route, Route.rapidAntigen( .failure(.invalidTestCode(.invalidHash))), "incorrect hash should trigger an error")
        } catch {
            XCTFail("Caught an error while trying to encode the Antigen test")
        }
    }
    
    func testAntigen_hashIsNotHex() {
        let invalidHash = "f1200d9650f1fd673d58f52811f98f1427fab40b4996e9c2d0da8b741446408G"
        let antigenTestInformation = RapidTestQRCodeInformation.mock(hash: invalidHash)
        
        do {
            let payloadData = try JSONEncoder().encode(antigenTestInformation)
            let payloadString = payloadData.base64EncodedString()
            let url = "https://s.coronawarn.app/?v=1#\(payloadString)"
            let route = Route(url)
            XCTAssertEqual(route, Route.rapidAntigen( .failure(.invalidTestCode(.invalidHash))), "incorrect hash should trigger an error")
        } catch {
            XCTFail("Caught an error while trying to encode the Antigen test")
        }
    }
    
    func testAntigen_InvalidTestedPersonInformation() {
        let antigenTestInformation = RapidTestQRCodeInformation.mock(
            hash: "584b5177c687f2a007778b2f1d2365770ca318b0a8cda0593f691c0d17d18d01",
            timestamp: 5,
            firstName: "Jon",
            lastName: nil,
            cryptographicSalt: "C520E70759CC69B28CAA219A8B57DAB4",
            testID: "40352cb5-e44b-409b-b4c9-2d8aac60f805",
            dateOfBirth: Date(timeIntervalSince1970: 1619618081)
        )
        do {
            let payloadData = try JSONEncoder().encode(antigenTestInformation)
            let payloadString = payloadData.base64EncodedString()
            let url = "https://s.coronawarn.app/?v=1#\(payloadString)"
            let route = Route(url)
            XCTAssertEqual(route, Route.rapidAntigen( .failure(.invalidTestCode(.invalidTestedPersonInformation))), "incorrect Personal info Hash should trigger an error")
        } catch {
            XCTFail("Caught an error while trying to encode the Antigen test")
        }
    }
    
    func testAntigen_InvalidTimeStamp() {
        let antigenTestInformation = RapidTestQRCodeInformation.mock(
            hash: "584b5177c687f2a007778b2f1d2365770ca318b0a8cda0593f691c0d17d18d01",
            timestamp: -5,
            firstName: "Jon",
            lastName: "Bird",
            cryptographicSalt: "C520E70759CC69B28CAA219A8B57DAB4",
            testID: "40352cb5-e44b-409b-b4c9-2d8aac60f805",
            dateOfBirth: Date(timeIntervalSince1970: 1619618081)
        )
        do {
            let payloadData = try JSONEncoder().encode(antigenTestInformation)
            let payloadString = payloadData.base64EncodedString()
            let url = "https://s.coronawarn.app/?v=1#\(payloadString)"
            let route = Route(url)
            XCTAssertEqual(route, Route.rapidAntigen( .failure(.invalidTestCode(.invalidTimeStamp))), "incorrect TimeStamp should trigger an error")
        } catch {
            XCTFail("Caught an error while trying to encode the Antigen test")
        }
    }
    
    func testAntigen_HashMismatch() {
        let antigenTestInformation = RapidTestQRCodeInformation.mock(
            hash: "584b5177c687f2a007778b2f1d2365770ca318b0a8cda0593f691c0d17d18d01",
            timestamp: 5,
            firstName: "Jon",
            lastName: "Bird",
            cryptographicSalt: "C520E70759CC69B28CAA219A8B57DAB4",
            testID: "40352cb5-e44b-409b-b4c9-2d8aac60f805",
            dateOfBirth: Date(timeIntervalSince1970: 1619618081)
        )
        do {
			let payloadData = try JSONEncoder().encode(antigenTestInformation)
            let payloadString = payloadData.base64EncodedString()
            let url = "https://s.coronawarn.app/?v=1#\(payloadString)"
            let route = Route(url)
            XCTAssertEqual(route, Route.rapidAntigen( .failure(.invalidTestCode(.hashMismatch))), "incorrect recalculated Hash should trigger an error")
        } catch {
            XCTFail("Caught an error while trying to encode the Antigen test")
        }
    }
    
    // MARK: - Private
    
    private let validPcrGuid = "3D6D08-3567F3F2-4DCF-43A3-8737-4CD1F87D6FDA"
    
    private func validAntigenHash(validPayload: String) -> String? {
        let jsonData: Data
        if validPayload.isBase64Encoded {
            guard let parsedData = Data(base64Encoded: validPayload) else {
                return nil
            }
            jsonData = parsedData
        } else {
            guard let parsedData = Data(base64URLEncoded: validPayload) else {
                return nil
            }
            jsonData = parsedData
        }
        do {
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .custom({ decoder -> Date in
                let container = try decoder.singleValueContainer()
                let stringDate = try container.decode(String.self)
                guard let date = ISO8601DateFormatter.justUTCDateFormatter.date(from: stringDate) else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "failed to decode date \(stringDate)")
                }
                return date
            })
            
            let testInformation = try jsonDecoder.decode(RapidTestQRCodeInformation.self, from: jsonData)
            return testInformation.hash
        } catch {
            Log.debug("Failed to read / parse district json", log: .ppac)
            return nil
        }
    }
    
}
