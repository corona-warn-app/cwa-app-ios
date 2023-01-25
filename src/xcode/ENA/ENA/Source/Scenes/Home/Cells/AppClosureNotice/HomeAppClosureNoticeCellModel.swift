//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class AppClosureNoticeCellModel {

	// MARK: - Init

	init(state: HomeState) {
		state.$enState
			.sink { [weak self] enState in
				self?.update(for: enState)
			}
			.store(in: &subscriptions)
	}

	// MARK: - Internal

	@OpenCombine.Published var title: String?
	@OpenCombine.Published var subtitle: String?
	@OpenCombine.Published var icon: UIImage?
	@OpenCombine.Published var accessibilityIdentifier: String?

	// MARK: - Private

	private var subscriptions = Set<AnyCancellable>()

	private func update(for state: ENStateHandler.State) {
		title = "Betriebsende"
		subtitle = "Der Betrieb der Corona-Warn-App wird am xx.xx.xxxx eingestellt."
		icon = UIImage(named: "Icons_Attention_high")
		accessibilityIdentifier = AccessibilityIdentifiers.Home.appClosureNotice
	}

}
