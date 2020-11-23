//
// 🦠 Corona-Warn-App
//

import Foundation


extension SAP_Internal_ApplicationConfiguration {
	var revokationEtags: [String] {
		let dayMeta = iosKeyDownloadParameters.revokedDayPackages
		let hourMeta = iosKeyDownloadParameters.revokedHourPackages

		var etags = dayMeta.map({ $0.etag })
		etags.append(contentsOf: hourMeta.map({ $0.etag }))

		return etags
	}
}
