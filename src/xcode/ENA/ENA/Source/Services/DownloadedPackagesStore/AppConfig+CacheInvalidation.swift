//
// 🦠 Corona-Warn-App
//

import Foundation


extension SAP_Internal_V2_ApplicationConfigurationIOS {
	var revokationEtags: [String] {
		let dayMeta = keyDownloadParameters.revokedDayPackages
		let hourMeta = keyDownloadParameters.revokedHourPackages

		var etags = dayMeta.map({ $0.etag })
		etags.append(contentsOf: hourMeta.map({ $0.etag }))

		return etags
	}
}
