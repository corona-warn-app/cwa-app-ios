//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeStatisticsCell: UITableViewCell {

	// MARK: - Internal

	func configure(
		with cellModel: HomeStatisticsCellModel,
		onInfoButtonTap: @escaping () -> Void,
		onAccessibilityFocus: @escaping () -> Void,
		onUpdate: @escaping () -> Void
	) {
		guard self.cellModel == nil else { return }

		cellModel.$keyFigureCards
			.receive(on: DispatchQueue.OCombine(.main))
			.sink { /* [weak self]*/ _ in
//				self?.configure(
//					for: $0,
//					onInfoButtonTap: onInfoButtonTap,
//					onAccessibilityFocus: onAccessibilityFocus
//				)
				onUpdate()
			}
			.store(in: &subscriptions)

		// Retaining cell model so it gets updated
		self.cellModel = cellModel
	}

	// MARK: - Private

	@IBOutlet private weak var scrollView: UIScrollView!

	private var cellModel: HomeStatisticsCellModel?
	private var subscriptions = Set<AnyCancellable>()
}
