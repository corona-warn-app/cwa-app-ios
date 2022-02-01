//
// 🦠 Corona-Warn-App
//

import UIKit

class RoundedLabeledView: UIView {
		
	// MARK: - Overrides

	override func layoutSubviews() {
		super.layoutSubviews()
		
		roundedView.layer.cornerRadius = roundedView.bounds.height / 2
		titleLabel.font = .enaFont(for: .subheadline, weight: .semibold, italic: false)
		
		accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.AdmissionState.roundedView
		titleLabel.accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.AdmissionState.title
	}

	// MARK: - Internal

	func configure(title: String?, gradientType: GradientView.GradientType) {
		titleLabel.text = title
		accessibilityLabel = title

		setupGradient(gradientType: gradientType)
	}
	
	// MARK: - Private
	
	private func setupGradient(gradientType: GradientView.GradientType) {
		let gradientView = GradientView(type: gradientType)
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
