//
// 🦠 Corona-Warn-App
//

import UIKit

struct HealthCertificateExpirationDateCellViewModel {

	let headline: String
	let expirationDate: String
	let content: String

	let headlineTextColor: UIColor = .enaColor(for: .textPrimary1)
	let expirationDateTextColor: UIColor = .enaColor(for: .textPrimary2)
	let contentTextColor: UIColor = .enaColor(for: .textPrimary1)

}
