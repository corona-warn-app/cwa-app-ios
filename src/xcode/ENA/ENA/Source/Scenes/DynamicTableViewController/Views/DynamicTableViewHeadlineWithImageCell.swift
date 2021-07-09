////
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

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	func configure(headline: String, image: UIImage) {
		headlineLabel.text = headline
		backgroundImageView.image = image
	}

	// MARK: - Private

	private let headlineLabel = ENALabel(style: .title1)
	private let backgroundImageView = UIImageView()
	private let gradientView = GradientView()

	/*
	var height: CGFloat {
	} else if let imageWidth = image?.size.width,
	   let imageHeight = image?.size.height {
		// view.bounds.size.width will not be set at that point
		// tableviews always use full screen, so it might work to use screen size here
		let cellWidth = UIScreen.main.bounds.size.width
		let ratio = imageHeight / imageWidth
		view?.height = cellWidth * ratio

	}
*/

	private func setupView() {
		gradientView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(gradientView)

		headlineLabel.translatesAutoresizingMaskIntoConstraints = false
		headlineLabel.numberOfLines = 0
		contentView.addSubview(headlineLabel)

		backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
		backgroundImageView.contentMode = .scaleAspectFit
		contentView.addSubview(backgroundImageView)

		NSLayoutConstraint.activate(
			[
				gradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
				gradientView.topAnchor.constraint(equalTo: contentView.topAnchor),
				gradientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
				gradientView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

				headlineLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
				headlineLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 64.0),
				headlineLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -45.0),

				backgroundImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
				backgroundImageView.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 8.0),
				backgroundImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
				backgroundImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
			]
		)
	}

}
