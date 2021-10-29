//
// 🦠 Corona-Warn-App
//

import Foundation

extension Locator {

	// send:	Empty
	// receive:	Protobuf SAP_Internal_Pt_QRCodePosterTemplateIOS
	// type:	caching
	// comment:
	static var qrCodePosterTemplate: Locator {
		Locator(
			endpoint: .distribution,
			paths: ["version", "v1", "qr_code_poster_template_ios"],
			method: .get
		)
	}

}
