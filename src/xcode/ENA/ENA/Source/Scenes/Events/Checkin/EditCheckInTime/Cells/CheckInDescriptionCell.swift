////
// 🦠 Corona-Warn-App
//

import UIKit

class CheckInDescriptionCell: UITableViewCell, ReuseIdentifierProviding {

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

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		updateBorderWidth()
	}

	// MARK: - Internal

	func configure(cellModel: CheckInDescriptionCellModel) {
		traceLocationTypeLabel.text = cellModel.locationType
		traceLocationTypeLabel.accessibilityIdentifier = AccessibilityIdentifiers.Checkin.Details.traceLocationTypeLabel
		traceLocationDescriptionLabel.text = cellModel.description
		traceLocationDescriptionLabel.accessibilityIdentifier = AccessibilityIdentifiers.Checkin.Details.traceLocationDescriptionLabel
		traceLocationAddressLabel.text = cellModel.address
		traceLocationAddressLabel.accessibilityIdentifier = AccessibilityIdentifiers.Checkin.Details.traceLocationAddressLabel
	}

	// MARK: - Private

	private let traceLocationTypeLabel = ENALabel()
	private let traceLocationDescriptionLabel = ENALabel()
	private let traceLocationAddressLabel = ENALabel()
	private let tileView = UIView()

	private func setupView() {
		selectionStyle = .none
		backgroundColor = .clear
		contentView.backgroundColor = .clear

		traceLocationTypeLabel.font = .enaFont(for: .body)
		traceLocationTypeLabel.textColor = .enaColor(for: .textPrimary2)
		traceLocationTypeLabel.numberOfLines = 0

		traceLocationDescriptionLabel.font = .enaFont(for: .title1)
		traceLocationDescriptionLabel.textColor = .enaColor(for: .textPrimary1)
		traceLocationDescriptionLabel.numberOfLines = 0

		traceLocationAddressLabel.font = .enaFont(for: .body)
		traceLocationAddressLabel.textColor = .enaColor(for: .textPrimary2)
		traceLocationAddressLabel.numberOfLines = 0

		tileView.translatesAutoresizingMaskIntoConstraints = false
		tileView.backgroundColor = .enaColor(for: .cellBackground2)
		tileView.layer.cornerRadius = 12.0
		tileView.layer.masksToBounds = true
		tileView.layer.borderColor = UIColor.enaColor(for: .hairline).cgColor
		updateBorderWidth()
		contentView.addSubview(tileView)

		let stackView = UIStackView(
			arrangedSubviews:
				[
					traceLocationTypeLabel,
					traceLocationDescriptionLabel,
					traceLocationAddressLabel
				]
		)
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.spacing = 14.0
		tileView.addSubview(stackView)

		NSLayoutConstraint.activate(
			[
				tileView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6.0),
				tileView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4.0),
				tileView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
				tileView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),

				stackView.topAnchor.constraint(equalTo: tileView.topAnchor, constant: 32.0),
				stackView.bottomAnchor.constraint(equalTo: tileView.bottomAnchor, constant: -32.0),
				stackView.leadingAnchor.constraint(equalTo: tileView.leadingAnchor, constant: 16.0),
				stackView.trailingAnchor.constraint(equalTo: tileView.trailingAnchor, constant: -16.0)
			]
		)
	}

	private func updateBorderWidth() {
		tileView.layer.borderWidth = traitCollection.userInterfaceStyle == .dark ? 0 : 1
	}

}
