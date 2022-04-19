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

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: recycleBin
		)

		let service = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: recycleBin,
			badgeWrapper: .fake()
		)

		let restorationHandler = UserCoronaTestRestorationHandler(service: service)

		if case .success = restorationHandler.canRestore(.pcr(.mock())) { } else {
			XCTFail("canRestore should return success for .pcr")
		}

		if case .success = restorationHandler.canRestore(.antigen(.mock())) {} else {
			XCTFail("canRestore should return success for .antigen")
		}

		service.pcrTest.value = .mock(registrationToken: "pcrRegistrationToken")

		if case .failure(.testTypeAlreadyRegistered) = restorationHandler.canRestore(.pcr(.mock())) { } else {
			XCTFail("canRestore should return failure for .pcr")
		}

		if case .success = restorationHandler.canRestore(.antigen(.mock())) {} else {
			XCTFail("canRestore should return success for .antigen")
		}

		service.antigenTest.value = .mock(registrationToken: "antigenRegistrationToken")

		if case .failure(.testTypeAlreadyRegistered) = restorationHandler.canRestore(.pcr(.mock())) { } else {
			XCTFail("canRestore should return failure for .pcr")
		}

		if case .failure(.testTypeAlreadyRegistered) = restorationHandler.canRestore(.antigen(.mock())) {} else {
			XCTFail("canRestore should return failure for .antigen")
		}

		service.pcrTest.value = nil

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

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: recycleBin
		)

		let service = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: recycleBin,
			badgeWrapper: .fake()
		)

		let restorationHandler = UserCoronaTestRestorationHandler(service: service)

		let activeTest: UserPCRTest = .mock(registrationToken: "activeTest")

		service.pcrTest.value = activeTest

		let testToRestore: UserPCRTest = .mock(registrationToken: "testToRestore")

		restorationHandler.restore(.pcr(testToRestore))

		XCTAssertEqual(service.pcrTest.value, testToRestore)

		guard case let .userCoronaTest(coronaTest) = store.recycleBinItems.first?.item, case let .pcr(pcrTest) = coronaTest else {
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

		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			appConfiguration: appConfiguration,
			cclService: FakeCCLService(),
			recycleBin: recycleBin
		)

		let service = CoronaTestService(
			client: client,
			store: store,
			eventStore: MockEventStore(),
			diaryStore: MockDiaryStore(),
			appConfiguration: appConfiguration,
			healthCertificateService: healthCertificateService,
			healthCertificateRequestService: HealthCertificateRequestService(
				store: store,
				client: client,
				appConfiguration: appConfiguration,
				healthCertificateService: healthCertificateService
			),
			recycleBin: recycleBin,
			badgeWrapper: .fake()
		)

		let restorationHandler = UserCoronaTestRestorationHandler(service: service)

		let activeTest: UserAntigenTest = .mock(registrationToken: "activeTest")

		service.antigenTest.value = activeTest

		let testToRestore: UserAntigenTest = .mock(registrationToken: "testToRestore")

		restorationHandler.restore(.antigen(testToRestore))

		XCTAssertEqual(service.antigenTest.value, testToRestore)

		guard case let .userCoronaTest(coronaTest) = store.recycleBinItems.first?.item, case let .antigen(antigenTest) = coronaTest else {
			XCTFail("Cannot find replaced test in recycle bin")
			return
		}

		XCTAssertEqual(antigenTest, activeTest)
	}
	
}
