////
// 🦠 Corona-Warn-App
//

import UIKit

class HealthCertificateQRCodeCell: UITableViewCell, ReuseIdentifierProviding {

	// MARK: - Init

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupView()
		isAccessibilityElement = false

		qrCodeView.isAccessibilityElement = true
		titleLabel.isAccessibilityElement = true
		subtitleLabel.isAccessibilityElement = true
		validityStateTitleLabel.isAccessibilityElement = true
		validityStateDescriptionLabel.isAccessibilityElement = true

		accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.qrCodeCell
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

	func configure(with cellViewModel: HealthCertificateQRCodeCellViewModel) {
		self.cellViewModel = cellViewModel

		qrCodeView.configure(with: cellViewModel.qrCodeViewModel)

		titleLabel.text = cellViewModel.title
		titleLabel.isHidden = cellViewModel.title == nil

		subtitleLabel.text = cellViewModel.subtitle
		subtitleLabel.isHidden = cellViewModel.subtitle == nil

		validityStateIconImageView.image = cellViewModel.validityStateIcon
		validityStateTitleLabel.text = cellViewModel.validityStateTitle
		validityStateStackView.isHidden = cellViewModel.validityStateIcon == nil && cellViewModel.validityStateTitle == nil

		validityStateDescriptionLabel.text = cellViewModel.validityStateDescription
		validityStateDescriptionLabel.isHidden = cellViewModel.validityStateDescription == nil

		unseenNewsIndicator.isHidden = !cellViewModel.isUnseenNewsIndicatorVisible

		validationButton.isEnabled = cellViewModel.isValidationButtonEnabled
		validationButton.isHidden = !cellViewModel.isValidationButtonVisible
	}

	// MARK: - Private

	private let backgroundContainerView: UIView = {
		let backgroundContainerView = UIView()
		backgroundContainerView.backgroundColor = .enaColor(for: .cellBackground2)
		backgroundContainerView.layer.borderColor = UIColor.enaColor(for: .hairline).cgColor

		if #available(iOS 13.0, *) {
			backgroundContainerView.layer.cornerCurve = .continuous
		}
		backgroundContainerView.layer.cornerRadius = 15.0
		backgroundContainerView.layer.masksToBounds = true

		return backgroundContainerView
	}()

	private let qrCodeView = HealthCertificateQRCodeView()

	private let titleStackView: UIStackView = {
		let titleStackView = UIStackView()
		titleStackView.axis = .horizontal
		titleStackView.distribution = .fill
		titleStackView.alignment = .center
		titleStackView.spacing = 6

		return titleStackView
	}()

	private let titleLabel: ENALabel = {
		let titleLabel = ENALabel()
		titleLabel.style = .headline
		titleLabel.textColor = .enaColor(for: .textPrimary1)
		titleLabel.numberOfLines = 0
		titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
		titleLabel.setContentHuggingPriority(.required, for: .horizontal)

		return titleLabel
	}()

	private let unseenNewsIndicator: UIView = {
		let unseenNewsIndicator = UIView()
		unseenNewsIndicator.backgroundColor = .systemRed
		unseenNewsIndicator.layer.cornerRadius = 5.5

		return unseenNewsIndicator
	}()

	private let subtitleLabel: ENALabel = {
		let subtitleLabel = ENALabel()
		subtitleLabel.style = .body
		subtitleLabel.textColor = .enaColor(for: .textPrimary2)
		subtitleLabel.numberOfLines = 0

		return subtitleLabel
	}()

	private let validityStateStackView: UIStackView = {
		let validityStateStackView = UIStackView()
		validityStateStackView.alignment = .center
		validityStateStackView.axis = .horizontal
		validityStateStackView.spacing = 8.0

		return validityStateStackView
	}()

	private let validityStateIconImageView: UIImageView = {
		let validityStateIconImageView = UIImageView()
		validityStateIconImageView.setContentHuggingPriority(.required, for: .horizontal)

		return validityStateIconImageView
	}()

	private let validityStateTitleLabel: ENALabel = {
		let validityStateTitleLabel = ENALabel()
		validityStateTitleLabel.style = .body
		validityStateTitleLabel.textColor = .enaColor(for: .textPrimary1)
		validityStateTitleLabel.numberOfLines = 0

		return validityStateTitleLabel
	}()

	private let validityStateDescriptionLabel: ENALabel = {
		let validityStateDescriptionLabel = ENALabel()
		validityStateDescriptionLabel.style = .body
		validityStateDescriptionLabel.textColor = .enaColor(for: .textPrimary2)
		validityStateDescriptionLabel.numberOfLines = 0

		return validityStateDescriptionLabel
	}()

	private lazy var validationButton: ENAButton = {
		let validationButton = ENAButton()
		validationButton.hasBorder = true
		validationButton.hasBackground = false
		validationButton.setTitle(
			AppStrings.HealthCertificate.Person.validationButtonTitle,
			for: .normal
		)
		validationButton.accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.Person.validationButton
		validationButton.addTarget(self, action: #selector(validationButtonTapped), for: .primaryActionTriggered)

		return validationButton
	}()

	private let stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.alignment = .fill
		stackView.axis = .vertical
		stackView.spacing = 4.0

		return stackView
	}()

	private var cellViewModel: HealthCertificateQRCodeCellViewModel?

	private func setupView() {
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		selectionStyle = .none

		updateBorderWidth()

		backgroundContainerView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(backgroundContainerView)

		titleStackView.addArrangedSubview(titleLabel)
		titleStackView.addArrangedSubview(unseenNewsIndicator)
		titleStackView.addArrangedSubview(UIView())

		stackView.addArrangedSubview(qrCodeView)
		stackView.addArrangedSubview(titleStackView)
		stackView.addArrangedSubview(subtitleLabel)
		stackView.setCustomSpacing(12, after: subtitleLabel)

		validityStateStackView.addArrangedSubview(validityStateIconImageView)
		validityStateStackView.addArrangedSubview(validityStateTitleLabel)

		stackView.addArrangedSubview(validityStateStackView)
		stackView.setCustomSpacing(12, after: validityStateStackView)

		stackView.addArrangedSubview(validityStateDescriptionLabel)
		stackView.addArrangedSubview(validationButton)

		stackView.translatesAutoresizingMaskIntoConstraints = false
		backgroundContainerView.addSubview(stackView)

		NSLayoutConstraint.activate(
			[
				backgroundContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0.0),
				backgroundContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4.0),
				backgroundContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
				backgroundContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),

				stackView.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor, constant: 14.0),
				stackView.topAnchor.constraint(equalTo: backgroundContainerView.topAnchor, constant: 14.0),
				stackView.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor, constant: -14.0),
				stackView.bottomAnchor.constraint(equalTo: backgroundContainerView.bottomAnchor, constant: -14.0),

				unseenNewsIndicator.widthAnchor.constraint(equalToConstant: 11),
				unseenNewsIndicator.heightAnchor.constraint(equalToConstant: 11)
			]
		)

	}

	private func updateBorderWidth() {
		backgroundContainerView.layer.borderWidth = traitCollection.userInterfaceStyle == .dark ? 0 : 1
	}

	@objc
	private func validationButtonTapped() {
		cellViewModel?.didTapValidationButton { [weak self] isLoading in
			self?.validationButton.isLoading = isLoading
			self?.validationButton.isEnabled = !isLoading
		}
	}

}
