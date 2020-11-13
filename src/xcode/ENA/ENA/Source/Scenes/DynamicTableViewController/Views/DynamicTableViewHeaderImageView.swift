//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class DynamicTableViewHeaderImageView: UITableViewHeaderFooterView {
	private(set) var imageView: UIImageView!
	private var heightConstraint: NSLayoutConstraint!

	var image: UIImage? {
		get { imageView.image }
		set { imageView.image = newValue }
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

	private func setup() {
		imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFit

		addSubview(imageView)
		imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

		heightConstraint = imageView.heightAnchor.constraint(equalToConstant: 100)
		heightConstraint.priority = .defaultHigh
		heightConstraint.isActive = true
	}
}
