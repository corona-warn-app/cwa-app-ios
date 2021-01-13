////
// 🦠 Corona-Warn-App
//

import UIKit

class HomeStatisticsCardView: UIView {

	// MARK: - Internal

	func configure(onInfoButtonTap: @escaping () -> Void) {
		self.onInfoButtonTap = onInfoButtonTap
	}

	// MARK: - Private

	private var onInfoButtonTap: (() -> Void)?

	@IBAction private  func infoButtonTapped(_ sender: Any) {
		onInfoButtonTap?()
	}

}
