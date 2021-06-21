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
		certificateType.text = cellModel.description
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
		accessibilityIdentifier = cellModel.accessibilityIdentifier
	}
	
	// MARK: - Private

	private let cardView: CardView = CardView()
	private let titleLabel: ENALabel = ENALabel()
	private let certificateType: ENALabel = ENALabel()
	private let nameLabel: ENALabel = ENALabel()
	private let gradientView: GradientView = GradientView(type: .lightBlue(withStars: false))
	private let qrCodeImageView: UIImageView = UIImageView()
	private let placeHolderImage: UIImage? = UIImage.with(color: .enaColor(for: .background))

	private func setupAccessibility() {
//		contentView.accessibilityElements = [titleLabel as Any, descriptionLabel as Any, nameLabel as Any]
	}

	private func setupView() {
		cardView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(cardView)

		let topContainerView = UIView()
		topContainerView.translatesAutoresizingMaskIntoConstraints = false
		topContainerView.backgroundColor = .enaColor(for: .background)
		topContainerView.layer.masksToBounds = true
		topContainerView.layer.cornerRadius = 12
		if #available(iOS 13.0, *) {
			topContainerView.layer.cornerCurve = .continuous
		}
		cardView.addSubview(topContainerView)

		let gradientView = GradientView(type: .mediumBlue(withStars: true))
		gradientView.translatesAutoresizingMaskIntoConstraints = false
		gradientView.layer.masksToBounds = true
		gradientView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		gradientView.layer.cornerRadius = 12
		if #available(iOS 13.0, *) {
			gradientView.layer.cornerCurve = .continuous
		}
		topContainerView.addSubview(gradientView)

		let bottomView = UIView()
		bottomView.backgroundColor = .enaColor(for: .background)
		bottomView.translatesAutoresizingMaskIntoConstraints = false
		topContainerView.addSubview(bottomView)

		titleLabel.textColor = .enaColor(for: .textContrast)
		titleLabel.font = .enaFont(for: .body)
		certificateType.textColor = .enaColor(for: .textContrast)
		certificateType.font = .enaFont(for: .headline)
		let stackView = UIStackView(arrangedSubviews: [titleLabel, certificateType])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.spacing = 4.0
		gradientView.addSubview(stackView)

		nameLabel.textColor = .enaColor(for: .textContrast)
		nameLabel.font = .enaFont(for: .title2, weight: .regular, italic: false)
		nameLabel.translatesAutoresizingMaskIntoConstraints = false
		gradientView.addSubview(nameLabel)

		let qrCodeContainerView = UIView()
		qrCodeContainerView.translatesAutoresizingMaskIntoConstraints = false
		qrCodeContainerView.backgroundColor = .enaColor(for: .background)
		qrCodeContainerView.layer.cornerRadius = 12
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

				topContainerView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
				topContainerView.topAnchor.constraint(equalTo: cardView.topAnchor),
				topContainerView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
				topContainerView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),

				gradientView.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor),
				gradientView.topAnchor.constraint(equalTo: topContainerView.topAnchor),
				gradientView.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor),
				gradientView.bottomAnchor.constraint(equalTo: qrCodeImageView.centerYAnchor),

				bottomView.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor),
				bottomView.topAnchor.constraint(equalTo: gradientView.bottomAnchor, constant: -1.0),
				bottomView.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor),
				bottomView.bottomAnchor.constraint(equalTo: topContainerView.bottomAnchor),

				stackView.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: 15.0),
				stackView.topAnchor.constraint(equalTo: gradientView.topAnchor, constant: 20.0),
				stackView.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor, constant: -15.0),

				nameLabel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 17.0),
				nameLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
				nameLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),

				qrCodeContainerView.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor, constant: 16.0),
				qrCodeContainerView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20.0),
				qrCodeContainerView.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor, constant: -16.0),
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
