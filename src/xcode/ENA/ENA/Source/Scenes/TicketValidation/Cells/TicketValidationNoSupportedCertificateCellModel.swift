//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit.UIImage

final class TicketValidationNoSupportedCertificateCellModel {

	// MARK: - Init

	init(
		serviceProviderRequirementsDescription: String
	) {
		self.serviceProviderRequirementsDescription = serviceProviderRequirementsDescription
	}

	// MARK: - Internal

	var iconImage: UIImage? {
		return UIImage(imageLiteralResourceName: "Icon_CertificateValidation_Failed")
	}

	var serviceProviderRequirements: String? {
		return self.serviceProviderRequirementsDescription
	}

	// MARK: - Private

	private let serviceProviderRequirementsDescription: String
}
