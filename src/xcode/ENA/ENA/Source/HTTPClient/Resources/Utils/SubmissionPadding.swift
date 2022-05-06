//
// 🦠 Corona-Warn-App
//

import Foundation

extension Array where Element == SAP_External_Exposurenotification_TemporaryExposureKey {
	
	/// This method recreates the request body of the submit keys request with a padding that fills up to resemble
	/// a request with 14 +`n` keys. Note that the `n`parameter is currently set to 0, but can change in the future
	/// when there will be support for 15 keys.
	var submissionPadding: Data {
		// This parameter denotes how many keys 14 + n have to be padded.
		let n = 0
		let paddedKeysAmount = 14 + n - count
		guard paddedKeysAmount > 0 else { return Data() }
		guard let data = (String.getRandomString(of: 28 * paddedKeysAmount)).data(using: .ascii) else { return Data() }
		return data
	}
}
