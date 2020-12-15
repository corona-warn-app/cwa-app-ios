//
// 🦠 Corona-Warn-App
//

import Foundation


extension SAP_Internal_V2_ApplicationConfigurationIOS {
	var revokationEtags: [String] {
		let dayMeta = keyDownloadParameters.cachedDayPackagesToUpdateOnEtagMismatch
		let hourMeta = keyDownloadParameters.cachedHourPackagesToUpdateOnEtagMismatch

		var etags = dayMeta.map({ $0.etag })
		etags.append(contentsOf: hourMeta.map({ $0.etag }))

		return etags
	}
}
