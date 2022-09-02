//
// 🦠 Corona-Warn-App
//

import UIKit

class RoundedLabeledView: UIView {

	override init(frame: CGRect) {
		super.init(frame: frame)

		setContentHuggingPriority(.required, for: .horizontal)
		setContentHuggingPriority(.required, for: .vertical)
		setContentCompressionResistancePriority(.init(rawValue: 999), for: .horizontal)
		setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

		gradientView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(gradientView)

		containerStackView.translatesAutoresizingMaskIntoConstraints = false
		gradientView.addSubview(containerStackView)

		NSLayoutConstraint.activate([
			gradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
			gradientView.topAnchor.constraint(equalTo: topAnchor),
			gradientView.trailingAnchor.constraint(equalTo: trailingAnchor),
			gradientView.bottomAnchor.constraint(equalTo: bottomAnchor),

			imageView.widthAnchor.constraint(equalToConstant: 37),
			imageView.heightAnchor.constraint(equalToConstant: 27),

			containerStackView.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: 12),
			containerStackView.topAnchor.constraint(equalTo: gradientView.topAnchor, constant: 6),
			containerStackView.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor, constant: -12),
			containerStackView.bottomAnchor.constraint(equalTo: gradientView.bottomAnchor, constant: -6)
		])

		titleLabel.font = .enaFont(for: .subheadline, weight: .semibold, italic: false)
		titleLabel.textColor = .enaColor(for: .textContrast)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func layoutSubviews() {
		super.layoutSubviews()

		gradientView.layer.cornerRadius = gradientView.bounds.height / 2
	}

	// MARK: - Internal

	func configure(title: String?, fontColor: UIColor? = .enaColor(for: .textContrast), image: UIImage? = nil, gradientType: GradientView.GradientType, accessibilityIdentifier: String? = nil, labelAccessibilityIdentifier: String? = nil) {
		titleLabel.text = title

		titleLabel.textColor = fontColor
		accessibilityLabel = title
		
		if accessibilityIdentifier != nil {
			self.accessibilityIdentifier = accessibilityIdentifier
		}
		
		if labelAccessibilityIdentifier != nil {
			titleLabel.accessibilityIdentifier = labelAccessibilityIdentifier
		}
		
		if image != nil {
			imageView.isHidden = false
			imageView.image = image
			titleLabel.textAlignment = .left
		} else {
			imageView.isHidden = true
			titleLabel.textAlignment = .center
		}

		gradientView.type = gradientType
	}
	
	// MARK: - Private
	
	private var gradientView = GradientView(type: .solidGrey)
	private var titleLabel = ENALabel()
    private var imageView = UIImageView()
	
	private lazy var containerStackView: UIStackView = {
		var containerStackView: UIStackView
		containerStackView = UIStackView(arrangedSubviews: [imageView, titleLabel])
		containerStackView.axis = .horizontal
		containerStackView.spacing = 4.0

		return containerStackView
	}()
}
