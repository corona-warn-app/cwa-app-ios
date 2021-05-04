////
// 🦠 Corona-Warn-App
//

import UIKit

final class HealthCertificateCellViewModel {

	// MARK: - Init
	init(
		healthCertificate: String,
		type: GradientView.GradientType
	) {
		self.healthCertificate = healthCertificate
		self.type = type
	}

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	var headline: String {
		// depending on certificate
		return "Impfung 1 von 2"
	}

	var detail: String {
		// depending on certificate
		return "durchgeführt am 12.04.2021"
	}

	var gradientType: GradientView.GradientType {
		// grey or light blue depending on certificate
		return type
	}

	var image: UIImage {
		// image depending on certificate
		return UIImage(imageLiteralResourceName: "Icon - Teilschild")
	}

	// MARK: - Private

	private let healthCertificate: String
	private let type: GradientView.GradientType

}
