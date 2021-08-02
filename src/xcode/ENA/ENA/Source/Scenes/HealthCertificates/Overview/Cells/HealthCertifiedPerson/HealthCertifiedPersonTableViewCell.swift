////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HealthCertifiedPersonTableViewCell: UITableViewCell, ReuseIdentifierProviding {
	
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

	// MARK: - Overrides

	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		super.setHighlighted(highlighted, animated: animated)

		cardView.setHighlighted(highlighted, animated: animated)
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		updateBorderColors()
	}

	// MARK: - Internal

	func configure(with cellModel: HealthCertifiedPersonCellModel) {
		gradientView.type = cellModel.backgroundGradientType

		titleLabel.text = cellModel.title
		nameLabel.text = cellModel.name

		qrCodeView.configure(with: cellModel.qrCodeViewModel)

		validityStateIconImageView.image = cellModel.validityStateIcon
		validityStateTitleLabel.text = cellModel.validityStateTitle
		validityStateStackView.isHidden = cellModel.validityStateIcon == nil && cellModel.validityStateTitle == nil
	}
	
	// MARK: - Private

	private let cardView: CardView = {
		let cardView = CardView()
		cardView.hasBorder = false

		return cardView
	}()

	private let titleLabel: ENALabel = {
		let titleLabel = ENALabel(style: .body)
		titleLabel.numberOfLines = 0
		titleLabel.textColor = .enaColor(for: .textContrast)

		return titleLabel
	}()

	private let nameLabel: ENALabel = {
		let nameLabel = ENALabel()
		nameLabel.numberOfLines = 0
		nameLabel.textColor = .enaColor(for: .textContrast)
		nameLabel.font = .enaFont(for: .title2, weight: .light, italic: false)

		return nameLabel
	}()

	private let gradientView: GradientView = {
		let gradientView = GradientView()
		gradientView.layer.masksToBounds = true
		gradientView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		gradientView.layer.cornerRadius = 14.0
		if #available(iOS 13.0, *) {
			gradientView.layer.cornerCurve = .continuous
		}

		return gradientView
	}()

	private let bottomView: UIView = {
		let bottomView = UIView()
		bottomView.backgroundColor = .enaColor(for: .background)
		bottomView.clipsToBounds = false
		bottomView.layer.borderWidth = 1.0
		bottomView.layer.cornerRadius = 14.0
		bottomView.layer.maskedCorners = [ .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
		if #available(iOS 13.0, *) {
			bottomView.layer.cornerCurve = .continuous
		}

		return bottomView
	}()

	private lazy var stackView: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: [titleLabel, nameLabel])
		stackView.axis = .vertical
		stackView.spacing = 16.0

		return stackView
	}()

	private let qrCodeContainerView: UIView = {
		let qrCodeContainerView = UIView()
		qrCodeContainerView.backgroundColor = .enaColor(for: .cellBackground2)
		qrCodeContainerView.layer.cornerRadius = 14
		qrCodeContainerView.layer.borderWidth = 1
		if #available(iOS 13.0, *) {
			qrCodeContainerView.layer.cornerCurve = .continuous
		}

		return qrCodeContainerView
	}()

	private let qrCodeView = HealthCertificateQRCodeView()

	private lazy var validityStateStackView: UIStackView = {
		let validityStateStackView = UIStackView(arrangedSubviews: [validityStateIconImageView, validityStateTitleLabel])
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

	private func setupAccessibility() {
		cardView.accessibilityElements = [titleLabel, nameLabel, qrCodeView, validityStateTitleLabel]
			.filter { !$0.isHidden }

		cardView.accessibilityTraits = [.staticText, .button]
		qrCodeView.isAccessibilityElement = true
		accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell
	}

	private func setupView() {
		selectionStyle = .none
		contentView.backgroundColor = .enaColor(for: .darkBackground)

		cardView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(cardView)

		gradientView.translatesAutoresizingMaskIntoConstraints = false
		cardView.addSubview(gradientView)

		bottomView.translatesAutoresizingMaskIntoConstraints = false
		cardView.addSubview(bottomView)

		stackView.translatesAutoresizingMaskIntoConstraints = false
		gradientView.addSubview(stackView)

		qrCodeContainerView.translatesAutoresizingMaskIntoConstraints = false
		cardView.addSubview(qrCodeContainerView)

		qrCodeView.translatesAutoresizingMaskIntoConstraints = false
		qrCodeContainerView.addSubview(qrCodeView)

		validityStateStackView.translatesAutoresizingMaskIntoConstraints = false
		bottomView.addSubview(validityStateStackView)

		updateBorderColors()

		NSLayoutConstraint.activate(
			[
				cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
				cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.0),
				cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),
				cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0),

				gradientView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
				gradientView.topAnchor.constraint(equalTo: cardView.topAnchor),
				gradientView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
				gradientView.bottomAnchor.constraint(equalTo: qrCodeView.centerYAnchor),

				bottomView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
				bottomView.topAnchor.constraint(equalTo: gradientView.bottomAnchor, constant: -1.0),
				bottomView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
				bottomView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),

				stackView.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: 15.0),
				stackView.topAnchor.constraint(equalTo: gradientView.topAnchor, constant: 20.0),
				stackView.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor, constant: -15.0),

				qrCodeContainerView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16.0),
				qrCodeContainerView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20.0),
				qrCodeContainerView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16.0),
				qrCodeContainerView.bottomAnchor.constraint(lessThanOrEqualTo: bottomView.bottomAnchor, constant: -24.0),
				qrCodeContainerView.widthAnchor.constraint(equalTo: qrCodeContainerView.heightAnchor),

				qrCodeView.centerXAnchor.constraint(equalTo: qrCodeContainerView.centerXAnchor),
				qrCodeView.centerYAnchor.constraint(equalTo: qrCodeContainerView.centerYAnchor),
				qrCodeView.widthAnchor.constraint(equalTo: qrCodeContainerView.widthAnchor, constant: -32.0),
				qrCodeView.heightAnchor.constraint(equalTo: qrCodeContainerView.heightAnchor, constant: -32.0),

				validityStateStackView.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 18.0),
				validityStateStackView.topAnchor.constraint(equalTo: qrCodeContainerView.bottomAnchor, constant: 12.0),
				validityStateStackView.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -16.0),
				validityStateStackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomView.bottomAnchor, constant: -16.0)
			]
		)

	}

	private func updateBorderColors() {
		bottomView.layer.borderColor = UIColor.enaColor(for: .cardBorder).cgColor
		qrCodeContainerView.layer.borderColor = UIColor.enaColor(for: .cardBorder).cgColor
	}

}
