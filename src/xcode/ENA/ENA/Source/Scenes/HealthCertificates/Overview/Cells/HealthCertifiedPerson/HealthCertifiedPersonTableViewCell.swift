////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HealthCertifiedPersonTableViewCell: UITableViewCell, ReuseIdentifierProviding {
	
	// MARK: - Overrides

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupView()
		setupAccessibility()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		super.setHighlighted(highlighted, animated: animated)

		cardView.setHighlighted(highlighted, animated: animated)
	}

	// MARK: - Internal

	func configure(with cellModel: HealthCertifiedPersonCellModel) {
		titleLabel.text = cellModel.title
		nameLabel.text = cellModel.name
		gradientView.type = cellModel.backgroundGradientType
		// add a placeholder image and process the QRCode image in background to smooth scrolling a bit
		qrCodeImageView.image = placeHolderImage
		DispatchQueue.global(qos: .userInteractive).async {
			let qrCodeImage = UIImage.qrCode(
				with: cellModel.certificate.base45,
				encoding: .utf8,
				size: CGSize(width: 280, height: 280),
				qrCodeErrorCorrectionLevel: .medium
			)
			DispatchQueue.main.async { [weak self] in
				self?.qrCodeImageView.image = qrCodeImage
			}
		}
		qrCodeImageView.accessibilityLabel = AppStrings.HealthCertificate.Overview.covidDescription
		accessibilityIdentifier = cellModel.accessibilityIdentifier
	}
	
	// MARK: - Private

	private let cardView = CardView()
	private let titleLabel = ENALabel(style: .body)
	private let nameLabel = ENALabel(style: .title2)
	private let gradientView = GradientView()
	private let qrCodeImageView = UIImageView()
	private let placeHolderImage: UIImage? = UIImage.with(color: .enaColor(for: .background))

	private func setupAccessibility() {
		cardView.accessibilityElements = [titleLabel as Any, nameLabel as Any, qrCodeImageView as Any]
		cardView.accessibilityTraits = [.staticText, .button]
		qrCodeImageView.isAccessibilityElement = true
	}

	private func setupView() {
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

		let bottomView = UIView()
		bottomView.backgroundColor = .enaColor(for: .background)
		bottomView.translatesAutoresizingMaskIntoConstraints = false
		bottomView.clipsToBounds = false
		bottomView.layer.borderWidth = 1.0
		bottomView.layer.borderColor = UIColor.enaColor(for: .cardShadow).cgColor
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

		let qrCodeContainerView = UIView()
		qrCodeContainerView.translatesAutoresizingMaskIntoConstraints = false
		qrCodeContainerView.backgroundColor = .enaColor(for: .cellBackground2)
		qrCodeContainerView.layer.cornerRadius = 14
		qrCodeContainerView.layer.borderWidth = 1
		qrCodeContainerView.layer.borderColor = UIColor.enaColor(for: .hairline).cgColor
		if #available(iOS 13.0, *) {
			qrCodeContainerView.layer.cornerCurve = .continuous
		}
		cardView.addSubview(qrCodeContainerView)

		qrCodeImageView.translatesAutoresizingMaskIntoConstraints = false
		qrCodeContainerView.addSubview(qrCodeImageView)

		NSLayoutConstraint.activate(
			[
				cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
				cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.0),
				cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),
				cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0),

				gradientView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
				gradientView.topAnchor.constraint(equalTo: cardView.topAnchor),
				gradientView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
				gradientView.bottomAnchor.constraint(equalTo: qrCodeImageView.centerYAnchor),

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

				qrCodeImageView.centerXAnchor.constraint(equalTo: qrCodeContainerView.centerXAnchor),
				qrCodeImageView.centerYAnchor.constraint(equalTo: qrCodeContainerView.centerYAnchor),
				qrCodeImageView.widthAnchor.constraint(equalTo: qrCodeContainerView.widthAnchor, constant: -32.0),
				qrCodeImageView.heightAnchor.constraint(equalTo: qrCodeContainerView.heightAnchor, constant: -32.0)
			]
		)

	}

}
