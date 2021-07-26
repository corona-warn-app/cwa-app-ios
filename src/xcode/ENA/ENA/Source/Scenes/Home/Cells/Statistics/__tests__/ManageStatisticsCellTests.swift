//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class ManageStatisticsCellTests: XCTestCase {

    func testManageCardViewStates() throws {
		let nib = UINib(nibName: "ManageStatisticsCardView", bundle: nil)
        let manageCard = try XCTUnwrap(nib.instantiate(withOwner: nil, options: nil).first as? ManageStatisticsCardView)

		manageCard.updateUI(for: .empty)
		XCTAssertEqual(manageCard.stackView.arrangedSubviews.count, 1)

		manageCard.updateUI(for: .notYetFull)
		XCTAssertEqual(manageCard.stackView.arrangedSubviews.count, 2)

		manageCard.updateUI(for: .full)
		XCTAssertEqual(manageCard.stackView.arrangedSubviews.count, 2)
    }

	func testDashedView() throws {
		let add = CustomDashedView.instance(for: .add)
		XCTAssertEqual(add.accessibilityIdentifier, AccessibilityIdentifiers.LocalStatistics.addLocalIncidencesButton)
		XCTAssertTrue(add.accessibilityTraits.contains(.button))

		let modify = CustomDashedView.instance(for: .modify)
		XCTAssertEqual(modify.accessibilityIdentifier, AccessibilityIdentifiers.LocalStatistics.modifyLocalIncidencesButton)
		XCTAssertTrue(modify.accessibilityTraits.contains(.button))
	}
}
