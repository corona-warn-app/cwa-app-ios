//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class AntigenTestPersonProfileCell: UITableViewCell, ReuseIdentifierProviding {
	
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

	// MARK: - Internal

	func configure(with cellModel: AntigenTestPersonProfileCellModel) {
		self.cellModel = cellModel

		gradientView.type = cellModel.backgroundGradientType

		titleLabel.text = cellModel.title
		nameLabel.text = cellModel.name

		qrCodeView.image = cellModel.qrCodeViewModel.qrCodeImage()

		setupAccessibility()
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
		titleLabel.accessibilityTraits = [.button]

		return titleLabel
	}()

	private let nameLabel: ENALabel = {
		let nameLabel = ENALabel(style: .title2)
		nameLabel.numberOfLines = 0
		nameLabel.textColor = .enaColor(for: .textContrast)
		nameLabel.accessibilityTraits = [.button]

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
		bottomView.backgroundColor = .enaColor(for: .backgroundLightGray)
		bottomView.clipsToBounds = false
		bottomView.layer.borderWidth = 1.0
		bottomView.layer.cornerRadius = 14.0
		bottomView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
		if #available(iOS 13.0, *) {
			bottomView.layer.cornerCurve = .continuous
		}

		return bottomView
	}()

	private lazy var titleStackView: UIStackView = {
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

	private let qrCodeView = UIImageView()
	
	private let accessoryIconView: UIImageView = {
		return UIImageView(image: UIImage(imageLiteralResourceName: "Icons_Chevron_plain_white"))
	}()

	private var cellModel: AntigenTestPersonProfileCellModel?

	private func setupAccessibility() {
		cardView.accessibilityElements = [titleLabel, nameLabel]
		cardView.accessibilityElements?.append(qrCodeView)

		accessibilityIdentifier = AccessibilityIdentifiers.AntigenProfile.Overview.antigenTestPersonProfileCell
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

		titleStackView.translatesAutoresizingMaskIntoConstraints = false
		gradientView.addSubview(titleStackView)

		qrCodeContainerView.translatesAutoresizingMaskIntoConstraints = false
		cardView.addSubview(qrCodeContainerView)

		qrCodeView.translatesAutoresizingMaskIntoConstraints = false
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

				accessoryIconView.widthAnchor.constraint(equalToConstant: 12.0),
				accessoryIconView.heightAnchor.constraint(equalToConstant: 21.0),
				accessoryIconView.topAnchor.constraint(equalTo: gradientView.topAnchor, constant: 20.0),
				accessoryIconView.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor, constant: -18.0),
				
				titleStackView.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: 15.0),
				titleStackView.topAnchor.constraint(equalTo: gradientView.topAnchor, constant: 20.0),
				titleStackView.trailingAnchor.constraint(equalTo: accessoryIconView.leadingAnchor, constant: 8.0),

				qrCodeContainerView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16.0),
				qrCodeContainerView.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: 20.0),
				qrCodeContainerView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16.0),
				qrCodeContainerView.bottomAnchor.constraint(lessThanOrEqualTo: bottomView.bottomAnchor, constant: -24.0),
				qrCodeContainerView.heightAnchor.constraint(equalTo: qrCodeContainerView.widthAnchor),
				
				qrCodeView.leadingAnchor.constraint(equalTo: qrCodeContainerView.leadingAnchor, constant: 16.0),
				qrCodeView.topAnchor.constraint(equalTo: qrCodeContainerView.topAnchor, constant: 16.0),
				qrCodeView.trailingAnchor.constraint(equalTo: qrCodeContainerView.trailingAnchor, constant: -16.0),
				qrCodeView.bottomAnchor.constraint(equalTo: qrCodeContainerView.bottomAnchor, constant: -16.0)
			]
		)
	}

	private func updateBorderColors() {
		bottomView.layer.borderColor = UIColor.enaColor(for: .cardBorder).cgColor
		qrCodeContainerView.layer.borderColor = UIColor.enaColor(for: .cardBorder).cgColor
	}

}
