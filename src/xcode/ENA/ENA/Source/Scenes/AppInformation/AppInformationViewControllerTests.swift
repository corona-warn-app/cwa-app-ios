//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA
import OpenCombine

class AppInformationViewControllerTests: XCTestCase {
	
	private var sut: AppInformationViewController!
	private var errorLogSubmissionProvidingMock: ErrorLogSubmissionProvidingMock!
	private var fakeCCSService: FakeCCLService!

    override func setUpWithError() throws {
		let store = MockTestStore()
		errorLogSubmissionProvidingMock = ErrorLogSubmissionProvidingMock()
		fakeCCSService = FakeCCLService()
        sut = AppInformationViewController(
			elsService: errorLogSubmissionProvidingMock,
			finishedDeltaOnboardings: store.finishedDeltaOnboardings,
			cclService: fakeCCSService
		)
    }

    override func tearDownWithError() throws {
		sut = nil
		errorLogSubmissionProvidingMock = nil
		fakeCCSService = nil
    }

    func testModel_WHEN_modelEntries_THEN_equalCategoryCount() throws {
		// WHEN
		let modelEntriesCount = sut.model.count

        // THEN
		XCTAssertEqual(modelEntriesCount, AppInformationViewController.Category.allCases.count)
    }
	
	func testHeightForRowAt_shouldShowAllCategories() {
		// GIVEN
		let mockCWAHibernationProvider = MockCWAHibernationProvider()
		mockCWAHibernationProvider.isHibernationStateToReturn = false
		let mockTestStore = MockTestStore()
		let sut = AppInformationViewController(
			elsService: errorLogSubmissionProvidingMock,
			finishedDeltaOnboardings: mockTestStore.finishedDeltaOnboardings,
			cclService: fakeCCSService,
			cwaHibernationProvider: mockCWAHibernationProvider
		)
		
		AppInformationViewController.Category.allCases.forEach { category in

			// WHEN
			let heightForRow = sut.tableView(
				sut.tableView,
				heightForRowAt: IndexPath(
					row: category.rawValue,
					section: 0
				)
			)

			// THEN
			switch category {
			case .about, .accessibility, .contact, .errorReport, .imprint, .legal, .privacy, .terms, .versionInfo:
				XCTAssertEqual(heightForRow, UITableView.automaticDimension)
			}
		}
	}
	
	func testHeightForRowAt_EOL_shouldHideSomeCategories() {
		// GIVEN
		let mockCWAHibernationProvider = MockCWAHibernationProvider()
		mockCWAHibernationProvider.isHibernationStateToReturn = true
		let mockTestStore = MockTestStore()
		let sut = AppInformationViewController(
			elsService: errorLogSubmissionProvidingMock,
			finishedDeltaOnboardings: mockTestStore.finishedDeltaOnboardings,
			cclService: fakeCCSService,
			cwaHibernationProvider: mockCWAHibernationProvider
		)
		
		AppInformationViewController.Category.allCases.forEach { category in

			// WHEN
			let heightForRow = sut.tableView(
				sut.tableView,
				heightForRowAt: IndexPath(
					row: category.rawValue,
					section: 0
				)
			)

			// THEN
			switch category {
			case .contact, .errorReport:
				XCTAssertEqual(heightForRow, 0)
			case .accessibility, .about, .imprint, .legal, .privacy, .terms, .versionInfo:
				XCTAssertEqual(heightForRow, UITableView.automaticDimension)
			}
		}
	}
}
