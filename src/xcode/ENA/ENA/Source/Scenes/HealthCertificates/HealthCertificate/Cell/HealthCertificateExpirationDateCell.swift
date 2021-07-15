////
// 🦠 Corona-Warn-App
//

import UIKit

class HealthCertificateExpirationDateCell: UITableViewCell {

	// MARK: - Init

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupView()
		isAccessibilityElement = false
		contentTextLabel.isAccessibilityElement = true
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

	func configure(with cellViewModel: HealthCertificateExpirationDateCellViewModel) {
		headlineLabel.text = cellViewModel.headline
		expirationDateLabel.text = cellViewModel.expirationDate
		contentTextLabel.text = cellViewModel.content
	}

	// MARK: - Private

	private let backgroundContainerView = UIView()
	private let headlineLabel = ENALabel(style: .title1)
	private let expirationDateLabel = ENALabel(style: .body)
	private let contentTextLabel = ENALabel()

	private func setupView() {
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		selectionStyle = .none

		if #available(iOS 13.0, *) {
			backgroundContainerView.layer.cornerCurve = .continuous
		}
		backgroundContainerView.layer.cornerRadius = 15.0
		backgroundContainerView.layer.masksToBounds = true
		backgroundContainerView.layer.borderColor = UIColor.enaColor(for: .hairline).cgColor
		backgroundContainerView.backgroundColor = .enaColor(for: .cellBackground2)
		updateBorderWidth()

		backgroundContainerView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(backgroundContainerView)

		headlineLabel.translatesAutoresizingMaskIntoConstraints = false
		backgroundContainerView.addSubview(headlineLabel)

		expirationDateLabel.translatesAutoresizingMaskIntoConstraints = false
		backgroundContainerView.addSubview(expirationDateLabel)

		contentTextLabel.translatesAutoresizingMaskIntoConstraints = false
		contentTextLabel.numberOfLines = 0
		backgroundContainerView.addSubview(contentTextLabel)

		NSLayoutConstraint.activate(
			[
				backgroundContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
				backgroundContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4.0),
				backgroundContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),
				backgroundContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4.0),

				headlineLabel.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor, constant: 16.0),
				headlineLabel.topAnchor.constraint(equalTo: backgroundContainerView.topAnchor, constant: 16.0),
				headlineLabel.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -16.0),

				expirationDateLabel.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor, constant: 16.0),
				expirationDateLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 2.0),
				expirationDateLabel.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -16.0),

				contentTextLabel.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor, constant: 16.0),
				contentTextLabel.topAnchor.constraint(equalTo: expirationDateLabel.bottomAnchor, constant: 16.0),
				contentTextLabel.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -16.0),
				contentTextLabel.bottomAnchor.constraint(equalTo: backgroundContainerView.bottomAnchor, constant: -16.0)
			]
		)
	}

	private func updateBorderWidth() {
		backgroundContainerView.layer.borderWidth = traitCollection.userInterfaceStyle == .dark ? 0 : 1
	}

}
