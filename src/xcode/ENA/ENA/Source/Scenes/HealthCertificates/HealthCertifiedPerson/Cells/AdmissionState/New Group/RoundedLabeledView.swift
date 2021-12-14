//
// 🦠 Corona-Warn-App
//

import UIKit

class RoundedLabeledView: UIView {
		
	// MARK: - Overrides

	override func layoutSubviews() {
		super.layoutSubviews()
		
		roundedView.layer.cornerRadius = roundedView.bounds.height / 2
		
		isAccessibilityElement = true
		accessibilityTraits = .button
		accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.AdmissionState.roundedView
		titleLabel.accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.AdmissionState.title
	}

	// MARK: - Internal

	func configure(title: String?) {
		titleLabel.text = title
		accessibilityLabel = title

		setupGradient()
	}
	
	// MARK: - Private
	
	private func setupGradient() {
		let gradientView = GradientView(type: .darkBlue(withStars: false))
		gradientView.translatesAutoresizingMaskIntoConstraints = false
		roundedView.insertSubview(gradientView, belowSubview: titleLabel)
		NSLayoutConstraint.activate(
			[
				gradientView.leadingAnchor.constraint(equalTo: roundedView.leadingAnchor),
				gradientView.topAnchor.constraint(equalTo: roundedView.topAnchor),
				gradientView.trailingAnchor.constraint(equalTo: roundedView.trailingAnchor),
				gradientView.bottomAnchor.constraint(equalTo: roundedView.bottomAnchor)
			]
		)
	}
	
	@IBOutlet private weak var roundedView: UIView!
	@IBOutlet private weak var titleLabel: ENALabel!
}
