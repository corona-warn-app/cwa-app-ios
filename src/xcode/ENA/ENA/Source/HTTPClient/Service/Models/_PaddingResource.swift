//
// 🦠 Corona-Warn-App
//

import Foundation

/// this protocol gets used to extend json model for padding data
/// all(?) JSON SendResources will use that

protocol PaddingResource: Encodable {
	var requestPadding: String { get set }
	var paddingCount: String { get }
}

extension PaddingResource {

	var paddingCount: String {
		let maxRequestPayloadSize = 250
		guard let paddedData = try? JSONEncoder().encode(self) else {
			fatalError("padding count error")
		}
		let paddingSize = maxRequestPayloadSize - paddedData.count
		return String.getRandomString(of: max(0, paddingSize))
	}
}
