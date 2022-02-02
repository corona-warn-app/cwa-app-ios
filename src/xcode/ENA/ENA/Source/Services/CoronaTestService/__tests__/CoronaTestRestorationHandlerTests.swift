//
// 🦠 Corona-Warn-App
//

@testable import ENA
import ExposureNotification
import HealthCertificateToolkit
import XCTest

class CoronaTestRestorationHandlerTests: CWATestCase {

	func testCanRestore() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()
		let recycleBin = RecycleBin(store: store)

		let service = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				cclService: FakeCCLService(),
				recycleBin: recycleBin
			),
			recycleBin: recycleBin,
			badgeWrapper: .fake()
		)

		let restorationHandler = CoronaTestRestorationHandler(service: service)

		if case .success = restorationHandler.canRestore(.pcr(.mock())) { } else {
			XCTFail("canRestore should return success for .pcr")
		}

		if case .success = restorationHandler.canRestore(.antigen(.mock())) {} else {
			XCTFail("canRestore should return success for .antigen")
		}

		service.pcrTest = PCRTest.mock(registrationToken: "pcrRegistrationToken")

		if case .failure(.testTypeAlreadyRegistered) = restorationHandler.canRestore(.pcr(.mock())) { } else {
			XCTFail("canRestore should return failure for .pcr")
		}

		if case .success = restorationHandler.canRestore(.antigen(.mock())) {} else {
			XCTFail("canRestore should return success for .antigen")
		}

		service.antigenTest = AntigenTest.mock(registrationToken: "antigenRegistrationToken")

		if case .failure(.testTypeAlreadyRegistered) = restorationHandler.canRestore(.pcr(.mock())) { } else {
			XCTFail("canRestore should return failure for .pcr")
		}

		if case .failure(.testTypeAlreadyRegistered) = restorationHandler.canRestore(.antigen(.mock())) {} else {
			XCTFail("canRestore should return failure for .antigen")
		}

		service.pcrTest = nil

		if case .success = restorationHandler.canRestore(.pcr(.mock())) { } else {
			XCTFail("canRestore should return success for .pcr")
		}

		if case .failure(.testTypeAlreadyRegistered) = restorationHandler.canRestore(.antigen(.mock())) {} else {
			XCTFail("canRestore should return failure for .antigen")
		}
	}

	func testRestoringPCRTest() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()
		let recycleBin = RecycleBin(store: store)

		let service = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				cclService: FakeCCLService(),
				recycleBin: recycleBin
			),
			recycleBin: recycleBin,
			badgeWrapper: .fake()
		)

		let restorationHandler = CoronaTestRestorationHandler(service: service)

		let activeTest = PCRTest.mock(registrationToken: "activeTest")

		service.pcrTest = activeTest

		let testToRestore = PCRTest.mock(registrationToken: "testToRestore")

		restorationHandler.restore(.pcr(testToRestore))

		XCTAssertEqual(service.pcrTest, testToRestore)

		guard case let .coronaTest(coronaTest) = store.recycleBinItems.first?.item, case let .pcr(pcrTest) = coronaTest else {
			XCTFail("Cannot find replaced test in recycle bin")
			return
		}

		XCTAssertEqual(pcrTest, activeTest)
	}

	func testRestoringAntigenTest() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()
		let recycleBin = RecycleBin(store: store)

		let service = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: HealthCertificateService(
				store: store,
				dccSignatureVerifier: DCCSignatureVerifyingStub(),
				dscListProvider: MockDSCListProvider(),
				client: client,
				appConfiguration: appConfiguration,
				cclService: FakeCCLService(),
				recycleBin: recycleBin
			),
			recycleBin: recycleBin,
			badgeWrapper: .fake()
		)

		let restorationHandler = CoronaTestRestorationHandler(service: service)

		let activeTest = AntigenTest.mock(registrationToken: "activeTest")

		service.antigenTest = activeTest

		let testToRestore = AntigenTest.mock(registrationToken: "testToRestore")

		restorationHandler.restore(.antigen(testToRestore))

		XCTAssertEqual(service.antigenTest, testToRestore)

		guard case let .coronaTest(coronaTest) = store.recycleBinItems.first?.item, case let .antigen(antigenTest) = coronaTest else {
			XCTFail("Cannot find replaced test in recycle bin")
			return
		}

		XCTAssertEqual(antigenTest, activeTest)
	}
	
}
