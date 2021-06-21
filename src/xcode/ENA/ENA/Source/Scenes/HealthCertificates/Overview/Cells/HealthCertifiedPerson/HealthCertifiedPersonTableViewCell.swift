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
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

//	override func awakeFromNib() {
//		super.awakeFromNib()
//
//		backgroundGradientView.type = .solidGrey
//		backgroundGradientView.layer.cornerRadius = 14
//
//		if #available(iOS 13.0, *) {
//			backgroundGradientView.layer.cornerCurve = .continuous
//		}
//		setupAccessibility()
//	}
//
//	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
//		super.setHighlighted(highlighted, animated: animated)
//
//		containerView.setHighlighted(highlighted, animated: animated)
//	}

	// MARK: - Internal

	func configure(with cellModel: HealthCertifiedPersonCellModel) {
		descriptionLabel.text = cellModel.description
		titleLabel.text = cellModel.title
		nameLabel.text = cellModel.name
		gradientView.type = cellModel.backgroundGradientType
//		accessibilityIdentifier = cellModel.accessibilityIdentifier
	}
	
	// MARK: - Private

	private let titleLabel: ENALabel = ENALabel()
	private let descriptionLabel: ENALabel = ENALabel()
	private let nameLabel: ENALabel = ENALabel()
	private let gradientView: GradientView = GradientView(type: .lightBlue(withStars: false), frame: CGRect(x: 0, y: 0, width: 320, height: 180))

//	private func setupAccessibility() {
//		containerView.accessibilityElements = [titleLabel as Any, nameLabel as Any, descriptionLabel as Any]
//
//		titleLabel.accessibilityTraits = [.header, .button]
//	}

	private func setupView() {
		let topContainerView = UIView()
		topContainerView.translatesAutoresizingMaskIntoConstraints = false
		topContainerView.backgroundColor = .enaColor(for: .cellBackground)
		topContainerView.layer.masksToBounds = true
		topContainerView.layer.cornerRadius = 12
		if #available(iOS 13.0, *) {
			topContainerView.layer.cornerCurve = .continuous
		}
		contentView.addSubview(topContainerView)

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
		bottomView.translatesAutoresizingMaskIntoConstraints = false
		bottomView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
		bottomView.layer.cornerRadius = 12
		bottomView.layer.borderWidth = 1
		bottomView.layer.borderColor = UIColor.enaColor(for: .hairline).cgColor
		if #available(iOS 13.0, *) {
			bottomView.layer.cornerCurve = .continuous
		}
		topContainerView.addSubview(bottomView)

		let stackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.spacing = 4.0
		gradientView.addSubview(stackView)

		nameLabel.font = .enaFont(for: .title2, weight: .regular, italic: false)
		nameLabel.translatesAutoresizingMaskIntoConstraints = false
		gradientView.addSubview(nameLabel)

		NSLayoutConstraint.activate(
			[
				topContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
				topContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.0),
				topContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),
				topContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0),

				gradientView.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor),
				gradientView.topAnchor.constraint(equalTo: topContainerView.topAnchor),
				gradientView.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor),
				gradientView.heightAnchor.constraint(equalToConstant: 180.0),

				bottomView.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor),
				bottomView.topAnchor.constraint(equalTo: gradientView.bottomAnchor, constant: -1.0),
				bottomView.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor),
				bottomView.bottomAnchor.constraint(equalTo: topContainerView.bottomAnchor),
				bottomView.heightAnchor.constraint(equalToConstant: 90.0),

				stackView.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: 15.0),
				stackView.topAnchor.constraint(equalTo: gradientView.topAnchor, constant: 20.0),
				stackView.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor, constant: -15.0),

				nameLabel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 15.0),
				nameLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
				nameLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor)

			]
		)

	}

}
