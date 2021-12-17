//
// 🦠 Corona-Warn-App
//

import UIKit

class DynamicTableViewHeadlineWithImageCell: UITableViewCell {

	// MARK: - Init

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupView()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Internal

	func configure(
		headline: String,
		image: UIImage,
		topInset: CGFloat,
		imageAccessibilityLabel: String? = nil,
		imageAccessibilityIdentifier: String? = nil
	) {
		headlineLabel.text = headline
		backgroundImageView.image = image
		topInsetConstraint.constant = topInset
		imageHeightConstraint.constant = imageHeight

		backgroundImageView.accessibilityLabel = imageAccessibilityLabel
		backgroundImageView.isAccessibilityElement = imageAccessibilityLabel != nil

		backgroundImageView.accessibilityIdentifier = imageAccessibilityIdentifier
	}

	// MARK: - Private

	private let headlineLabel = ENALabel(style: .title1)
	private let backgroundImageView = UIImageView()
	private let gradientView = GradientView(type: .whiteToLightBlue, withStars: false)

	private var topInsetConstraint: NSLayoutConstraint!
	private var imageHeightConstraint: NSLayoutConstraint!

	private func setupView() {
		gradientView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(gradientView)

		headlineLabel.translatesAutoresizingMaskIntoConstraints = false
		headlineLabel.numberOfLines = 0
		contentView.addSubview(headlineLabel)

		backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
		backgroundImageView.contentMode = .scaleAspectFit
		contentView.addSubview(backgroundImageView)

		topInsetConstraint = headlineLabel.topAnchor.constraint(equalTo: contentView.topAnchor)
		imageHeightConstraint = backgroundImageView.heightAnchor.constraint(equalToConstant: 100.0)

		NSLayoutConstraint.activate(
			[
				gradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
				gradientView.topAnchor.constraint(equalTo: contentView.topAnchor),
				gradientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
				gradientView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

				headlineLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
				topInsetConstraint,
				headlineLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -45.0),
				headlineLabel.bottomAnchor.constraint(equalTo: backgroundImageView.topAnchor, constant: -12),

				backgroundImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
				backgroundImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
				backgroundImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
				imageHeightConstraint
			]
		)
	}

	/// UIImageView mode .scaleAspectFit will center the image with clear borders.
	/// By calculation the resulting height, we can set a layout constraint, this will draw the image without borders.
	private var imageHeight: CGFloat {
		guard let originalSize = backgroundImageView.image?.size else {
			Log.info("No image found - height must be 0.0")
			return 0.0
		}
		let screenSize = UIScreen.main.bounds.size
		return screenSize.width * originalSize.height / originalSize.width
	}

}
