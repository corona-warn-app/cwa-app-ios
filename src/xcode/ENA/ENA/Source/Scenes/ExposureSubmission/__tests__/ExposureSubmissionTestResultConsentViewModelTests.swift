//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
import HealthCertificateToolkit
@testable import ENA

class ExposureSubmissionTestResultConsentViewModelTests: CWATestCase {

	func testCellsInSection0() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let viewModel = ExposureSubmissionTestResultConsentViewModel(
			supportedCountries: [],
			coronaTestType: .pcr,
			coronaTestService: CoronaTestService(
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
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: RulesDownloadService(store: store, client: client)
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			testResultAvailability: .availableAndPositive,
			dismissCompletion: nil
		)

		let section = viewModel.dynamicTableViewModel.section(0)
		let cells = section.cells
		XCTAssertEqual(cells.count, 4)
		
		let firstItem = cells[0]
		var id = firstItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "labelCell")
		
		let secondItem = cells[1]
		id = secondItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "labelCell")
		
		let fourthItem = cells[2]
		id = fourthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "ConsentCellReuseIdentifier")
		
		let fifthItem = cells[3]
		id = fifthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "spaceCell")
		
	}
	
	func testCellsInSection1() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let viewModel = ExposureSubmissionTestResultConsentViewModel(
			supportedCountries: [],
			coronaTestType: .pcr,
			coronaTestService: CoronaTestService(
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
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: RulesDownloadService(store: store, client: client)
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			testResultAvailability: .availableAndPositive,
			dismissCompletion: nil
		)
		
		let section = viewModel.dynamicTableViewModel.section(1)
		let cells = section.cells
		XCTAssertEqual(cells.count, 1)
		
		let firstItem = cells[0]
		let id = firstItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "iconCell")
		
	}
	
	func testCellsInSection2() {
		let client = ClientMock()
		let store = MockTestStore()
		let appConfiguration = CachedAppConfigurationMock()

		let viewModel = ExposureSubmissionTestResultConsentViewModel(
			supportedCountries: [],
			coronaTestType: .pcr,
			coronaTestService: CoronaTestService(
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
					boosterNotificationsService: BoosterNotificationsService(
						rulesDownloadService: RulesDownloadService(store: store, client: client)
					),
					recycleBin: .fake()
				),
				recycleBin: .fake(),
				badgeWrapper: .fake()
			),
			testResultAvailability: .availableAndPositive,
			dismissCompletion: nil
		)
		
		let section = viewModel.dynamicTableViewModel.section(2)
		let cells = section.cells
		XCTAssertEqual(cells.count, 1)
		
		let firstItem = cells[0]
		let id = firstItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "spaceCell")

	}
	
}
