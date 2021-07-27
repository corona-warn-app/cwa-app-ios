//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class TechnicalValidationFailedRulesTableViewCell: UITableViewCell, ReuseIdentifierProviding {

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

		updateBorderColor()
	}

	// MARK: - Internal
	
	func setText(_ text: String) {
		failureDescriptionLabel.text = text
	}
	
	// MARK: - Private

	private let backgroundContainerView = UIView()
	private let failureDescriptionLabel = ENALabel(style: .body)

	private func setupView() {
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		selectionStyle = .none

		backgroundContainerView.backgroundColor = .enaColor(for: .background)
		backgroundContainerView.layer.borderWidth = 1
		if #available(iOS 13.0, *) {
			backgroundContainerView.layer.cornerCurve = .continuous
		}
		backgroundContainerView.layer.cornerRadius = 15.0
		backgroundContainerView.layer.masksToBounds = true
		updateBorderColor()

		backgroundContainerView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(backgroundContainerView)

		let contentStackView = UIStackView()
		contentStackView.axis = .horizontal
		contentStackView.spacing = 12
		contentStackView.translatesAutoresizingMaskIntoConstraints = false
		contentStackView.alignment = .top
		backgroundContainerView.addSubview(contentStackView)

		let failureIconImageView = UIImageView(image: UIImage(named: "Icon_CertificateValidation_Failed"))
		failureIconImageView.setContentHuggingPriority(.required, for: .horizontal)
		contentStackView.addArrangedSubview(failureIconImageView)

		failureDescriptionLabel.numberOfLines = 0
		failureDescriptionLabel.textColor = .enaColor(for: .textPrimary1)
		contentStackView.addArrangedSubview(failureDescriptionLabel)

		NSLayoutConstraint.activate(
			[
				backgroundContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4.0),
				backgroundContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4.0),
				backgroundContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
				backgroundContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),

				contentStackView.topAnchor.constraint(equalTo: backgroundContainerView.topAnchor, constant: 16.0),
				contentStackView.bottomAnchor.constraint(equalTo: backgroundContainerView.bottomAnchor, constant: -16.0),
				contentStackView.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor, constant: 16.0),
				contentStackView.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -16.0)
			]
		)

		accessibilityElements = [failureDescriptionLabel]
	}

	private func updateBorderColor() {
		backgroundContainerView.layer.borderColor = UIColor.enaColor(for: .hairline).cgColor
	}

}
