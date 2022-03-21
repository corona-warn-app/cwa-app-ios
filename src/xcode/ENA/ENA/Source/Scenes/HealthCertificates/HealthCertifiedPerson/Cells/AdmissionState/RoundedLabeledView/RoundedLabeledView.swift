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

		titleLabel.setContentHuggingPriority(.required, for: .horizontal)
		titleLabel.setContentHuggingPriority(.required, for: .vertical)
		titleLabel.setContentCompressionResistancePriority(.init(rawValue: 999), for: .horizontal)
		titleLabel.setContentCompressionResistancePriority(.init(rawValue: 760), for: .vertical)
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		gradientView.addSubview(titleLabel)

		NSLayoutConstraint.activate([
			gradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
			gradientView.topAnchor.constraint(equalTo: topAnchor),
			gradientView.trailingAnchor.constraint(equalTo: trailingAnchor),
			gradientView.bottomAnchor.constraint(equalTo: bottomAnchor),

			titleLabel.leadingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: 12),
			titleLabel.topAnchor.constraint(equalTo: gradientView.topAnchor, constant: 6),
			titleLabel.trailingAnchor.constraint(equalTo: gradientView.trailingAnchor, constant: -12),
			titleLabel.bottomAnchor.constraint(equalTo: gradientView.bottomAnchor, constant: -6)
		])

		titleLabel.font = .enaFont(for: .subheadline, weight: .semibold, italic: false)
		titleLabel.textColor = .enaColor(for: .textContrast)

		accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.AdmissionState.roundedView
		titleLabel.accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.AdmissionState.title
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

	func configure(title: String?, gradientType: GradientView.GradientType) {
		titleLabel.text = title
		accessibilityLabel = title

		gradientView.type = gradientType
	}
	
	// MARK: - Private
	
	private var gradientView = GradientView(type: .solidGrey)
	private var titleLabel = ENALabel()

}
