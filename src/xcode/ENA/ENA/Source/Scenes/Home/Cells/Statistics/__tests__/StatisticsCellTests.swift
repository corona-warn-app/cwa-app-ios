//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class StatisticsCellTests: XCTestCase {

    func testManageCardViewStates() throws {
		let nib = UINib(nibName: "ManageStatisticsCardView", bundle: nil)
        let manageCard = try XCTUnwrap(nib.instantiate(withOwner: nil, options: nil).first as? ManageStatisticsCardView)

		manageCard.updateUI(for: .empty)
		XCTAssertEqual(manageCard.stackView.arrangedSubviews.count, 1)

		manageCard.updateUI(for: .notYetFull)
		XCTAssertEqual(manageCard.stackView.arrangedSubviews.count, 2)

		manageCard.updateUI(for: .full)
		XCTAssertEqual(manageCard.stackView.arrangedSubviews.count, 1) // will be 2 after refactoring!
    }

}
