//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA
import OpenCombine

class AppInformationViewControllerTests: XCTestCase {
	
	private var sut: AppInformationViewController!
	private var errorLogSubmissionProvidingMock: ErrorLogSubmissionProvidingMock!
	private var cclServableMock: CCLServableMock!

    override func setUpWithError() throws {
		errorLogSubmissionProvidingMock = ErrorLogSubmissionProvidingMock()
		cclServableMock = CCLServableMock()
        sut = AppInformationViewController(
			elsService: errorLogSubmissionProvidingMock,
			cclService: cclServableMock
		)
    }

    override func tearDownWithError() throws {
		sut = nil
		errorLogSubmissionProvidingMock = nil
		cclServableMock = nil
    }

    func testModel_WHEN_modelEntries_THEN_equalCategoryCount() throws {
		// WHEN
		let modelEntriesCount = sut.model.count

        // THEN
		XCTAssertEqual(modelEntriesCount, AppInformationViewController.Category.allCases.count)
    }
}
