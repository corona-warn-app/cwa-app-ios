//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class NotificationSettingsViewModelTests: CWATestCase {
	
	func testGIVEN_ViewModel_WHEN_NotificationsOn_THEN_CorrectNumberOfCells() {
		
		// GIVEN
		
		let viewModel = NotificationSettingsViewModel()
		
		// WHEN
		
		let numberOfSections = viewModel.dynamicTableViewModelNotificationOn.numberOfSection
		let numberOfRowsInSection0 = viewModel.dynamicTableViewModelNotificationOn.numberOfRows(section: 0)
		let numberOfRowsInSection1 = viewModel.dynamicTableViewModelNotificationOn.numberOfRows(section: 1)
		let numberOfRowsInSection2 = viewModel.dynamicTableViewModelNotificationOn.numberOfRows(section: 2)
		
		// THEN
		
		XCTAssertEqual(numberOfSections, 3)
		XCTAssertEqual(numberOfRowsInSection0, 1)
		XCTAssertEqual(numberOfRowsInSection1, 2)
		XCTAssertEqual(numberOfRowsInSection2, 11)
	}
	
	func testGIVEN_ViewModel_WHEN_NotificationsOff_THEN_CorrectNumberOfCells() {
		
		// GIVEN
		
		let viewModel = NotificationSettingsViewModel()
		
		// WHEN
		
		let numberOfSections = viewModel.dynamicTableViewModelNotificationOff.numberOfSection
		let numberOfRowsInSection0 = viewModel.dynamicTableViewModelNotificationOn.numberOfRows(section: 0)
		let numberOfRowsInSection1 = viewModel.dynamicTableViewModelNotificationOn.numberOfRows(section: 1)
		let numberOfRowsInSection2 = viewModel.dynamicTableViewModelNotificationOn.numberOfRows(section: 2)
		
		// THEN
		
		XCTAssertEqual(numberOfSections, 3)
		XCTAssertEqual(numberOfRowsInSection0, 1)
		XCTAssertEqual(numberOfRowsInSection1, 2)
		XCTAssertEqual(numberOfRowsInSection2, 4)
	}
	
}
