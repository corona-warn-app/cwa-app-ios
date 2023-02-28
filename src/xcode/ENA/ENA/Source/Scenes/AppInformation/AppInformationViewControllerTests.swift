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

	func testModel_WHEN_modelEntriesInHibernation_THEN_equalCount() throws {
		// WHEN
		let store = MockTestStore()
		store.hibernationComparisonDate = Calendar.current.date(byAdding: .day, value: 180, to: Date()) ?? Date()

		let sut = AppInformationViewController(
			elsService: errorLogSubmissionProvidingMock,
			finishedDeltaOnboardings: store.finishedDeltaOnboardings,
			cclService: fakeCCSService
		)

		// THEN
		XCTAssertEqual(sut.model.count, 7)
	}
	
    func testModel_WHEN_modelEntries_THEN_equalCategoryCount() throws {
		// WHEN
		let modelEntriesCount = sut.model.count

        // THEN
		XCTAssertEqual(modelEntriesCount, AppInformationViewController.Category.allCases.count)
    }
}
