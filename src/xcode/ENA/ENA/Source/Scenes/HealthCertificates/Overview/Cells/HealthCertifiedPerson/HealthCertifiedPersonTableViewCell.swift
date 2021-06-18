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
		descriptionLabel.isHidden = cellModel.description == nil

		titleLabel.text = cellModel.title
		nameLabel.text = cellModel.name
		gradientView.type = cellModel.backgroundGradientType

		accessibilityIdentifier = cellModel.accessibilityIdentifier
	}
	
	// MARK: - Private

	private let titleLabel: ENALabel = ENALabel()
	private let descriptionLabel: ENALabel = ENALabel()
	private let nameLabel: ENALabel = ENALabel()
	private let gradientView: GradientView = GradientView(type: .lightBlue(withStars: true))

//	private func setupAccessibility() {
//		containerView.accessibilityElements = [titleLabel as Any, nameLabel as Any, descriptionLabel as Any]
//
//		titleLabel.accessibilityTraits = [.header, .button]
//	}

	private func setupView() {
		let outerContainer = UIView()
		outerContainer.backgroundColor = .enaColor(for: .cellBackground)
		outerContainer.translatesAutoresizingMaskIntoConstraints = false
		outerContainer.layer.borderWidth = 1.0
		outerContainer.layer.borderColor = UIColor.enaColor(for: .hairline).cgColor
		outerContainer.layer.cornerRadius = 14
		contentView.addSubview(outerContainer)

		gradientView.translatesAutoresizingMaskIntoConstraints = false
		outerContainer.addSubview(gradientView)

		NSLayoutConstraint.activate(
			[
				gradientView.leadingAnchor.constraint(equalTo: outerContainer.leadingAnchor),
				gradientView.topAnchor.constraint(equalTo: outerContainer.topAnchor),
				gradientView.trailingAnchor.constraint(equalTo: outerContainer.trailingAnchor),
				gradientView.bottomAnchor.constraint(equalTo: outerContainer.bottomAnchor, constant: -167), //update later

				outerContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8.0),
				outerContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.0),
				outerContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),
				outerContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0)
			]
		)

	}

}
