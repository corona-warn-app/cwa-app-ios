////
// 🦠 Corona-Warn-App
//

import UIKit

/// just an empty view to make some space under a tableview section

class SelectTraceLocationTypeFooterView: UITableViewHeaderFooterView, ReuseIdentifierProviding {

	// MARK: - Init

	override init(reuseIdentifier: String?) {
		super.init(reuseIdentifier: reuseIdentifier)
		setupView()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Private

	private func setupView() {
		contentView.backgroundColor = .enaColor(for: .cellBackground)
		NSLayoutConstraint.activate([
			contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 15.0)
		])
	}

}
