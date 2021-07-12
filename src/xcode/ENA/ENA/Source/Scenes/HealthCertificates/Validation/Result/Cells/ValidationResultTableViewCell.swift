////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class ValidationResultTableViewCell: UITableViewCell, ReuseIdentifierProviding {

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

	func configure(with cellModel: ValidationResultCellModel) {
		iconImageView.image = cellModel.iconImage
		ruleDescriptionLabel.text = cellModel.ruleDescription
		ruleTypeDescriptionLabel.text = cellModel.ruleTypeDescription

		keyValuePairsStackView.arrangedSubviews.forEach {
			keyValuePairsStackView.removeArrangedSubview($0)
			$0.removeFromSuperview()
		}

		cellModel.keyValuePairs.forEach { keyValuePair in
			let keyValueStackView = UIStackView()
			keyValueStackView.axis = .vertical
			keyValueStackView.spacing = 0
			keyValueStackView.alignment = .leading
			keyValuePairsStackView.addArrangedSubview(keyValueStackView)

			let keyLabel = ENALabel(style: .footnote)
			keyLabel.numberOfLines = 0
			keyLabel.textColor = .enaColor(for: .textPrimary2)
			keyLabel.text = keyValuePair.key
			keyValueStackView.addArrangedSubview(keyLabel)

			let valueLabel = ENALabel(style: .subheadline)
			valueLabel.numberOfLines = 0
			valueLabel.textColor = .enaColor(for: .textPrimary1)
			valueLabel.text = keyValuePair.value
			keyValueStackView.addArrangedSubview(valueLabel)
		}
	}

	// MARK: - Private

	private let backgroundContainerView = UIView()
	private let iconImageView = UIImageView()

	private let keyValuePairsStackView = UIStackView()
	private let ruleDescriptionLabel = ENALabel(style: .body)
	private let ruleTypeDescriptionLabel = ENALabel(style: .footnote)

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

		let containerStackView = UIStackView()
		containerStackView.axis = .horizontal
		containerStackView.spacing = 12
		containerStackView.translatesAutoresizingMaskIntoConstraints = false
		containerStackView.alignment = .top
		backgroundContainerView.addSubview(containerStackView)

		iconImageView.setContentHuggingPriority(.required, for: .horizontal)
		containerStackView.addArrangedSubview(iconImageView)

		let contentStackView = UIStackView()
		contentStackView.axis = .vertical
		contentStackView.spacing = 12
		contentStackView.alignment = .leading
		containerStackView.addArrangedSubview(contentStackView)

		let descriptionStackView = UIStackView()
		descriptionStackView.axis = .vertical
		descriptionStackView.spacing = 0
		descriptionStackView.alignment = .leading
		contentStackView.addArrangedSubview(descriptionStackView)

		ruleDescriptionLabel.numberOfLines = 0
		ruleDescriptionLabel.textColor = .enaColor(for: .textPrimary1)
		descriptionStackView.addArrangedSubview(ruleDescriptionLabel)

		ruleTypeDescriptionLabel.numberOfLines = 0
		ruleTypeDescriptionLabel.textColor = .enaColor(for: .textPrimary2)
		descriptionStackView.addArrangedSubview(ruleTypeDescriptionLabel)

		keyValuePairsStackView.axis = .vertical
		keyValuePairsStackView.spacing = 12
		keyValuePairsStackView.alignment = .leading
		contentStackView.addArrangedSubview(keyValuePairsStackView)

		NSLayoutConstraint.activate(
			[
				backgroundContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4.0),
				backgroundContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4.0),
				backgroundContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
				backgroundContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),

				containerStackView.topAnchor.constraint(equalTo: backgroundContainerView.topAnchor, constant: 16.0),
				containerStackView.bottomAnchor.constraint(equalTo: backgroundContainerView.bottomAnchor, constant: -16.0),
				containerStackView.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor, constant: 16.0),
				containerStackView.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -16.0)
			]
		)
	}

	private func updateBorderColor() {
		backgroundContainerView.layer.borderColor = UIColor.enaColor(for: .hairline).cgColor
	}

}
