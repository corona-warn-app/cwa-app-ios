//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class DynamicTableViewHeaderSeparatorView: UITableViewHeaderFooterView {
	private var separatorView: UIView!
	private var heightConstraint: NSLayoutConstraint!

	var color: UIColor? {
		get { separatorView.backgroundColor }
		set { separatorView.backgroundColor = newValue }
	}

	var height: CGFloat {
		get { heightConstraint.constant }
		set { heightConstraint.constant = newValue }
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override init(reuseIdentifier: String?) {
		super.init(reuseIdentifier: reuseIdentifier)
		setup()
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		layoutMargins = .zero
	}

	private func setup() {
		preservesSuperviewLayoutMargins = false
		insetsLayoutMarginsFromSafeArea = false
		layoutMargins = .zero

		separatorView = UIView()
		separatorView.translatesAutoresizingMaskIntoConstraints = false

		addSubview(separatorView)

		separatorView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
		separatorView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).isActive = true
		separatorView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
		let bottomConstraint = separatorView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
		bottomConstraint.priority = .defaultHigh
		bottomConstraint.isActive = true

		heightConstraint = separatorView.heightAnchor.constraint(equalToConstant: 1)
		heightConstraint.isActive = true
	}
}
