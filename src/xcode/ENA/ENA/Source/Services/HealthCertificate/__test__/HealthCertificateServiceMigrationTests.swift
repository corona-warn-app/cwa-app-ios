//
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
@testable import ENA

class HealthCertificateServiceMigrationTests: XCTestCase {
	// swiftlint:disable line_length

	// two certificates for the same person spelling issue included
	let cert01 = "HC1:6BF080290T9WJWG.FKY*4GO0DY7877D:S692FBB2G2*70HS8FN0YOCV%LWY03ECWFFD97TK0F90KECTHGWJC0FDQ%5AIA%G7X+AQB9746HS80:5%IBPB8646$A8ZS8DA6%%6JIA209BNAFH8JA6C69RM8QBAZ69UPC1JCWY8FVC*70LVC6JD846Y96F465W5.A6+EDXVET3E5$CSUE6O9NPCSW5F/DBWENWE4WEB$D% D3IA4W5646646/96OA7.JCP9EJY8L/5M/5 96.96WF63KC.SC4KCD3DX47B46IL6646H*6Z/E5JD%96IA7B46646WX6GVC*JC1A6LA74W5Y96/96TPCBEC7ZKW.CD CC$C5$C JC9/D8UA+3EHECY24EC8J$D:.DW.C7WEQY9%CBVIAI3DFWELTA61ASB8UR7RB8UY9.+9O/EZKEZ967L6156Q88TLCW7C3779%V6EDCS79TB%R7WNK::IJYSU1N%ZD.CO%387TGI/GV5KP%5N*R.GQL0HV/4%CS%MN$/J9$VSD5+IOFXAXUPQF1Q:FD3"

	let cert02 = "HC1:6BF/70490T9WJWG.FKY*4GO0DY7877D:S692FBBU42*70HS8FN0YOCH*LWY03ECIGFD97TK0F90KECTHGWJC0FDQ%5AIA%G7X+AQB9746HS80:5%IBPB8646$A82B7+*8JG671A71AE*8O1BNH9N+9$YARQ652BUPC1JCWY8FVCPD0LVC6JD846Y96F465W5SG6+EDXVET3E5$CSUE6O9NPCSW5F/DBWENWE4WEB$D% D3IA4W5646646/96OA7.JCP9EJY8L/5M/5 96.96WF63KC.SC4KCD3DX47B46IL6646H*6Z/E5JD%96IA7B46646WX6GVC*JC1A6LA74W5Y96/96TPCBEC7ZKW.CD CC$C5$C JC8/D8UA+3EHECM34/KEZEDLPCG/DD CNY8GY8MPCG/DCVDG69MY9NNARB8UY9.+9O/EZKEZ967L61569687*7:600L5LBFGNE+UI O98OB3RI4U7/RSO49F/2PJRE+P1ICS7HT0U2.0W103VTDHM.COB%JXYTF0UU5R6OD9WG:R3KGSO%B3YSN1"

	// make sure grouping works as expected
	func testGIVEN_ServiceWithEmptyStore_WHEN_RegisterTwoCertificatesWithDifferentSpelling_THEN_OnePersonIsCreated() {
		// GIVEN
		let store = MockTestStore()
		let service = getService(store: store)

		// WHEN
		service.registerHealthCertificate(base45: cert01)
		service.registerHealthCertificate(base45: cert02)

		// THEN
		XCTAssertEqual(service.healthCertifiedPersons.count, 1)
	}

	// without migration no grouping will apply
	func testGIVEN_ServiceWithCertificatesInStore_WHEN_ServiceWithNoMigration_THEN_TwoHealthCertifiedPersons() throws {
		// GIVEN
		let cert01 = try HealthCertificate(base45: cert01)
		let cert02 = try HealthCertificate(base45: cert02)
		let person01 = HealthCertifiedPerson(healthCertificates: [cert01])
		let person02 = HealthCertifiedPerson(healthCertificates: [cert02])
		let store = MockTestStore()
		store.healthCertifiedPersons = [person01, person02]

		// WHEN
		let service = getService(store: store)

		// THEN
		XCTAssertEqual(service.healthCertifiedPersons.count, 2)
	}

	// with migration grouping will apply
	func testGIVEN_ServiceWithCertificatesInStore_WHEN_ServiceWithMigration_THEN_OneHealthCertifiedPersons() throws {
		// GIVEN
		let cert01 = try HealthCertificate(base45: cert01)
		let cert02 = try HealthCertificate(base45: cert02)
		let person01 = HealthCertifiedPerson(healthCertificates: [cert01])
		let person02 = HealthCertifiedPerson(healthCertificates: [cert02])
		let store = MockTestStore(healthCertifiedPersonsVersion: nil) // fake old version
		store.healthCertifiedPersons = [person01, person02]

		// WHEN
		let service = getService(store: store)

		// THEN
		XCTAssertEqual(service.healthCertifiedPersons.count, 1)
	}

	// MARK: - Helpers

	func getService(store: Store) -> HealthCertificateService {
		let client = ClientMock()
		return HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: CachedAppConfigurationMock(
				with: SAP_Internal_V2_ApplicationConfigurationIOS()
			),
			boosterNotificationsService: BoosterNotificationsService(
				rulesDownloadService: RulesDownloadService(store: store, client: client)
			),
			recycleBin: RecycleBin(
				store: store
			)
		)
	}

}
