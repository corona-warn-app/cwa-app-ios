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
		titleLabel.text = cellModel.title
		nameLabel.text = cellModel.name

		qrCodeView.configure(with: cellModel.qrCodeViewModel)

		gradientView.type = cellModel.backgroundGradientType
	}
	
	// MARK: - Private

	private let cardView = CardView()
	private let titleLabel = ENALabel(style: .body)
	private let nameLabel = ENALabel(style: .title2)
	private let gradientView = GradientView()
	private let bottomView = UIView()
	private let qrCodeContainerView = UIView()
	private let qrCodeView = HealthCertificateQRCodeView()

	private func setupAccessibility() {
		cardView.accessibilityElements = [titleLabel as Any, nameLabel as Any, qrCodeView as Any]
		cardView.accessibilityTraits = [.staticText, .button]
		qrCodeView.isAccessibilityElement = true
		accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.Overview.healthCertifiedPersonCell
	}

	private func setupView() {
		selectionStyle = .none
		contentView.backgroundColor = .enaColor(for: .darkBackground)

		cardView.translatesAutoresizingMaskIntoConstraints = false
		cardView.hasBorder = false
		contentView.addSubview(cardView)

		gradientView.translatesAutoresizingMaskIntoConstraints = false
		gradientView.layer.masksToBounds = true
		gradientView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		gradientView.layer.cornerRadius = 14.0
		if #available(iOS 13.0, *) {
			gradientView.layer.cornerCurve = .continuous
		}
		cardView.addSubview(gradientView)

		bottomView.backgroundColor = .enaColor(for: .background)
		bottomView.translatesAutoresizingMaskIntoConstraints = false
		bottomView.clipsToBounds = false
		bottomView.layer.borderWidth = 1.0
		bottomView.layer.cornerRadius = 14.0
		bottomView.layer.maskedCorners = [ .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
		if #available(iOS 13.0, *) {
			bottomView.layer.cornerCurve = .continuous
		}

		cardView.addSubview(bottomView)

		titleLabel.numberOfLines = 0
		titleLabel.textColor = .enaColor(for: .textContrast)

		nameLabel.textColor = .enaColor(for: .textContrast)
		nameLabel.font = .enaFont(for: .title2, weight: .regular, italic: false)

		let stackView = UIStackView(arrangedSubviews: [titleLabel, nameLabel])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.spacing = 16.0
		gradientView.addSubview(stackView)

		qrCodeContainerView.translatesAutoresizingMaskIntoConstraints = false
		qrCodeContainerView.backgroundColor = .enaColor(for: .cellBackground2)
		qrCodeContainerView.layer.cornerRadius = 14
		qrCodeContainerView.layer.borderWidth = 1
		if #available(iOS 13.0, *) {
			qrCodeContainerView.layer.cornerCurve = .continuous
		}
		cardView.addSubview(qrCodeContainerView)

		qrCodeView.translatesAutoresizingMaskIntoConstraints = false
		qrCodeView.layer.magnificationFilter = CALayerContentsFilter.nearest
		qrCodeContainerView.addSubview(qrCodeView)

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
				qrCodeContainerView.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor, constant: -24.0),
				qrCodeContainerView.widthAnchor.constraint(equalTo: qrCodeContainerView.heightAnchor),

				qrCodeView.centerXAnchor.constraint(equalTo: qrCodeContainerView.centerXAnchor),
				qrCodeView.centerYAnchor.constraint(equalTo: qrCodeContainerView.centerYAnchor),
				qrCodeView.widthAnchor.constraint(equalTo: qrCodeContainerView.widthAnchor, constant: -32.0),
				qrCodeView.heightAnchor.constraint(equalTo: qrCodeContainerView.heightAnchor, constant: -32.0)
			]
		)

	}

	private func updateBorderColors() {
		bottomView.layer.borderColor = UIColor.enaColor(for: .cardBorder).cgColor
		qrCodeContainerView.layer.borderColor = UIColor.enaColor(for: .cardBorder).cgColor
	}

}
