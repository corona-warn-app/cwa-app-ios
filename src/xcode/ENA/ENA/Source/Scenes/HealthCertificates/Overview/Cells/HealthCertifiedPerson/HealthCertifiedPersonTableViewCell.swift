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

	override func layoutSubviews() {
		super.layoutSubviews()

		captionCountView.layoutIfNeeded()
		captionCountView.layer.cornerRadius = captionCountView.bounds.height / 2
	}

	// MARK: - Internal

	func configure(with cellModel: HealthCertifiedPersonCellModel) {
		gradientView.type = cellModel.backgroundGradientType

		titleLabel.text = cellModel.title
		nameLabel.text = cellModel.name

		qrCodeView.configure(with: cellModel.qrCodeViewModel)

		captionStackView.isHidden = false
		captionStackView.arrangedSubviews.forEach { $0.isHidden = false }

		switch cellModel.caption {
		case .unseenNews(count: let unseenNewsCount):
			captionImageView.isHidden = true

			captionCountLabel.text = String(unseenNewsCount)
			captionLabel.text = AppStrings.HealthCertificate.Overview.news
		case let .validityState(image: validityStateIcon, description: validityStateDescription):
			captionCountView.isHidden = true

			captionImageView.image = validityStateIcon
			captionLabel.text = validityStateDescription
		case .none:
			captionStackView.isHidden = true
			captionStackView.arrangedSubviews.forEach { $0.isHidden = true }
		}

		setupAccessibility(validityStateTitleIsVisible: cellModel.caption != nil)
		captionCountLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: captionCountLabel.intrinsicContentSize.height).isActive = true
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
		let nameLabel = ENALabel(style: .title2)
		nameLabel.numberOfLines = 0
		nameLabel.textColor = .enaColor(for: .textContrast)
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
		stackView.spacing = 8.0

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
	
	private let accessoryIconView: UIImageView = {
		return UIImageView(image: UIImage(imageLiteralResourceName: "Icons_Chevron_plain_white"))
	}()

	private lazy var captionStackView: UIStackView = {
		let captionStackView = UIStackView(arrangedSubviews: [captionImageView, captionCountView, captionLabel, UIView()])
		captionStackView.alignment = .center
		captionStackView.axis = .horizontal
		captionStackView.spacing = 8.0

		return captionStackView
	}()

	private let captionImageView: UIImageView = {
		let captionImageView = UIImageView()
		captionImageView.setContentHuggingPriority(.required, for: .horizontal)
		captionImageView.setContentCompressionResistancePriority(.required, for: .horizontal)

		return captionImageView
	}()

	private let captionCountLabel: ENALabel = {
		let captionCountLabel = ENALabel()
		captionCountLabel.font = .enaFont(for: .subheadline, weight: .bold, italic: false)
		captionCountLabel.textColor = .enaColor(for: .textContrast)
		captionCountLabel.textAlignment = .center
		captionCountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

		return captionCountLabel
	}()

	private let captionCountView: UIView = {
		let captionCountView = UIView()
		captionCountView.backgroundColor = .systemRed
		captionCountView.layer.masksToBounds = true

		return captionCountView
	}()

	private let captionLabel: ENALabel = {
		let captionLabel = ENALabel()
		captionLabel.style = .body
		captionLabel.textColor = .enaColor(for: .textPrimary1)
		captionLabel.numberOfLines = 0
		captionLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

		return captionLabel
	}()

	private func setupAccessibility(validityStateTitleIsVisible: Bool) {
		cardView.accessibilityElements = [titleLabel, nameLabel, qrCodeView]

		if validityStateTitleIsVisible {
			cardView.accessibilityElements?.append(captionLabel)
		}

		qrCodeView.accessibilityTraits = [.image, .button]
		qrCodeView.isAccessibilityElement = true
		accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell
	}

	private func setupView() {
		selectionStyle = .none
		contentView.backgroundColor = .enaColor(for: .darkBackground)

		cardView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(cardView)

		accessoryIconView.translatesAutoresizingMaskIntoConstraints = false
		gradientView.addSubview(accessoryIconView)

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

		captionStackView.translatesAutoresizingMaskIntoConstraints = false
		bottomView.addSubview(captionStackView)

		captionCountLabel.translatesAutoresizingMaskIntoConstraints = false
		captionCountView.addSubview(captionCountLabel)

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

				// placement is based on new figma design
				accessoryIconView.widthAnchor.constraint(equalToConstant: 12.0),
				accessoryIconView.heightAnchor.constraint(equalToConstant: 21.0),
				accessoryIconView.topAnchor.constraint(equalTo: gradientView.topAnchor, constant: 35.0),
				accessoryIconView.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor, constant: -18.0),
				
				stackView.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: 15.0),
				stackView.topAnchor.constraint(equalTo: gradientView.topAnchor, constant: 20.0),
				stackView.trailingAnchor.constraint(equalTo: accessoryIconView.leadingAnchor, constant: 8.0),

				qrCodeContainerView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16.0),
				qrCodeContainerView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20.0),
				qrCodeContainerView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16.0),
				qrCodeContainerView.bottomAnchor.constraint(lessThanOrEqualTo: bottomView.bottomAnchor, constant: -24.0),

				qrCodeView.leadingAnchor.constraint(equalTo: qrCodeContainerView.leadingAnchor, constant: 16.0),
				qrCodeView.topAnchor.constraint(equalTo: qrCodeContainerView.topAnchor, constant: 16.0),
				qrCodeView.trailingAnchor.constraint(equalTo: qrCodeContainerView.trailingAnchor, constant: -16.0),
				qrCodeView.bottomAnchor.constraint(equalTo: qrCodeContainerView.bottomAnchor, constant: -16.0),

				captionStackView.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 18.0),
				captionStackView.topAnchor.constraint(equalTo: qrCodeContainerView.bottomAnchor, constant: 12.0),
				captionStackView.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -16.0),
				captionStackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomView.bottomAnchor, constant: -16.0),

				captionCountView.widthAnchor.constraint(greaterThanOrEqualTo: captionCountView.heightAnchor),

				captionCountLabel.leadingAnchor.constraint(equalTo: captionCountView.leadingAnchor, constant: 2.0),
				captionCountLabel.topAnchor.constraint(equalTo: captionCountView.topAnchor, constant: 2.0),
				captionCountLabel.trailingAnchor.constraint(equalTo: captionCountView.trailingAnchor, constant: -2.0),
				captionCountLabel.bottomAnchor.constraint(equalTo: captionCountView.bottomAnchor, constant: -2.0)
			]
		)
	}

	private func updateBorderColors() {
		bottomView.layer.borderColor = UIColor.enaColor(for: .cardBorder).cgColor
		qrCodeContainerView.layer.borderColor = UIColor.enaColor(for: .cardBorder).cgColor
	}

}
