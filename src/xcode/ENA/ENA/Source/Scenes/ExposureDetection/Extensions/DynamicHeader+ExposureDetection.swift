//
// 🦠 Corona-Warn-App
//

import ExposureNotification
import Foundation
import UIKit
import OpenCombine

// MARK: - Supported Header Types

extension DynamicHeader {
	static func backgroundSpace(height: CGFloat) -> DynamicHeader {
		.space(height: height, color: .enaColor(for: .background))
	}

	static func riskTint(height _: CGFloat) -> DynamicHeader {
		.custom { viewController in
			let view = UIView()
			let heightConstraint = view.heightAnchor.constraint(equalToConstant: 16)
			heightConstraint.priority = .defaultHigh
			heightConstraint.isActive = true
			view.backgroundColor = (viewController as? ExposureDetectionViewController)?.viewModel.riskBackgroundColor
			return view
		}
	}
}
