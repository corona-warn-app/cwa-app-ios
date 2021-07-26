//
// 🦠 Corona-Warn-App
//

import UIKit

class HealthCertificateExpirationDateCell: UITableViewCell, ReuseIdentifierProviding {

	// MARK: - Init

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupView()
		accessibilityElements = [headlineLabel as Any, expirationDateLabel as Any, contentTextLabel as Any]
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
		headlineLabel.textColor = cellViewModel.headlineTextColor

		expirationDateLabel.text = cellViewModel.expirationDate
		expirationDateLabel.textColor = cellViewModel.expirationDateTextColor

		contentTextLabel.text = cellViewModel.content
		contentTextLabel.textColor = cellViewModel.contentTextColor
	}

	// MARK: - Private

	private let backgroundContainerView = UIView()
	private let headlineLabel = ENALabel(style: .headline)
	private let expirationDateLabel = ENALabel(style: .subheadline)
	private let contentTextLabel = ENALabel(style: .subheadline)

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
		headlineLabel.numberOfLines = 0
		backgroundContainerView.addSubview(headlineLabel)

		expirationDateLabel.translatesAutoresizingMaskIntoConstraints = false
		expirationDateLabel.numberOfLines = 0
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
				expirationDateLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 4.0),
				expirationDateLabel.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -16.0),

				contentTextLabel.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor, constant: 16.0),
				contentTextLabel.topAnchor.constraint(equalTo: expirationDateLabel.bottomAnchor, constant: 8.0),
				contentTextLabel.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -16.0),
				contentTextLabel.bottomAnchor.constraint(equalTo: backgroundContainerView.bottomAnchor, constant: -16.0)
			]
		)
	}

	private func updateBorderWidth() {
		backgroundContainerView.layer.borderWidth = traitCollection.userInterfaceStyle == .dark ? 0 : 1
	}

}
