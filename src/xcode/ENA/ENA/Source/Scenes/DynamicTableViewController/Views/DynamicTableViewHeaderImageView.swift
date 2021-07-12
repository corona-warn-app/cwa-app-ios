//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class DynamicTableViewHeaderImageView: UITableViewHeaderFooterView {

	// MARK: - Init

	override init(reuseIdentifier: String?) {
		super.init(reuseIdentifier: reuseIdentifier)
		setup()
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Internal

	var image: UIImage? {
		get { imageView.image }
		set { imageView.image = newValue }
	}

	var height: CGFloat {
		get { heightConstraint.constant }
		set { heightConstraint.constant = newValue }
	}

	var title: String? {
		get { titleLabel.text }
		set { titleLabel.text = newValue }
	}

	// MARK: - Private

	private(set) var imageView: UIImageView!
	private(set) var titleLabel: ENALabel = ENALabel(style: .title1)
	private var heightConstraint: NSLayoutConstraint!

	private func setup() {
		imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFit
		addSubview(imageView)

		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		titleLabel.numberOfLines = 0
		imageView.addSubview(titleLabel)

		heightConstraint = imageView.heightAnchor.constraint(equalToConstant: 100)
		heightConstraint.priority = .defaultHigh

		NSLayoutConstraint.activate(
			[
				imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
				imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
				imageView.topAnchor.constraint(equalTo: topAnchor),
				imageView.bottomAnchor.constraint(equalTo: bottomAnchor),

				heightConstraint,

				titleLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 16.0),
				titleLabel.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 16.0),
				titleLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -42.0)
			]
		)
	}
}
