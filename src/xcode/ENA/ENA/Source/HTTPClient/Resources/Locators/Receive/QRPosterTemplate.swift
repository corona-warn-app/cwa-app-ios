//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	static var qrCodePosterTemplate: Locator {
		Locator(
			endpoint: .distribution,
			paths: ["version", "v1", "qr_code_poster_template_ios"],
			method: .get
		)
	}

}
