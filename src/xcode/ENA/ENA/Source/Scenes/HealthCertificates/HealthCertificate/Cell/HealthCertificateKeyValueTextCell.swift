////
// 🦠 Corona-Warn-App
//

import UIKit

class HealthCertificateKeyValueTextCell: UITableViewCell, ReuseIdentifierProviding {

	// MARK: - Init

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupView()
		setupAccessibility()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Internal

	func configure(with cellViewModel: HealthCertificateKeyValueCellViewModel) {
		headlineTextLabel.font = cellViewModel.headlineFont
		detailsTextLabel.font = cellViewModel.textFont
		headlineTextLabel.textColor = cellViewModel.headlineTextColor
		detailsTextLabel.textColor = cellViewModel.textTextColor
		headlineTextLabel.text = cellViewModel.headline
		detailsTextLabel.text = cellViewModel.text
		backgroundContainerView.accessibilityLabel = [cellViewModel.headline, cellViewModel.text].joined(separator: " ")
		bottomSeparatorView.isHidden = cellViewModel.isBottomSeparatorHidden
		topSpaceLayoutConstraint.constant = cellViewModel.topSpace ?? 8.0
		bottomSpaceLayoutConstraint.constant = cellViewModel.bottomSpace ?? -8.0
	}

	// MARK: - Private

	private let backgroundContainerView = UIView()
	private let headlineTextLabel = ENALabel()
	private let detailsTextLabel = ENALabel()
	private let bottomSeparatorView = UIView()

	private var topSpaceLayoutConstraint: NSLayoutConstraint!
	private var bottomSpaceLayoutConstraint: NSLayoutConstraint!

	private func setupView() {
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		selectionStyle = .none

		backgroundContainerView.backgroundColor = .enaColor(for: .cellBackground2)
		backgroundContainerView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(backgroundContainerView)

		headlineTextLabel.numberOfLines = 0
		detailsTextLabel.numberOfLines = 0

		let stackView = UIStackView(arrangedSubviews: [headlineTextLabel, detailsTextLabel])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.alignment = .leading
		stackView.axis = .vertical
		stackView.spacing = 4.0
		backgroundContainerView.addSubview(stackView)

		bottomSeparatorView.translatesAutoresizingMaskIntoConstraints = false
		bottomSeparatorView.backgroundColor = .enaColor(for: .hairline)
		backgroundContainerView.addSubview(bottomSeparatorView)

		topSpaceLayoutConstraint = stackView.topAnchor.constraint(equalTo: backgroundContainerView.topAnchor, constant: 4.0)
		bottomSpaceLayoutConstraint = stackView.bottomAnchor.constraint(equalTo: backgroundContainerView.bottomAnchor, constant: -8.0)
		NSLayoutConstraint.activate(
			[
				backgroundContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
				backgroundContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
				backgroundContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
				backgroundContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),

				topSpaceLayoutConstraint,
				bottomSpaceLayoutConstraint,
				stackView.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor, constant: 16.0),
				stackView.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -16.0),

				bottomSeparatorView.heightAnchor.constraint(equalToConstant: 1),
				bottomSeparatorView.bottomAnchor.constraint(equalTo: backgroundContainerView.bottomAnchor),
				bottomSeparatorView.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor, constant: 7.0),
				bottomSeparatorView.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -7.0)
			]
		)
	}

	private func setupAccessibility() {
		backgroundContainerView.isAccessibilityElement = true
		backgroundContainerView.accessibilityTraits = .staticText
	}

}
