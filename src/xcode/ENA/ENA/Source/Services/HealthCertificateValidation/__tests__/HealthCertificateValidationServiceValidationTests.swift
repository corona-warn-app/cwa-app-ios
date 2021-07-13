////
// 🦠 Corona-Warn-App
//

@testable import ENA
import HealthCertificateToolkit
import XCTest
import SwiftCBOR
import CertLogic
import OpenCombine
import ZIPFoundation

class HealthCertificateValidationServiceValidationTests: XCTestCase {

	func test_CertLogicEngineValidation() throws {
		guard let jsonData = certLogicTestData else {
			XCTFail("Could not load json data.")
			return
		}

		let testData = try JSONDecoder().decode(CertEngineTestData.self, from: jsonData)

		guard let valueSetsData = Data(base64Encoded: testData.general.valueSetProtocolBuffer),
			  let valueSets = try? SAP_Internal_Dgc_ValueSets(serializedData: valueSetsData) else {
			XCTFail("Could not load valueSets.")
			return
		}

		let valueSetsStub = ValueSetsStub()
		valueSetsStub.valueSets = valueSets

		for testCase in testData.testCases {
			let mockVerifier = MockVerifier()
			let mockStore = MockTestStore()
			let mockClient = ClientMock()

			guard let package = try? makeSAPDownloadedPackage(with: testCase.rules) else {
				XCTFail("Could not create package.")
				return
			}

			mockClient.onGetDCCRules = { _, _, completion in
				let package = PackageDownloadResponse(
					package: package,
					etag: ""
				)
				completion(.success(package))
			}

			let validationService = HealthCertificateValidationService(
				store: mockStore,
				client: mockClient,
				vaccinationValueSetsProvider: valueSetsStub,
				signatureVerifier: mockVerifier,
				validationRulesAccess: ValidationRulesAccess()
			)

			let certificate = try HealthCertificate(base45: testCase.dcc)

			validationService.validate(
				healthCertificate: certificate,
				arrivalCountry: testCase.countryOfArrival,
				validationClock: Date(timeIntervalSince1970: TimeInterval(testCase.validationClock))
			) { result in

				guard case let .success(validationReport) = result else {
					XCTFail("Success expected for validation result.")
					return
				}

				switch validationReport {
				case .validationFailed(let validatonResults),
					 .validationOpen(let validatonResults),
					 .validationPassed(let validatonResults):

					let passCount = validatonResults.filter { $0.result == .passed }.count
					let openCount = validatonResults.filter { $0.result == .open }.count
					let failCount = validatonResults.filter { $0.result == .fail }.count

					XCTAssertEqual(passCount, testCase.expPass, "CertEngineTestCase failed with incorrect expPass count: \(testCase.testCaseDescription)")
					XCTAssertEqual(openCount, testCase.expOpen, "CertEngineTestCase failed with incorrect expOpen count: \(testCase.testCaseDescription)")
					XCTAssertEqual(failCount, testCase.expFail, "CertEngineTestCase failed with incorrect expFail count: \(testCase.testCaseDescription)")
				}
			}
		}
	}

	private var certLogicTestData: Data? {
		let bundle = Bundle(for: HealthCertificateValidationServiceValidationTests.self)
		guard let url = bundle.url(forResource: "dcc-validation-rules-common-test-cases", withExtension: "json"),
			  let data = FileManager.default.contents(atPath: url.path) else {
			return nil
		}
		return data
	}

	private func makeSAPDownloadedPackage(with rules: [Rule]) throws -> SAPDownloadedPackage? {
		let cborRulesData = try CodableCBOREncoder().encode(rules)

		let archive = try XCTUnwrap(Archive(accessMode: .create))
		try archive.addEntry(with: "export.bin", type: .file, uncompressedSize: UInt32(cborRulesData.count), bufferSize: 4, provider: { position, size -> Data in
			return cborRulesData.subdata(in: position..<position + size)
		})
		try archive.addEntry(with: "export.sig", type: .file, uncompressedSize: 12, bufferSize: 4, provider: { position, size -> Data in
			return Data().subdata(in: position..<position + size)
		})
		let archiveData = archive.data ?? Data()
		return SAPDownloadedPackage(compressedData: archiveData)
	}
}

private class ValueSetsStub: VaccinationValueSetsProviding {
	var valueSets: SAP_Internal_Dgc_ValueSets!

	func latestVaccinationCertificateValueSets() -> AnyPublisher<SAP_Internal_Dgc_ValueSets, Error> {
		// return stubbed value sets; no error
		return Just(valueSets)
			.setFailureType(to: Error.self)
			.eraseToAnyPublisher()
	}
}
