////
// 🦠 Corona-Warn-App
//

import UIKit

class PreferredPersonTableViewCell: UITableViewCell, ReuseIdentifierProviding {

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

	func configure(with cellModel: PreferredPersonCellModel) {
		nameLabel.text = cellModel.name
		dateOfBirthLabel.text = cellModel.dateOfBirth
		preferredPersonSwitch.isOn = cellModel.isPreferredPerson

		self.cellModel = cellModel
	}

	// MARK: - Private

	private let backgroundContainerView = UIView()

	private let nameLabel = ENALabel(style: .headline)
	private let dateOfBirthLabel = ENALabel(style: .body)
	private let preferredPersonSwitch = UISwitch()

	private var cellModel: PreferredPersonCellModel?

	private func setupView() {
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		selectionStyle = .none

		backgroundContainerView.backgroundColor = .enaColor(for: .cellBackground2)
		backgroundContainerView.layer.borderColor = UIColor.enaColor(for: .hairline).cgColor
		if #available(iOS 13.0, *) {
			backgroundContainerView.layer.cornerCurve = .continuous
		}
		backgroundContainerView.layer.cornerRadius = 15.0
		backgroundContainerView.layer.masksToBounds = true
		updateBorderWidth()

		backgroundContainerView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(backgroundContainerView)

		let contentStackView = UIStackView()
		contentStackView.axis = .vertical
		contentStackView.spacing = 6
		contentStackView.translatesAutoresizingMaskIntoConstraints = false
		backgroundContainerView.addSubview(contentStackView)

		let topContentStackView = UIStackView()
		topContentStackView.axis = .horizontal
		topContentStackView.alignment = .center
		contentStackView.addArrangedSubview(topContentStackView)

		let personalDataStackView = UIStackView()
		personalDataStackView.axis = .vertical
		topContentStackView.addArrangedSubview(personalDataStackView)

		nameLabel.numberOfLines = 0
		nameLabel.textColor = .enaColor(for: .textPrimary1)
		personalDataStackView.addArrangedSubview(nameLabel)

		dateOfBirthLabel.numberOfLines = 0
		dateOfBirthLabel.textColor = .enaColor(for: .textPrimary2)
		personalDataStackView.addArrangedSubview(dateOfBirthLabel)

		preferredPersonSwitch.onTintColor = .enaColor(for: .tint)
		preferredPersonSwitch.setContentHuggingPriority(.required, for: .horizontal)
		preferredPersonSwitch.addTarget(self, action: #selector(didTogglePreferredPersonSwitch(sender:)), for: .valueChanged)
		topContentStackView.addArrangedSubview(preferredPersonSwitch)

		let descriptionLabel = ENALabel(style: .body)
		descriptionLabel.text = AppStrings.HealthCertificate.Person.preferredPersonDescription
		descriptionLabel.numberOfLines = 0
		contentStackView.addArrangedSubview(descriptionLabel)

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
	}

	private func updateBorderWidth() {
		backgroundContainerView.layer.borderWidth = traitCollection.userInterfaceStyle == .dark ? 0 : 1
	}

	@objc
	private func didTogglePreferredPersonSwitch(sender: UISwitch) {
		cellModel?.setAsPreferredPerson(sender.isOn)
	}

}
