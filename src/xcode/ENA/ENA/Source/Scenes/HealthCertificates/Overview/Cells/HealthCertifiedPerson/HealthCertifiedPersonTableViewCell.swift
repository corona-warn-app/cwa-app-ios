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
//		descriptionLabel.text = cellModel.description
//		descriptionLabel.isHidden = cellModel.description == nil
//
//		titleLabel.text = cellModel.title
//		nameLabel.text = cellModel.name
//		gradientView.type = cellModel.backgroundGradientType
//
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
		topContainerView.backgroundColor = .enaColor(for: .cellBackground) //.red
//		topContainerView.layer.borderWidth = 1.0
//		topContainerView.layer.borderColor = UIColor.enaColor(for: .hairline).cgColor
//		topContainerView.layer.cornerRadius = 14
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

//		let outerContainer = UIView()
//		outerContainer.backgroundColor = .red // .enaColor(for: .cellBackground)
//		outerContainer.translatesAutoresizingMaskIntoConstraints = false
//		contentView.addSubview(outerContainer)

//		gradientView.translatesAutoresizingMaskIntoConstraints = false
//		contentView.addSubview(gradientView)

		NSLayoutConstraint.activate(
			[
				topContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8.0),
				topContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.0),
				topContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),
				topContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0),

				gradientView.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor),
				gradientView.topAnchor.constraint(equalTo: topContainerView.topAnchor),
				gradientView.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor),
				gradientView.bottomAnchor.constraint(equalTo: topContainerView.bottomAnchor, constant: -180), //update later
				gradientView.heightAnchor.constraint(equalToConstant: 180.0)
			]
		)

	}

}
