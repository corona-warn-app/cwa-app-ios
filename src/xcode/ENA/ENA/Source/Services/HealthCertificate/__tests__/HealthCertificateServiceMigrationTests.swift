//
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
@testable import ENA

class HealthCertificateServiceMigrationTests: XCTestCase {

	func testGIVEN_4_Persons_WHEN_registerHealthCertificate_THEN_Grouped_to_2_Persons() throws {
		// GIVEN
		let store = MockTestStore()
		let service = getService(store: store)
		
		// WHEN
		service.registerHealthCertificate(base45: try thomasCert01())
		service.registerHealthCertificate(base45: try thomasCert02())
		service.registerHealthCertificate(base45: try thomasCert03())
		service.registerHealthCertificate(base45: try ulrikeCert01())
		// THEN
		XCTAssertEqual(service.healthCertifiedPersons.count, 2)
	}
	
	// MARK: - Helpers

	private func getService(store: Store) -> HealthCertificateService {
		let client = ClientMock()
		return HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: CachedAppConfigurationMock(
				with: SAP_Internal_V2_ApplicationConfigurationIOS()
			),
			cclService: FakeCCLService(),
			recycleBin: RecycleBin(
				store: store
			)
		)
	}

	private func thomasCert01() throws -> Base45 {
		try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(
					standardizedFamilyName: "MEYER<SCHMIDT",
					standardizedGivenName: "THOMAS<ARMIN"
				),
				dateOfBirth: "1966-11-16",
				vaccinationEntries: [.fake()]
			)
		)
	}

	private func thomasCert02() throws -> Base45 {
		try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(
					standardizedFamilyName: "MEYER",
					standardizedGivenName: "THOMAS"
				),
				dateOfBirth: "1966-11-16",
				testEntries: [.fake()]
			)
		)
	}

	private func thomasCert03() throws -> Base45 {
		try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(
					standardizedFamilyName: "SCHMIDT",
					standardizedGivenName: "ARMIN"
				),
				dateOfBirth: "1966-11-16",
				recoveryEntries: [.fake()]
			)
		)
	}

	private func ulrikeCert01() throws -> Base45 {
		try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(
					standardizedFamilyName: "MEYER",
					standardizedGivenName: "ULRIKE"
				),
				dateOfBirth: "1967-04-23",
				vaccinationEntries: [.fake()]
			)
		)
	}

}
