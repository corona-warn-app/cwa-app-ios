////
// 🦠 Corona-Warn-App
//

import UIKit

class ErrorReportFooterView: UIView {
	
	// MARK: - Internal

	func configure(status: ErrorLoggingStatus) {
		
		switch status {
		case .active:
			coloredCircle.backgroundColor = .enaColor(for: .brandRed)
			statusTitle.text = "Fehleranalyse läuft"
			statusDescription.text = "Derzeitige Größe 12 B (unkomprimiert)"

		case .inactive:
			coloredCircle.backgroundColor = .enaColor(for: .textSemanticGray)
			statusTitle.text = "NOT ACTIVE"
			statusDescription.text = "statusDescription"

		}
	}

	// MARK: - Private

	@IBOutlet private weak var statusTitle: ENALabel!
	@IBOutlet private weak var statusDescription: ENALabel!
	@IBOutlet private weak var coloredCircle: UIView!
	@IBOutlet private weak var buttonsStackView: UIStackView!
}

enum ErrorLoggingStatus {
	case active
	case inactive
}
